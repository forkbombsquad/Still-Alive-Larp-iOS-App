//
//  PasswordField.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/18/22.
//

import SwiftUI

struct PasswordField: View {
    @ObservedObject private var _dm = DataManager.shared

    let hintText: String
    @State private var isSecured: Bool = true
    @Binding var password: String

    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(hintText, text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                        .padding(.top, 8)
                } else {
                    TextField(hintText, text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                        .padding(.top, 8)
                }
            }.padding(.trailing, 32)
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                        .padding(.top, 8)
                        .accentColor(.gray)
            }
        }
    }
}

struct PasswordField_Previews: PreviewProvider {

    @State static private var password: String = ""

    static var previews: some View {
       PasswordField(hintText: "Password", password: $password)
    }
}
