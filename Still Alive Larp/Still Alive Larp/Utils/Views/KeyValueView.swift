//
//  KeyValueView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 1/6/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct KeyValueView: View {
    @ObservedObject private var _dm = DataManager.shared

    var key: String
    var value: String
    var showDivider: Bool = true
    var allowCopy: Bool = false

    var body: some View {
        if allowCopy {
            VStack {
                HStack {
                    Text(key)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text(value)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 20))
                }
                if showDivider {
                    Divider()
                }
            }.onLongPressGesture {
                runOnMainThread {
                    UIPasteboard.general.setValue(self.value, forPasteboardType: UTType.plainText.identifier)
                    AlertManager.shared.showOkAlert("Copied to clipboard:", message: self.value) { }
                }
            }
        } else {
            VStack {
                HStack {
                    Text(key)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text(value)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 20))
                }
                if showDivider {
                    Divider()
                }
            }
        }
    }
}

struct KeyValueView_Previews: PreviewProvider {
    static var previews: some View {
        KeyValueView(key: "Key Example", value: "Value Example")
    }
}
