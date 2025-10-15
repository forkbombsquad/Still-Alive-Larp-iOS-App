//
//  AwardCharacterView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI
import Combine

struct AwardCharacterView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    typealias stat = AwardCharacterView

    private static let m = "MATERIAL"
    private static let a = "AMMO"
    private static let i = "INFECTION"

    private static let cas = "CASINGS"
    private static let woo = "WOOD"
    private static let clo = "CLOTH"
    private static let met = "METAL"
    private static let tec = "TECH"
    private static let med = "MED"

    private static let bul = "BULLET"
    private static let meg = "MEGA"
    private static let riv = "RIVAL"
    private static let roc = "ROCKET"

    let character: FullCharacterModel
    @State private var awardType: String = stat.m
    @State private var awardOptions = [stat.m, stat.a, stat.i]

    @State private var materialType: String = stat.cas
    @State private var materialOptions = [stat.cas, stat.woo, stat.clo, stat.met, stat.tec, stat.med]

    @State private var ammoType: String = stat.bul
    @State private var ammoOptions = [stat.bul, stat.meg, stat.riv, stat.roc]

    @State private var amount: String = ""
    @State private var reason: String = ""

    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Give Award To\n\(character.fullName)")
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    Picker(selection: $awardType, label: Text("Choose Award Type")) {
                        ForEach(awardOptions, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.trailing, 0)

                    if awardType == stat.m {
                        Picker(selection: $materialType, label: Text("Choose Material Type")) {
                            ForEach(materialOptions, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.trailing, 0)
                    }
                    if awardType == stat.a {
                        Picker(selection: $ammoType, label: Text("Choose Ammo Type")) {
                            ForEach(ammoOptions, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.trailing, 0)
                    }

                    TextField("Amount (Numbers Only)", text: $amount)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .onReceive(Just(amount)) { newValue in
                            let filtered = newValue.filter { "0123456789-".contains($0) }
                            if filtered != newValue {
                                self.amount = filtered
                            }
                        }
                    TextField("Reason", text: $reason)
                        .padding(.top, 8)
                        .textFieldStyle(.roundedBorder)
                        .padding(.trailing, 0)
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Submit") {
                        var aType = self.awardType
                        if self.awardType == stat.m {
                            aType = "\(aType)_\(self.materialType)"
                        }
                        if self.awardType == stat.a {
                            aType = "\(aType)_\(self.ammoType)"
                        }
                        if let type = AdminService.CharAwardType(rawValue: aType) {
                            let award = AwardCreateModel.CreateCharacterAward(character.baseModel(), awardType: type, reason: reason, amount: amount)

                            self.loading = true
                            AdminService.awardChar(award) { _ in
                                self.loading = false
                                runOnMainThread {
                                    DM.load()
                                    self.mode.wrappedValue.dismiss()
                                }
                            } failureCase: { _ in
                                self.loading = false
                            }
                        }
                    }
                    .padding(.trailing, 0)
                }
            }
        }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.lightGray)
    }
}
