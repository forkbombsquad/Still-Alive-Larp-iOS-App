//
//  ViewCharacterView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/8/25.
//

import SwiftUI

struct ViewCharacterView: View {
    
    private enum ViewCharacterViewShowType: CaseIterable {
        case playerName, stats, skillsTree, skillsList, bio, gear, xpReductions, awards
    }
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var character: FullCharacterModel?
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        if let character = character {
                            let show = calculateShouldShow()
                            globalCreateTitleView("\(character.fullName)\n\(character.getPostText())", DM: DM)
                            Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                            if show[.playerName]! {
                                Text("\(DM.getPlayerForCharacter(character).fullName)").padding(8)
                                Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                            }
                            if show[.stats]! {
                                NavArrowView(title: "View Stats") { _ in
                                    // TODO View Character Stats View
                                    EmptyView()
                                }
                            }
                            if show[.skillsTree]! {
                                NavArrowView(title: "View Skills (Tree)") { _ in
                                    switch character.characterType() {
                                    case .standard, .hidden:
                                        if DM.playerIsCurrentPlayer(character.playerId) && character.isAlive {
                                            NativeSkillTree.initAsPersonal(currentPlayer: DM.getPlayerForCharacter(character), character: character, isInOfflineMode: DM.offlineMode)
                                        } else {
                                            NativeSkillTree.initAsOtherPlayerPersonal(currentPlayer: DM.getCurrentPlayer()!, character: character)
                                        }
                                    case .npc:
                                        NativeSkillTree.initAsNPCPersonal(currentPlayer: DM.getCurrentPlayer()!, npc: character)
                                    case .planner:
                                        if DM.playerIsCurrentPlayer(character.playerId) {
                                            NativeSkillTree.initAsPlannedPersonal(currentPlayer: DM.getCurrentPlayer()!, plannedCharacter: character, isInOfflineMode: DM.offlineMode)
                                        } else {
                                            NativeSkillTree.initAsOtherPlayerPersonal(currentPlayer: DM.getCurrentPlayer()!, character: character)
                                        }
                                    }
                                }
                            }
                            if show[.skillsList]! {
                                NavArrowView(title: "View Skills (List)") {
                                    _ in
                                    SkillsListView(character: $character, allowDelete: character.characterType() == .planner && DM.playerIsCurrentPlayer(character.playerId))
                                }
                            }
                            if show[.bio]! {
                                NavArrowView(title: "View Bio") {
                                    _ in
                                    // TODO View Bio View
                                    EmptyView()
                                }
                            }
                            if show[.gear]! {
                                NavArrowView(title: "View Bio") {
                                    _ in
                                    // TODO View Gear View
                                    EmptyView()
                                }
                            }
                            if show[.xpReductions]! {
                                NavArrowView(title: "View Xp Reductions") {
                                    _ in
                                    // TODO View Xp Reductions View
                                    EmptyView()
                                }
                            }
                            if show[.awards]! {
                                NavArrowView(title: "View Awards") {
                                    _ in
                                    ViewAwardsView(player: DM.getPlayerForCharacter(character), awards: character.awards)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
    
    private func calculateShouldShow() -> [ViewCharacterViewShowType : Bool] {
        guard let character = character else { return [:] }
        let charIsStandard = character.characterType() == .standard
        let charIsPlanner = character.characterType() == .planner
        let bioApproved = character.approvedBio
        let playerIsCurrentPlayer = DM.playerIsCurrentPlayer(character.playerId)
        
        var shouldShow = [ViewCharacterViewShowType : Bool]()
        ViewCharacterViewShowType.allCases.forEach { showType in
            switch showType {
            case .playerName:
                shouldShow[showType] = charIsStandard
            case .stats:
                shouldShow[showType] = true
            case .skillsTree:
                shouldShow[showType] = true
            case .skillsList:
                shouldShow[showType] = true
            case .bio:
                shouldShow[showType] = !charIsPlanner && (bioApproved || playerIsCurrentPlayer)
            case .gear:
                shouldShow[showType] = charIsStandard
            case .xpReductions:
                shouldShow[showType] = charIsStandard
            case .awards:
                shouldShow[showType] = charIsStandard
            }
        }
        return shouldShow
    }
    
}
