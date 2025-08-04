//
//  ContactView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/17/22.
//

import SwiftUI

struct ContactView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State private var fullName: String = ""
    @State private var emailAddress: String = ""
    @State private var postalCode: String = ""
    @State private var message: String = ""
    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Still Alive Larp Contact")
                        .font(Font.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    Text("Still Alive is a Zombie Apocalypse LARP (Live Action Role Playing) game that takes place in North-Western Wisconsin (USA). If you live nearby, are over the age of 18, and are interested in playing, fill out the contact form below and we'll get back to you as soon as we can!\n\n-The Still Alive Team")
                        .padding(.top, 16)
                        .padding(.trailing, 0)
                    TextField("Full Name", text: $fullName)
                        .padding(.top, 8)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .padding(.trailing, 0)
                    TextField("Email Address", text: $emailAddress)
                        .padding(.top, 8)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding(.trailing, 0)
                    TextField("Postal Code", text: $postalCode)
                        .padding(.top, 8)
                        .textFieldStyle(.roundedBorder)
                        .padding(.trailing, 0)
                    TextEditor(text: $message)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 100)
                        .fixedSize(horizontal: false, vertical: true)
                        .placeholder(when: message.isEmpty) {
                            Text("Message").foregroundColor(.gray).padding().multilineTextAlignment(.center)
                        }
                    LoadingButtonView($loading, width: gr.size.width - 32, height: 60, buttonText: "Submit") {
                        let valResult = validateFields()
                        if !valResult.hasError {
                            self.loading = true
                            let contact = ContactRequestCreateModel(fullName: self.fullName, emailAddress: self.emailAddress, postalCode: self.postalCode, message: self.message, read: "FALSE")
                            ContactService.createContactRequest(contact, onSuccess: { _ in
                                runOnMainThread {
                                    self.loading = false
                                    AlertManager.shared.showOkAlert("Contact Request Sent") {
                                        runOnMainThread {
                                            self.mode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            }, failureCase: { _ in
                                self.loading = false
                            })

                        } else {
                            AlertManager.shared.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
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
            ValidationGroup(text: fullName, validationType: .fullName),
            ValidationGroup(text: emailAddress, validationType: .email),
            ValidationGroup(text: postalCode, validationType: .postalCode),
            ValidationGroup(text: message, validationType: .message)])
    }

}

#Preview {
    DataManager.shared.setDebugMode(true)
    return ContactView(_dm: dm)
}
