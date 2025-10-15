//
//  AwardPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI
import Combine

struct AwardPlayerView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    private static let xp = "XP"
    private static let pp = "Prestige Points"
    private static let fs = "Free Tier-1 Skills"

    let player: FullPlayerModel
    @State private var awardType: String = AwardPlayerView.xp
    @State private var awardOptions = [AwardPlayerView.xp, AwardPlayerView.pp, AwardPlayerView.fs]
    @State private var amount: String = ""
    @State private var reason: String = ""

    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Give Award To\n\(player.fullName)")
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

                    TextField("Amount (Numbers Only)", text: $amount)
                        .padding(.top, 8)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .onReceive(Just(amount)) { newValue in
                            let filtered = newValue.filter { "0123456789-".contains($0) }
                            if filtered != newValue {
                                self.amount = filtered
                            }
                        }
                        .padding(.trailing, 0)
                    TextField("Reason", text: $reason)
                        .padding(.top, 8)
                        .textFieldStyle(.roundedBorder)
                        .padding(.trailing, 0)
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Submit") {
                        var type: AdminService.PlayerAwardType? = nil
                        switch self.awardType {
                            case AwardPlayerView.xp:
                                type = .xp
                            case AwardPlayerView.pp:
                                type = .prestigePoints
                            case AwardPlayerView.fs:
                                type = .freeTier1Skills
                            default:
                                break
                        }
                        if let type = type {
                            let award = AwardCreateModel.CreatePlayerAward(player.baseModel(), awardType: type, reason: reason, amount: amount)

                            self.loading = true
                            AdminService.awardPlayer(award) { updatedPlayer in
                                runOnMainThread {
                                    AlertManager.shared.showSuccessAlert("Successfully Awarded Player!", onOkAction: {
                                        runOnMainThread {
                                            self.mode.wrappedValue.dismiss()
                                        }
                                    })
                                    DM.load()
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
        .padding(16)
        .background(Color.lightGray)
    }

}
