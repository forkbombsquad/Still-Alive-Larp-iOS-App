//
//  DataExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import Foundation

extension Data {
    
    func toJsonObject<T: Decodable>() -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            globalTestPrint("❌ Decoding error: \(error)")
            return nil
        }
    }


}
