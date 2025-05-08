//
//  RegisterPrimaryWeaponView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/29/23.
//

import SwiftUI

struct RegisterPrimaryWeaponView: View {
    @ObservedObject var _dm = DataManager.shared

    let character: CharacterModel
    @State private var name: String = ""
    @State private var ammo: String = ""

    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        // TODO fix
//                        Text("\((DataManager.shared.loadingSelectedCharacterGear || DataManager.shared.selectedCharacterGear?.primaryWeapon == nil) ? "Register" : "Edit") Primary Weapon\(DataManager.shared.loadingSelectedCharacterGear ? "" : "\nFor \(character.fullName)")")
//                            .font(Font.system(size: 36, weight: .bold))
//                            .multilineTextAlignment(.center)
//                            .padding(.trailing, 0)
                        if DataManager.shared.loadingSelectedCharacterGear {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            TextField("Weapon Name", text: $name)
                                .padding(.top, 8)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.default)
                                .padding(.trailing, 0)
                            TextField("Ammunition Amount And Type", text: $ammo)
                                .padding(.top, 8)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.default)
                                .padding(.trailing, 0)
                                .padding(.bottom, 16)
                            LoadingButtonView($loading, width: gr.size.width - 32, buttonText: isEditing() ? "Submit Changes" : "Submit") {
                                let valResult = validateFields()
                                if !valResult.hasError {
                                    self.loading = true
                                    if !self.isEditing() {
                                        // TODO fix
//                                        let gearModel = GearCreateModel(characterId: self.character.id, type: Constants.Gear.primaryWeapon, name: self.name, description: self.ammo)
//                                        AdminService.createGear(gearModel) { _ in
//                                            self.loading = false
//                                            AlertManager.shared.showSuccessAlert("\(self.name) registered as Primary Weapon for \(self.character.fullName)") {
//                                                runOnMainThread {
//                                                    self.mode.wrappedValue.dismiss()
//                                                }
//                                            }
//                                        } failureCase: { _ in
//                                            self.loading = false
//                                        }

                                    } else {
                                        // TODO fix
//                                        let gearModel = GearModel(id: DataManager.shared.selectedCharacterGear?.primaryWeapon?.id ?? -1, characterId: self.character.id, type: Constants.Gear.primaryWeapon, name: self.name, description: self.ammo)
//                                        AdminService.updateGear(gearModel: gearModel) { _ in
//                                            self.loading = false
//                                            AlertManager.shared.showSuccessAlert("\(self.name) registered as Primary Weapon for \(self.character.fullName)") {
//                                                runOnMainThread {
//                                                    self.mode.wrappedValue.dismiss()
//                                                }
//                                            }
//                                        } failureCase: { _ in
//                                            self.loading = false
//                                        }
                                    }
                                } else {
                                    AlertManager.shared.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
                                }
                            }
                            .padding(.trailing, 0)
                        }
                    }
                }
            }
        }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.lightGray)
            .onAppear {
                runOnMainThread {
                    DataManager.shared.selectedChar = character
                        // TODO fix
//                    DataManager.shared.load([.selectedCharacterGear], forceDownloadIfApplicable: true) {
//                        if let primaryWeapon = DataManager.shared.selectedCharacterGear?.primaryWeapon {
//                            self.name = primaryWeapon.name
//                            self.ammo = primaryWeapon.description
//                        }
//                    }
                }
            }
    }

    func isEditing() -> Bool {
        // TODO fix
//        return DataManager.shared.selectedCharacterGear?.primaryWeapon != nil
        return false
    }

    private func validateFields() -> ValidationResult {
        return Validator.validateMultiple([
            ValidationGroup(text: name, validationType: .primaryWeaponName),
            ValidationGroup(text: ammo, validationType: .primaryWeaponAmmo)])
    }
}
