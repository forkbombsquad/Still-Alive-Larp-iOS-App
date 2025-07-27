//
//  ManageNPCView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

import SwiftUI

struct ManageNPCView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var _dm = OldDataManager.shared
    
    @Binding var npcs: [CharacterModel]
    let npc: CharacterModel
    
    @State var loading = false
    @State var bullets = ""
    @State var infection = ""
    @State var isAlive = true
    
    @State var fullChar: OldFullCharacterModel? = nil
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Manage NPC\n\(npc.fullName)")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ArrowViewButton(title: "Manage Bullets and Infection", loading: $loading) {
                            runOnMainThread {
                                self.bullets = npc.bullets
                                self.infection = npc.infection
                                self.isAlive = npc.isAlive.boolValueDefaultFalse
                                self.loading = true
                                AlertManager.shared.showDynamicAlert(model: CustomAlertModel(
                                    title: "Adjust \(npc.fullName) Values", textFields: [
                                        AlertTextField(placeholder: "Bullets", value: $bullets),
                                        AlertTextField(placeholder: "Infection Rating", value: $infection)
                                    ], checkboxes: [
                                        AlertToggle(text: "Is Alive?", isOn: $isAlive)
                                    ], verticalButtons: [], buttons: [
                                        AlertButton(title: "Ok", onPress: {
                                            var update = self.npc
                                            update.bullets = self.bullets
                                            update.infection = self.infection
                                            update.isAlive = self.isAlive.stringValue.uppercased()
                                            AdminService.updateCharacter(update) { characterModel in
                                                runOnMainThread {
                                                    if let index = npcs.firstIndex(where: { $0.id == characterModel.id }) {
                                                        npcs[index] = characterModel
                                                    }
                                                    AlertManager.shared.showOkAlert("Update Successful!") {
                                                        runOnMainThread {
                                                            self.loading = false
                                                            self.presentationMode.wrappedValue.dismiss()
                                                        }
                                                    }
                                                }
                                                
                                            } failureCase: { error in
                                                runOnMainThread {
                                                    self.loading = false
                                                }
                                            }

                                        }),
                                        AlertButton.cancel(onPress: {
                                            runOnMainThread {
                                                self.loading = false
                                            }
                                        })
                                    ])
                                )
                            }
                        }
                        NavArrowView(title: "Manage Skills", loading: $loading) { _ in
                            if let char = self.fullChar {
                                SkillManagementView(character: char, allowEdit: true)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            self.loading = true
            CharacterManager.shared.fetchFullCharacter(characterId: npc.id) { fcm in
                self.fullChar = fcm
                self.loading = false
            }
        }
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return ManageNPCView(_dm: dm, npcs: .constant(md.characterListFullModel.characters), npc: md.character())
}
