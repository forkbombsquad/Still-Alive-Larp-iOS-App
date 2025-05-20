//
//  CodeableExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import Foundation

protocol CustomCodeable: Codable { }

extension CustomCodeable {

    func toData() -> Data? {
        return try? JSONEncoder().encode(self)
    }

    func toJsonString() -> String? {
        guard let data = self.toData() else { return nil }
        return String(data: data, encoding: .utf8)
    }

}
