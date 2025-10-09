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
                                        // TODO View character View
                                    case .selectSkillForXpReduction:
                                        // TODO select Skill For Xp Reduction View
                                        EmptyView()
                                    case .awardCharacter:
                                        // TODO award char view
                                        EmptyView()
                                    case .viewGear:
                                        // TODO view gear
                                        EmptyView()
                                    case .manageGear:
                                        // TODO manage gear
                                        EmptyView()
                                    case .approveBio:
                                        // TODO approve bio
                                        EmptyView()
                                    case .deleteSkills:
                                        // TODO delete skills
                                        EmptyView()
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
