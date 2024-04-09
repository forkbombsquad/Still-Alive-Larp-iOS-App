//
//  IncrementalIndexManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/31/23.
//

import Foundation

class IncrementalIndexManager {

    static let shared = IncrementalIndexManager()

    private var index = -1

    private init() {}

    func getNextIndex() -> Int {
        index += 1
        return index - 1
    }

}
