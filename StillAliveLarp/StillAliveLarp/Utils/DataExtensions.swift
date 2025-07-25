//
//  DataExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import Foundation

extension Data {
    
    func decompress() -> Data? {
        guard let decompressedData = try? self.gunzipped() else {
            return nil
        }
        return decompressedData
    }
    
    func toJsonObject<T: Decodable>() -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            globalTestPrint("❌ Decoding error: \(error)")
            return nil
        }
    }
    
    func toJsonObject<T: Decodable>(as type: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            globalTestPrint("❌ Decoding error: \(error)")
            return nil
        }
    }

}
