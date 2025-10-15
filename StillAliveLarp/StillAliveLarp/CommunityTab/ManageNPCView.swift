//
//  ManageNPCView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

import SwiftUI

struct ManageNPCView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var loading = false
    @State var bullets = ""
    @State var infection = ""
    @State var isAlive = true
    
    @State var character: FullCharacterModel?
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        if let character = character {
                            Text("Manage NPC\n\(character.fullName)")
                                .font(.system(size: 32, weight: .bold))
                                .frame(alignment: .center)
                            ArrowViewButton(title: "Manage Bullets and Infection", loading: $loading) {
                                runOnMainThread {
                                    self.bullets = character.bullets.stringValue
                                    self.infection = character.infection.stringValue
                                    self.isAlive = character.isAlive
                                    self.loading = true
                                    alertManager.showDynamicAlert(model: CustomAlertModel(
                                        title: "Adjust \(character.fullName) Values", textFields: [
                                            AlertTextField(placeholder: "Bullets", value: $bullets),
                                            AlertTextField(placeholder: "Infection Rating", value: $infection)
                                        ], checkboxes: [
                                            AlertToggle(text: "Is Alive?", isOn: $isAlive)
                                        ], verticalButtons: [], buttons: [
                                            AlertButton(title: "Ok", onPress: {
                                                var update = character
                                                update.bullets = self.bullets.intValueDefaultZero
                                                update.infection = self.infection.intValueDefaultZero
                                                update.isAlive = self.isAlive
                                                AdminService.updateCharacter(update.baseModel()) { characterModel in
                                                    runOnMainThread {
                                                        DM.load()
                                                        alertManager.showOkAlert("Update Successful!") {
                                                            runOnMainThread {
                                                                DM.load()
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
                                SkillsListView(character: $character, allowDelete: true)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
}
