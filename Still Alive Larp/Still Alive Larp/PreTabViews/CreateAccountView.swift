//
//  CreateAccountView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/17/22.
//

import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var _dm = DataManager.shared

    @State private var fullName: String = ""
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var preApprovalCode: String = ""

    @State private var loading = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Create Account")
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    TextField("Full Name", text: $fullName)
                        .padding(.top, 8)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .padding(.trailing, 0)
                    TextField("Email Address", text: $emailAddress)
                        .padding(.top, 8)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding(.trailing, 0)
                    PasswordField(hintText: "Password", password: $password)
                    PasswordField(hintText: "Confirm Password", password: $confirmPassword)
                    Text("Only pre-approved players are allowed to create an account for Still Alive Larp. Once you're pre-approved, you'll be given a security code. Please enter that below")
                        .padding(.top, 16)
                        .lineLimit(nil)
                        .padding(.trailing, 0)
                    PasswordField(hintText: "Pre-Approval Security Code", password: $preApprovalCode)
                    LoadingButtonView($loading, width: gr.size.width - 32, height: 60, buttonText: "Submit") {
                        if checkPasswordsMatch() {
                            let valResult = validateFields()
                            if !valResult.hasError {
                                self.loading = true
                                let playerCreate = PlayerCreateModel(username: emailAddress, fullName: fullName, startDate: Date().yyyyMMddFormatted, experience: "0", freeTier1Skills: "0", prestigePoints: "0", isCheckedIn: "FALSE", isCheckedInAsNpc: "FALSE", lastCheckIn: "", numEventsAttended: "0", numNpcEventsAttended: "0", isAdmin: "FALSE", password: password)

                                PlayerService.createPlayer(preApprovalCode, player: playerCreate) { player in
                                    PlayerManager.shared.setPlayer(player)
                                    UserAndPassManager.shared.setTemp(emailAddress, p: password)
                                    DataManager.forceReset()
                                    AlertManager.shared.showOkAlert("Account Created!") {
                                        runOnMainThread {
                                            self.loading = false
                                            self.mode.wrappedValue.dismiss()
                                        }
                                    }
                                } failureCase: { _ in
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

                    Text("If you don't have a Pre-Approval code but would like to join Still Alive Larp, please use the Contact button below")
                    .padding(.top, 16)
                    .padding(.trailing, 0)
                    NavigationLink(destination: ContactView()) {
                        Text("Contact Us")
                            .frame(width: gr.size.width, height: 60)
                            .background(Color.midRed)
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .tint(.midRed)
                            .controlSize(.large)
                    }
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
            ValidationGroup(text: fullName, validationType: .fullName),
            ValidationGroup(text: emailAddress, validationType: .email),
            ValidationGroup(text: password, validationType: .password),
            ValidationGroup(text: preApprovalCode, validationType: .securityCode)])
    }

    private func checkPasswordsMatch() -> Bool {
        return password == confirmPassword
    }

}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
