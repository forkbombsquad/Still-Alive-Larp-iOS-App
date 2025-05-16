//
//  AlertManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/15/23.
//

import Foundation
import SwiftUI

// Global typealias
typealias AlertAction = (() -> Void)?

class AlertManager: ObservableObject {

    static let shared = AlertManager()

    private init() { }

    @Published var alert: Alert? {
        didSet {
            runOnMainThread {
                self.isShowingAlert = self.alert != nil
            }
        }
    }

    @Published var isShowingAlert = false
    
    @Published var isShowingCustomAlert = false
    @Published var customAlertModel: CustomAlertModel? = nil

    func showAlert(_ title: String, message: String? = nil, button1: Alert.Button, button2: Alert.Button? = nil) {
        runOnMainThread {
            if let button2 = button2 {
                self.alert = Alert(title: title.toTextView(), message: message?.toTextView(), primaryButton: button1, secondaryButton: button2)
            } else {
                self.alert = Alert(title: title.toTextView(), message: message?.toTextView(), dismissButton: button1)
            }
        }
    }

    func showOkAlert(_ title: String, message: String? = nil, onOkAction: AlertAction) {
        showAlert(title, message: message, button1: AlertConstants.Buttons.ok(onOkAction))
    }

    func showOkCancelAlert(_ title: String, message: String? = nil, onOkAction: AlertAction, onCancelAction: AlertAction = nil) {
        showAlert(title, message: message, button1: AlertConstants.Buttons.ok(onOkAction), button2: AlertConstants.Buttons.cancel(onCancelAction))
    }

    func showCustomOrCancelAlert(_ title: String, message: String? = nil, customButtonText: String, onCustomButtonPress: AlertAction, onCancelAction: AlertAction = nil) {
        showAlert(title, message: message, button1: Alert.Button.default(customButtonText.toTextView(), action: onCustomButtonPress ?? {}), button2: AlertConstants.Buttons.cancel(onCancelAction))
    }

    func showCustomNegativeOrCancelAlert(_ title: String, message: String? = nil, customButtonText: String, onCustomButtonPress: AlertAction, onCancelAction: AlertAction = nil) {
        showAlert(title, message: message, button1: Alert.Button.destructive(customButtonText.toTextView(), action: onCustomButtonPress ?? {}), button2: AlertConstants.Buttons.cancel(onCancelAction))
    }

    func showSuccessAlert(_ message: String, onOkAction: AlertAction) {
        showOkAlert("Success", message: message, onOkAction: onOkAction)
    }
    
    func showDynamicAlert(model: CustomAlertModel) {
        runOnMainThread {
            self.customAlertModel = model
            self.isShowingCustomAlert = true
        }
    }
    
    func dismissDynamicAlert() {
        func dismissDynamicAlert() {
            runOnMainThread {
                self.isShowingCustomAlert = false
                self.customAlertModel = nil
            }
        }
    }
}

struct AlertConstants {

    struct Buttons {

        static func ok(_ action: AlertAction) -> Alert.Button { Alert.Button.default(Texts.ok, action: action ?? {}) }

        static func cancel(_ action: AlertAction) -> Alert.Button { Alert.Button.default(Texts.cancel, action: action ?? {}) }

    }

    struct Texts {
        static let ok = Text("Ok")
        static let cancel = Text("Cancel")
    }

}

struct AlertTextField {
    var placeholder: String
    var value: Binding<String>
    var isMultiline: Bool = false
}

struct AlertToggle {
    var text: String
    var isOn: Binding<Bool>
}

struct AlertButton {
    var title: String
    var role: ButtonRole? = nil
    var onPress: () -> Void
    
    static func cancel(onPress: @escaping () -> Void) -> AlertButton {
        AlertButton(title: "Cancel", role: .cancel, onPress: onPress)
    }
}

struct CustomAlertModel {
    var title: String
    var message: String?
    var textFields: [AlertTextField]
    var checkboxes: [AlertToggle]
    var buttons: [AlertButton]
}

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    let model: CustomAlertModel

    var body: some View {
        VStack(spacing: 16) {
            Text(model.title)
                .font(.headline)
                .multilineTextAlignment(.center)

            if let message = model.message {
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }

            ForEach(0..<model.textFields.count, id: \.self) { index in
                let tf = model.textFields[index]
                if tf.isMultiline {
                    TextEditor(text: tf.value)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 250)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(Color.lightGray)
                } else {
                    TextField(model.textFields[index].placeholder, text: model.textFields[index].value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

            ForEach(0..<model.checkboxes.count, id: \.self) { index in
                Toggle(isOn: model.checkboxes[index].isOn) {
                    Text(model.checkboxes[index].text)
                }
            }

            HStack {
                ForEach(0..<model.buttons.count, id: \.self) { index in
                    let button = model.buttons[index]
                    Button(role: button.role) {
                        isPresented = false
                        button.onPress()
                    } label: {
                        Text(button.title)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}

struct CustomAlertContainerView<Content: View>: View {
    @ObservedObject var alertManager = AlertManager.shared
    let content: () -> Content

    var body: some View {
        ZStack {
            content()

            if alertManager.isShowingCustomAlert,
               let model = alertManager.customAlertModel {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)

                CustomAlertView(
                    isPresented: $alertManager.isShowingCustomAlert,
                    model: model
                )
                .onDisappear {
                    alertManager.customAlertModel = nil
                }
                .transition(.scale)
                .animation(.easeInOut, value: alertManager.isShowingCustomAlert)
            }
        }
    }
}

