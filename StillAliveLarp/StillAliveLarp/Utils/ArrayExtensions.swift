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
    
    func sumOf<T: Numeric>(_ transform: (Element) -> T) -> T {
        return map(transform).reduce(0, +)
    }
    
    func indexIsInBounds(_ index: Int) -> Bool {
        return index >= 0 && index < self.count
    }
    
}

extension Array where Element: Equatable {
    func doesNotContain(_ element: Element) -> Bool {
        return !self.contains(element)
    }
    
    func doesNotContainAnyOf(_ elements: [Element]) -> Bool {
        for e in elements {
            if (self.contains(e)) {
                return false
            }
        }
        return true
    }
}


extension Array where Element == PlayerModel {

    var alphabetized: [PlayerModel] {
        return self.sorted { $0.fullName < $1.fullName }
    }

}

extension Array where Element == FullPlayerModel {

    var alphabetized: [FullPlayerModel] {
        return self.sorted { $0.fullName < $1.fullName }
    }

}

extension Array where Element == FullCharacterModel {

    var alphabetized: [FullCharacterModel] {
        return self.sorted { $0.fullName < $1.fullName }
    }

}

extension Array where Element == FullCharacterModifiedSkillModel {

    var alphabetized: [FullCharacterModifiedSkillModel] {
        return self.sorted { $0.name < $1.name }
    }

}

extension Array where Element == CharacterModel {

    var alphabetized: [CharacterModel] {
        return self.sorted { $0.fullName < $1.fullName }
    }

}

extension Array where Element == EventPreregModel {

    func getRegNumbers() -> PreregNumbers {
        var p = 0
        var pn = 0
        var b = 0
        var bn = 0
        var f = 0
        var na = 0
        for prereg in self {
            let isNpc = prereg.getCharId() == nil
            switch prereg.eventRegType {
            case .notPrereged:
                na += 1
            case .free:
                f += 1
            case .basic:
                b += 1
                bn += isNpc ? 1 : 0
            case .premium:
                p += 1
                pn += isNpc ? 1 : 0
            }
        }
        return PreregNumbers(premium: p, premiumNpc: pn, basic: b, basicNpc: bn, free: f, notAttending: na)
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
