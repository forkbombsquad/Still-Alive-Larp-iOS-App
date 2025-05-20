//
//  DateExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import Foundation

extension Date {

    var yyyyMMddFormatted: String {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        return format.string(from: self)
    }

}
