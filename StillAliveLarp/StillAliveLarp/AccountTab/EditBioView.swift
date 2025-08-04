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

    init() {
        self._bio = State(initialValue: OldDM.character?.bio ?? "")
    }

    @State var bio: String
    @State var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
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
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Submit Update") {
                        if let character = OldDM.character {
                            self.loading = true
                            var char = character.baseModel
                            char.bio = self.bio

                            CharacterService.updateBio(char) { characterModel in
                                OldDM.load([.character], forceDownloadIfApplicable: true)
                                AlertManager.shared.showOkAlert("Success", message: "\(character.fullName)'s bio was approved!") {
                                    runOnMainThread {
                                        self.mode.wrappedValue.dismiss()
                                    }
                                }
                            } failureCase: { error in
                                self.loading = false
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 0)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.lightGray)
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    dm.character = md.fullCharacters()[1]
    var ebv = EditBioView()
    ebv._dm = dm
    return ebv
}
