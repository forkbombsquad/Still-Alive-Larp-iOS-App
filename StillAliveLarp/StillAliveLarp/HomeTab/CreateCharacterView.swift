//
//  CreateCharacterView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import SwiftUI

// TODO redo view
struct CreateCharacterView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State private var fullName: String = ""
    @State private var bio: String = ""

    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Create Character")
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    TextField("", text: $fullName)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .placeholder(when: fullName.isEmpty) {
                            Text("Full Character Name").foregroundColor(.gray).padding().padding(.top, 4)
                        }
                    TextEditor(text: $bio)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 250)
                        .fixedSize(horizontal: false, vertical: true)
                        .placeholder(when: bio.isEmpty) {
                            Text("Bio\n(Optional, but if your bio is approved, you will earn 1 additional experience)").foregroundColor(.gray).padding().multilineTextAlignment(.center)
                        }
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Submit") {
                        let valResult = validateFields()
                        if !valResult.hasError {
//                            self.loading = true
//                            let char = CreateCharacterModel(fullName: fullName, startDate: Date().yyyyMMddFormatted, isAlive: "TRUE", deathDate: "", infection: "0", bio: bio, approvedBio: "FALSE", bullets: "20", megas: "0", rivals: "0", rockets: "0", bulletCasings: "0", clothSupplies: "0", woodSupplies: "0", metalSupplies: "0", techSupplies: "0", medicalSupplies: "0", armor: CharacterModel.ArmorType.none.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: OldDM.player?.id ?? -1, characterTypeId: Constants.CharacterTypes.standard)
//
//                            CharacterService.createCharacter(char) { characterModel in
//                                OldDM.load([.player, .character], forceDownloadIfApplicable: true)
//                                AlertManager.shared.showSuccessAlert("Character named \(characterModel.fullName) created!") {
//                                    runOnMainThread {
//                                        self.mode.wrappedValue.dismiss()
//                                    }
//                                }
//                            } failureCase: { _ in
//                                self.loading = false
//                            }

                        } else {
                            AlertManager.shared.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
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

    private func validateFields() -> ValidationResult {
        return Validator.validateMultiple([
            ValidationGroup(text: fullName, validationType: .fullName)])
    }

}

#Preview {
    DataManager.shared.setDebugMode(true)
    return CreateCharacterView()
}
