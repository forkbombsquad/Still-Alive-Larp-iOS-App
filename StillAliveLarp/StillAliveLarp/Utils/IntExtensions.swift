//
//  IntExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import Foundation

extension Int {

    var stringValue: String {
        return "\(self)"
    }
    
    var cgFloat: CGFloat {
        return CGFloat(self)
    }

    func equalsAnyOf(_ intArray: [Int]) -> Bool {
        for i in intArray {
            guard self == i else { continue }
            return true
        }
        return false
    }

    func addMinOne(_ value: Int) -> Int {
        let val = self + value
        return val > 0 ? val : 1
    }
    
    var pluralizeString: String {
        return self == 1 ? "" : "s"
    }

}
