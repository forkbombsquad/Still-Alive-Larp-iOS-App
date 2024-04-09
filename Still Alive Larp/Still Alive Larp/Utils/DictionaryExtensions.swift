//
//  DictionaryExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import Foundation

extension Dictionary where Key == String, Value == String {

    mutating func addInPlace(_ key: String, value: String) {
        self[key] = value
    }

    mutating func addInPlace(_ newDict: [String : String]) {
        for (key, value) in newDict {
            self[key] = value
        }
    }

}
