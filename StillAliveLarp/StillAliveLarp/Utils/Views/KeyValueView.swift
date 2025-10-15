//
//  KeyValueView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 1/6/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct KeyValueView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    init(key: String, value: String, showDivider: Bool = true, allowCopy: Bool = false) {
        self.key = key
        self.value = value
        self.showDivider = showDivider
        self.allowCopy = allowCopy
    }
    
    init(key: String, value: Bool, showDivider: Bool = true, allowCopy: Bool = false) {
        self.key = key
        self.value = value.stringValue
        self.showDivider = showDivider
        self.allowCopy = allowCopy
    }
    
    init(key: String, value: Int, showDivider: Bool = true, allowCopy: Bool = false) {
        self.key = key
        self.value = value.stringValue
        self.showDivider = showDivider
        self.allowCopy = allowCopy
    }

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
                    alertManager.showOkAlert("Copied to clipboard:", message: self.value) { }
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

#Preview {
    KeyValueView(key: "Key Example", value: "Value Example")
}
