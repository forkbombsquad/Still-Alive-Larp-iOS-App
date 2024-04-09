//
//  DataExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import Foundation

extension Data {

    func toJsonObject<T:Decodable>() -> T? {
        return try? JSONDecoder().decode(T.self, from: self)
    }

}
