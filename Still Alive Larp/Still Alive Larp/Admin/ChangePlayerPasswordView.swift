//
//  ChangePlayerPasswordView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

//
//  ChangePasswordView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct ChangePlayerPasswordView: View {
    @ObservedObject private var _dm = DataManager.shared

    let player: PlayerModel

    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    @State private var loading = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Change Password For\n\(player.fullName)")
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    PasswordField(hintText: "New Password", password: $password)
                    PasswordField(hintText: "Confirm New Password", password: $confirmPassword)
                    LoadingButtonView($loading, width: gr.size.width - 32, height: 60, buttonText: "Submit") {
                        if checkPasswordsMatch() {
                            let valResult = validateFields()
                            if !valResult.hasError {
                                self.loading = true
                                AdminService.updatePAdmin(self.password, playerId: self.player.id) { player in
                                    runOnMainThread {
                                        AlertManager.shared.showOkAlert("Password Successfuly Updated For", message: player.fullName) {
                                            runOnMainThread {
                                                self.loading = false
                                                self.mode.wrappedValue.dismiss()
                                            }
                                        }
                                    }
                                } failureCase: { error in
                                    self.loading = false
                                }

                            } else {
                                AlertManager.shared.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
                            }
                        } else {
                            AlertManager.shared.showOkAlert("Validation Error", message: "Passwords do not match", onOkAction: {})
                        }
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.lightGray)
    }

    private func validateFields() -> ValidationResult {
        return Validator.validateMultiple([
            ValidationGroup(text: password, validationType: .password)])
    }

    private func checkPasswordsMatch() -> Bool {
        return password == confirmPassword
    }

}

