//
//  OfflineAccountView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/21/23.
//

import SwiftUI

struct OfflineAccountView: View {
    
    init() {
        self.player = OldLocalDataHandler.shared.getPlayer()
        self.character = OldLocalDataHandler.shared.getCharacter()
        self.skills = SkillManager.shared.getSkillsOffline()
        self.gear = OldLocalDataHandler.shared.getGear()?.first
        self.npcs = OldLocalDataHandler.shared.getNPCs() ?? []
        self.rulebook = RulebookManager.shared.getOfflineVersion()
        self.skillCategories = OldLocalDataHandler.shared.getSkillCategories() ?? []
        self.treatingWoundsDiagram = OldLocalDataHandler.shared.getImage(.treatingWounds)
    }
    
    init(_ player: PlayerModel?, _ character: FullCharacterModel?, _ skills: [FullSkillModel], _ gear: GearModel?, _ npcs: [FullCharacterModel], _ rulebook: Rulebook?, _ skillCategories: [SkillCategoryModel], _ treatingWoundsDiagram: UIImage?) {
        self.player = player
        self.character = character
        self.skills = skills
        self.gear = gear
        self.npcs = npcs
        self.rulebook = rulebook
        self.skillCategories = skillCategories
        self.treatingWoundsDiagram = treatingWoundsDiagram
    }

    let player: PlayerModel?
    let character: FullCharacterModel?
    let skills: [FullSkillModel]
    let gear: GearModel?
    let npcs: [FullCharacterModel]
    let rulebook: Rulebook?
    let skillCategories: [SkillCategoryModel]
    let treatingWoundsDiagram: UIImage?

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Offline Mode")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        if let player = player {
                            Text("Personal")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            NavArrowView(title: "Player Stats") { _ in
                                PlayerStatsView.Offline(player: player)
                            }
                            if let character = character {
                                NavArrowView(title: "Character Stats") { _ in
                                    CharacterStatusView.Offline(character: character)
                                }
                                NavArrowView(title: "Character Skills") { _ in
                                    SkillManagementView.Offline(character: character)
                                }
                                NavArrowView(title: "Personal Skill Tree Diagram") { _ in
                                    NativeSkillTree(skillGrid: SkillGrid(skills: skills, skillCategories: skillCategories, personal: true, allowPurchase: false), character: character)
                                }
                                NavArrowView(title: "Character Bio") { _ in
                                    BioView.Offline(character: character)
                                }
                                if let gear = gear {
                                    NavArrowView(title: "Character Gear") { _ in
                                        GearView.Offline(character, gear: gear)
                                    }
                                }
                                
                            }

                        }
                        Text("Global")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        NavArrowView(title: "All NPCs") { _ in
                            AllNpcsListView.Offline(npcs: npcs, skills: skills)
                        }
                        NavArrowView(title: "All Skills") { _ in
                            SkillListView(skills: skills)
                        }
                        NavArrowView(title: "Skill Tree Diagram") { _ in
                            NativeSkillTree(skillGrid: SkillGrid(skills: skills, skillCategories: skillCategories, personal: false, allowPurchase: false))
                        }
                        if let rulebook = rulebook {
                            NavArrowView(title: "Rulebook") { _ in
                                ViewRulesView(rulebook: rulebook)
                            }
                        }
                        if let image = treatingWoundsDiagram {
                            NavArrowView(title: "Treating Wounds Diagram") { _ in
                                DownloadedImageView(image: image)
                            }
                        }
                        
                        if FeatureFlag.oldSkillTreeImage.isActive() {
                            NavArrowView(title: "Skill Tree Diagram Image (Legacy)") { _ in
                                if let image = OldLocalDataHandler.shared.getImage(.skillTree) {
                                    DownloadedImageView(image: image)
                                }
                            }
                            NavArrowView(title: "Dark Skill Tree Diagram Image (Legacy)") { _ in
                                if let image = OldLocalDataHandler.shared.getImage(.skillTreeDark) {
                                    DownloadedImageView(image: image)
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

#Preview {
    let md = getMockData()
    OfflineAccountView(md.player(), md.fullCharacters().first!, md.fullSkills(), md.gear(), md.fullCharacters(), md.rulebook, md.skillCategories.results, nil)
}
