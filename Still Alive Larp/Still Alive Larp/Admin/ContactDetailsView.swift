//
//  ContactDetailsView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct ContactDetailsView: View {
    @ObservedObject var _dm = DataManager.shared

    @Binding var contactRequest: ContactRequestModel
    @State var loading = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                VStack {
                    Text("Contact Request")
                        .font(.system(size: 32, weight: .bold))
                        .frame(alignment: .center)
                        .padding(.trailing, 0)
                    ScrollView(.vertical) {
                        KeyValueView(key: "Name", value: contactRequest.fullName, allowCopy: true)
                        KeyValueView(key: "Email", value: contactRequest.emailAddress, allowCopy: true)
                        KeyValueView(key: "Postal Code", value: contactRequest.postalCode, allowCopy: true)
                        Text(contactRequest.message)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 100)
                            .padding(.trailing, 0)
                    }
                    .padding(.trailing, 0)
                    Divider()
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Mark as \(self.contactRequest.read.boolValueDefaultFalse ? "Unread" : "Read")") {
                        self.loading = true
                        self.contactRequest.read = self.contactRequest.read.boolValueDefaultFalse ? "FALSE" : "TRUE"
                        AdminService.updateContactRequest(self.contactRequest) { updatedContactRequest in
                            runOnMainThread {
                                self.contactRequest = contactRequest
                                self.loading = false
                                AlertManager.shared.showOkAlert("Contact Request Updated") {
                                    runOnMainThread {
                                        self.mode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        } failureCase: { error in
                            self.loading = false
                        }
                    }
                    .padding(.trailing, 0)
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }

}
