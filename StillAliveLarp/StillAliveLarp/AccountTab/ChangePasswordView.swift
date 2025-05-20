//
//  ChangePasswordView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct ChangePasswordView: View {
    @ObservedObject var _dm = DataManager.shared

    @State private var existingPassword: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    @State private var loading = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Change Password")
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    PasswordField(hintText: "Current Password", password: $existingPassword)
                    PasswordField(hintText: "New Password", password: $password)
                    PasswordField(hintText: "Confirm New Password", password: $confirmPassword)
                    LoadingButtonView($loading, width: gr.size.width - 32, height: 60, buttonText: "Submit") {
                        if checkOldPass() {
                            if checkPasswordsMatch() {
                                let valResult = validateFields()
                                if !valResult.hasError {
                                    self.loading = true
                                    PlayerService.updateP(self.password, playerId: DataManager.shared.player?.id ?? -1) { player in
                                        runOnMainThread {
                                            UserAndPassManager.shared.setUAndP(player.username, p: password, remember: true)
                                            AlertManager.shared.showOkAlert("Password Successfuly Updated") {
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
                        } else {
                            AlertManager.shared.showOkAlert("Validation Error", message: "Existing password incorrect", onOkAction: {})
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

    private func checkOldPass() -> Bool {
        return self.existingPassword == UserAndPassManager.shared.getP()
    }

}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return ChangePasswordView(_dm: dm)
}
