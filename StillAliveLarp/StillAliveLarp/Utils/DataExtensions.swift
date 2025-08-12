//
//  DataExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import Foundation

extension Data {
    
    func decompress() -> String? {
        guard let base64String = String(data: self, encoding: .utf8), let gzippedData = Data(base64Encoded: base64String), let uncompressedData = try? gzippedData.gunzipped() else {
            return nil
        }
        return String(data: uncompressedData, encoding: .utf8)
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
