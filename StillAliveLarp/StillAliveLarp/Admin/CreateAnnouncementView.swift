//
//  CreateAnnouncementView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct CreateAnnouncementView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State private var title: String = ""
    @State private var message: String = ""

    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Create Announcement")
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    TextField("", text: $title)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .placeholder(when: title.isEmpty) {
                            Text("Title").foregroundColor(.gray).padding().padding(.top, 4)
                        }
                    TextEditor(text: $message)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 250)
                        .fixedSize(horizontal: false, vertical: true)
                        .placeholder(when: message.isEmpty) {
                            Text("Message").foregroundColor(.gray).padding().multilineTextAlignment(.center)
                        }
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Submit") {
                        let valResult = validateFields()
                        if !valResult.hasError {
                            self.loading = true

                            let announcement = CreateAnnouncementModel(title: title, text: message, date: Date().yyyyMMddFormatted)

                            AdminService.createAnnouncement(announcement) { _ in
                                runOnMainThread {
                                    alertManager.showOkAlert("Announcement Created") {
                                        self.loading = false
                                        self.mode.wrappedValue.dismiss()
                                    }
                                }
                            } failureCase: { error in
                                self.loading = false
                            }
                        } else {
                            alertManager.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
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
            ValidationGroup(text: title, validationType: .announcementTitle), ValidationGroup(text: message, validationType: .announcementMessage)])
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    return CreateAnnouncementView()
}
