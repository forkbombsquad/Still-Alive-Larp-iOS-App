//
//  BoolExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/7/25.
//

import Foundation

extension Bool {
    var stringValue: String {
        switch self {
            case true: return "TRUE"
            case false: return "FALSE"
        }
    }
}
