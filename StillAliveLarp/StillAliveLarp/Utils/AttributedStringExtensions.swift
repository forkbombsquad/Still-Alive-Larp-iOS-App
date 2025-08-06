//
//  AttributedStringExtensions.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/6/25.
//

import SwiftUI

extension NSAttributedString {
    convenience init?(htmlString: String) {
        guard let data = htmlString.data(using: .utf8) else { return nil }
        try? self.init(data: data,
                       options: [.documentType: NSAttributedString.DocumentType.html,
                                 .characterEncoding: String.Encoding.utf8.rawValue],
                       documentAttributes: nil)
    }
}
