//
//  CharactersListView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/8/25.
//

import SwiftUI

struct CharactersListView: View {
    
    enum CharactersListViewDestination {
        case viewCharacter, selectSkillForXpReduction, awardCharacter, viewGear, manageGear, approveBio, deleteSkills
    }
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let title: String
    let destination: CharactersListViewDestination
    let characters: [FullCharacterModel]
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        globalCreateTitleView(title, DM: DM)
                        LazyVStack(spacing: 8) {
                            ForEach(characters.alphabetized) { character in
                                let player = DM.getPlayerForCharacter(character)
                                NavArrowView(title: "\(character.fullName) - \(player.fullName)") { _ in
                                    switch destination {
                                    case .viewCharacter:
                                        ViewCharacterView(character: character)
                                    case .selectSkillForXpReduction:
                                        SelectSkillForClassXpReducitonView(character: character)
                                    case .awardCharacter:
                                        AwardCharacterView(character: character)
                                    case .viewGear, .manageGear:
                                        GearView(character: character)
                                    case .approveBio:
                                        ApproveBioView(character: .constant(character))
                                    case .deleteSkills:
                                        if character.characterType() == .planner {
                                            DeleteSkillsView(character: .constant(character), mode: .justDelete)
                                        } else if character.isAlive && DM.getCurrentPlayer()?.isAdmin ?? false {
                                            DeleteSkillsView(character: .constant(character), mode: .refund)
                                        }
                                    }
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
}
