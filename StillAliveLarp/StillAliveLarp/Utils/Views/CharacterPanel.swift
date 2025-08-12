//
//  CharacterPanel.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/4/25.
//

import SwiftUI

struct CharacterPanel: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let fromAccount: Bool
    let player: FullPlayerModel
    let character: FullCharacterModel?
    
    var body: some View {
        VStack {
            let show = calculateShouldShow()
            if show[.charTitle]! {
                Text("\(character?.fullName ?? "") \(getActiveText())")
                    .font(.system(size: 24, weight: .bold))
                    .frame(alignment: .leading)
                    .padding(.top, 24)
            }
            if show[.stats]! {
                NavArrowView(title: "View Character Stats") { _ in
                    // TODO
                }
            }
            if show[.skillTree]! {
                NavArrowView(title: "\(fromAccount ? "Manage Skills (Tree)" : "Manage Skills (Tree)")") { _ in
                    if fromAccount {
                        NativeSkillTree.initAsPersonal(currentPlayer: player, character: character!, isInOfflineMode: DM.offlineMode)
                    } else {
                        NativeSkillTree.initAsOtherPlayerPersonal(currentPlayer: player, character: character!)
                    }
                }
            }
            if show[.skillList]! {
                NavArrowView(title: "\(fromAccount ? "Manage Skills (List)" : "Manage Skills (List)")") { _ in
                    // TODO
                }
            }
            if show[.bio]! {
                NavArrowView(title: "View Bio") { _ in
                    // TODO
                }
            }
            if show[.gear]! {
                NavArrowView(title: "View Gear") { _ in
                    // TODO
                }
            }
            if show[.xpReductions]! {
                NavArrowView(title: "View Xp Reductions") { _ in
                    // TODO
                }
            }
            if show[.awards]! {
                NavArrowView(title: "View Character Awards") { _ in
                    // TODO
                }
            }
            if show[.otherCharacters]! {
                Text("Other Characters")
                    .font(.system(size: 24, weight: .bold))
                    .frame(alignment: .leading)
                    .padding(.top, 24)
            }
            if show[.inactive]! {
                NavArrowView(title: "View Inactive Characters") { _ in
                    // TODO
                }
            }
            if show[.planned]! {
                NavArrowView(title: "\(fromAccount ? "Character Planner" : "View Planned Characters")") { _ in
                    // TODO
                }
            }
        }
    }
    
    private func getActiveText() -> String {
        switch character?.characterType() ?? .standard {
        case .standard:
            return (character?.isAlive ?? false) ? "\n(Active Character)" : "\n(Inactive Character)"
        case .npc:
            return "\n(NPC\((character?.isAlive ?? false) ? "" : " - Dead"))"
        case .planner:
            return "\n(Planned Character)"
        case .hidden:
            return "\n(Hidden Character)"
        }
    }
    
    private func calculateShouldShow() -> [CharacterPanelShowType : Bool] {
        let charExists = character != nil
        let isOwnedByPlayer = player.id == DM.getCurrentPlayer()?.id
        let charIsStandard = character?.characterType() == .standard
        let charType = character?.characterType() ?? .hidden
        let bioApproved = character?.approvedBio ?? false
        let charIsAlive = character?.isAlive ?? false
        let hasInactiveChars = player.getInactiveCharacters().isNotEmpty
        let hasPlannedChars = player.getPlannedCharacters().isNotEmpty
        
        var shouldShow = [CharacterPanelShowType : Bool]()
        CharacterPanelShowType.allCases.forEach { showType in
            switch showType {
            case .charTitle:
                shouldShow[showType] = charExists
            case .stats:
                shouldShow[showType] = charExists
            case .skillTree:
                shouldShow[showType] = charExists
            case .skillList:
                shouldShow[showType] = charExists
            case .bio:
                shouldShow[showType] = charExists && ((charIsStandard && bioApproved) || isOwnedByPlayer || charType == .npc)
            case .gear:
                shouldShow[showType] = charExists
            case .xpReductions:
                shouldShow[showType] = charExists && charIsStandard
            case .awards:
                shouldShow[showType] = charExists
            case .otherCharacters:
                shouldShow[showType] = ((charExists && charIsStandard && charIsAlive) || !charExists) && (hasInactiveChars || hasPlannedChars)
            case .inactive:
                shouldShow[showType] = hasInactiveChars && ((charExists && charIsStandard && charIsAlive) || !charExists)
            case .planned:
                shouldShow[showType] = hasPlannedChars && ((charExists && charIsStandard && charIsAlive) || !charExists)
            }
        }
        return shouldShow
    }
    
    private enum CharacterPanelShowType: CaseIterable {
        case charTitle, stats, skillTree, skillList, bio, gear, xpReductions, awards, otherCharacters, inactive, planned
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let mockData = getMockData()
    return CharacterPanel(fromAccount: true, player: mockData.fullPlayers().first!, character: mockData.fullCharacters().first!)
}
