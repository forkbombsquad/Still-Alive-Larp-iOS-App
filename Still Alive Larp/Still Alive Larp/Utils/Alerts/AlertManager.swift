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
