//
//  ColorExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/17/22.
//

import Foundation
import SwiftUI

extension Color {

    static var lightGray: Color {
        Color("LightGray")
    }
    static var darkGray: Color {
        Color("DarkGray")
    }
    static var brightRed: Color {
        Color("BrightRed")
    }
    static var darkerBrightRed: Color {
        Color("DarkerBrightRed")
    }
    static var midRed: Color {
        Color("MidRed")
    }
    static var darkerMidRed: Color {
        Color("DarkerMidRed")
    }
    static var darkGreen: Color {
        Color("DarkGreen")
    }
    
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .whitespacesAndNewlines))
        var hexNumber: UInt64 = 0
        scanner.currentIndex = hex.hasPrefix("#") ? scanner.string.index(after: scanner.string.startIndex) : scanner.string.startIndex
        scanner.scanHexInt64(&hexNumber)

        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b)
    }
    
    init(hex: Int) {
            self.init(
                red: Double((hex >> 16) & 0xff) / 255.0,
                green: Double((hex >> 8) & 0xff) / 255.0,
                blue: Double(hex & 0xff) / 255.0
            )
        }

}

