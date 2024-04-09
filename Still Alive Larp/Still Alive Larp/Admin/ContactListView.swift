//
//  ContactListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct ContactListView: View {
    @ObservedObject private var _dm = DataManager.shared

    @Binding var contactRequests: [ContactRequestModel]

    var body: some View {
        VStack {
            ScrollView {
                GeometryReader { gr in
                    VStack {
                        Text("Contact Requests")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)

                        ForEach($contactRequests) { $contact in
                            NavArrowView(title: "\(contact.fullName)\(contact.read.boolValueDefaultFalse ? "" : " *")") { _ in
                                ContactDetailsView(contactRequest: $contact)
                            }.navigationViewStyle(.stack)
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}
