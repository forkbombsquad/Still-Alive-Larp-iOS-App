//
//  ArrayExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/22/23.
//

import Foundation

extension Array {
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
}

extension Array where Element == PlayerModel {

    var alphabetized: [PlayerModel] {
        return self.sorted { $0.fullName < $1.fullName }
    }

}

extension Array where Element == FullCharacterModel {

    var alphabetized: [FullCharacterModel] {
        return self.sorted { $0.fullName < $1.fullName }
    }

}

extension Array where Element == CharacterModel {

    var alphabetized: [CharacterModel] {
        return self.sorted { $0.fullName < $1.fullName }
    }

}


extension Array where Element == EventModel {

    var inChronologicalOrder: [EventModel] {
        return self.sorted { $0.date.yyyyMMddtoDate() < $1.date.yyyyMMddtoDate() }.filter({ $0.isToday() || $0.isInFuture() })
    }

}

extension Optional where Wrapped: Collection {
    var isNullOrEmpty: Bool {
        guard let self = self else { return true }
        return self.isEmpty
    }
    
    var isNotNullOrEmpty: Bool {
        return !isNullOrEmpty
    }
}
