//
//  AwardPlayerFormView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI
import Combine

struct AwardPlayerFormView: View {
    @ObservedObject var _dm = DataManager.shared

    private static let xp = "XP"
    private static let pp = "Prestige Points"
    private static let fs = "Free Tier-1 Skills"

    let player: PlayerModel
    @State private var awardType: String = AwardPlayerFormView.xp
    @State private var awardOptions = [AwardPlayerFormView.xp, AwardPlayerFormView.pp, AwardPlayerFormView.fs]
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
                            case AwardPlayerFormView.xp:
                                type = .xp
                            case AwardPlayerFormView.pp:
                                type = .prestigePoints
                            case AwardPlayerFormView.fs:
                                type = .freeTier1Skills
                            default:
                                break
                        }
                        if let type = type {
                            let award = AwardCreateModel.CreatePlayerAward(player, awardType: type, reason: reason, amount: amount)

                            self.loading = true
                            AdminService.awardPlayer(award) { updatedPlayer in
                                self.loading = false
                                if PlayerManager.shared.getPlayer()?.id == updatedPlayer.id {
                                    PlayerManager.shared.updatePlayer(updatedPlayer)
                                }
                                runOnMainThread {
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

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return AwardPlayerFormView(_dm: dm, player: md.player())
}
