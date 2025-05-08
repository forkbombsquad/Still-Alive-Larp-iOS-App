//
//  ApproveBioView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct ApproveBioView: View {
    @ObservedObject var _dm = DataManager.shared

    @Binding var character: CharacterModel
    @State var loading = false
    @State var giveXp = true

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                VStack {
                    Text("\(character.fullName)\nBio")
                        .font(.system(size: 32, weight: .bold))
                        .frame(alignment: .center)
                        .padding(.trailing, 0)
                    ScrollView(.vertical) {
                        Text(character.bio)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 100)
                            .padding(.trailing, 0)
                    }
                    .padding(.trailing, 0)
                    Divider()
                    Toggle("Grant Experience On Approval", isOn: $giveXp).tint(.brightRed)
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Approve") {
                        self.loading = true
                        self.character.approvedBio = "TRUE"
                        AdminService.updateCharacter(self.character) { characterModel in
                            if self.giveXp {
                                let award = AwardCreateModel(playerId: character.playerId, characterId: nil, awardType: AdminService.PlayerAwardType.xp.rawValue, reason: "Bio approved", date: Date().yyyyMMddFormatted, amount: "1")
                                AdminService.awardPlayer(award) { _ in
                                    runOnMainThread {
                                        self.loading = false
                                        self.character = characterModel
                                        self.mode.wrappedValue.dismiss()
                                    }
                                } failureCase: { error in
                                    self.loading = false
                                }
                            } else {
                                runOnMainThread {
                                    self.loading = false
                                    self.character = characterModel
                                    self.mode.wrappedValue.dismiss()
                                }
                            }

                        } failureCase: { error in
                            self.loading = false
                        }
                    }
                    .padding(.trailing, 0)
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Deny") {
                        self.loading = true
                        AlertManager.shared.showAlert("Are You Sure?", message: "Are you sure you want to deny \(self.character.fullName)'s bio? This will delete it and they will have to write another one.", button1: Alert.Button.destructive(Text("Deny Bio"), action: {
                            self.character.approvedBio = "FALSE"
                            self.character.bio = ""
                            AdminService.updateCharacter(self.character) { characterModel in
                                runOnMainThread {
                                    self.character = characterModel
                                    self.loading = false
                                    self.mode.wrappedValue.dismiss()
                                }
                            } failureCase: { error in
                                self.loading = false
                            }

                        }), button2: AlertConstants.Buttons.cancel({
                            self.loading = false
                        }))
                    }
                    .padding(.trailing, 0)
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
}
