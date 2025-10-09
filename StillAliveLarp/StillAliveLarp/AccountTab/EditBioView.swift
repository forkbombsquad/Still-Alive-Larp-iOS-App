//
//  EditBioView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct EditBioView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Binding var character: FullCharacterModel?
    @State var bio: String
    @State var loading: Bool = false
    @State var loadingText: String = ""

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    if let character = character {
                        Text("Edit Bio")
                            .font(Font.system(size: 36, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.trailing, 0)
                        TextEditor(text: $bio)
                            .padding(.top, 8)
                            .padding(.trailing, 0)
                            .textFieldStyle(.roundedBorder)
                            .frame(minHeight: 250)
                            .fixedSize(horizontal: false, vertical: true)
                            .placeholder(when: bio.isEmpty) {
                                Text("Bio\n(Optional, but if your bio is approved, you will earn 1 additional experience)").foregroundColor(.gray).padding().multilineTextAlignment(.center)
                            }
                        LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 32, buttonText: "Submit Update") {
                            self.loading = true
                            self.loadingText = "Submitting Bio Update..."
                            CharacterService.updateBio(character.baseModel()) { _ in
                                runOnMainThread {
                                    self.loadingText = "Updating Character..."
                                    DM.load(finished: {
                                        runOnMainThread {
                                            self.character = DM.getCharacter(character.id) ?? character
                                            AlertManager.shared.showSuccessAlert("\(character.fullName)'s bio was updated! It is now pending Staff approval.", onOkAction: {
                                                runOnMainThread {
                                                    self.loadingText = ""
                                                    self.loading = false
                                                    self.mode.wrappedValue.dismiss()
                                                }
                                            })
                                        }
                                    })
                                }
                            } failureCase: { error in
                                runOnMainThread {
                                    self.loading = false
                                    self.loadingText = ""
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 0)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.lightGray)
    }
}
