//
//  ViewPlayerStuffView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct ViewPlayerStuffView: View {
    @ObservedObject var _dm = DataManager.shared

    private let playerModel: PlayerModel
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "blank-profile")
    
    @State var character: OldFullCharacterModel? = nil
    @State var loadingCharacter: Bool = true
    @State var loadingProfileImage: Bool = true
    
    @State var firstLoad: Bool = true
    @State var skills: [OldFullSkillModel] = []
    @State var loadingSkills: Bool = false
    @State var skillCategories: [SkillCategoryModel] = []

    init(player: PlayerModel) {
        self.playerModel = player
    }

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text(playerModel.fullName)
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .padding(.bottom, 8)
                            if loadingProfileImage {
                                ProgressView()
                                .tint(.red)
                                .controlSize(.large)
                                .padding(.top, 80)
                            }
                        }
                        NavArrowView(title: "Player Stats") { _ in
                            PlayerStatsView(player: playerModel)
                        }
                        if loadingCharacter || character != nil {
                            NavArrowView(title: "Character Stats", loading: $loadingCharacter) { _ in
                                CharacterStatusView()
                            }
                            NavArrowView(title: "Skills", loading: $loadingCharacter) { _ in
                                if let char = self.character {
                                    SkillManagementView(character: char, allowEdit: false)
                                }
                            }
                            if let character = character {
                                NavArrowView(title: "Skill Tree Diagram", loading: $loadingCharacter) { _ in
                                    NativeSkillTree(skillGrid: SkillGrid(skills: skills, skillCategories: skillCategories, personal: true, allowPurchase: false), character: character)
                                }
                                NavArrowView(title: "Bio", loading: $loadingCharacter) { _ in
                                    BioView(allowEdit: false)
                                }
                                // TODO
//                                NavArrowView(title: "Gear", loading: $loadingCharacter) { _ in
//                                    GearView(character: character.baseModel, allowEdit: false)
//                                }
                            } else {
                                NavArrowView(title: "Gear", loading: $loadingCharacter) { _ in }
                            }
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            if firstLoad {
                self.firstLoad = false
                self.loadingCharacter = true
                self.loadingProfileImage = true
                self.loadingSkills = true
                CharacterManager.shared.getActiveCharacterForOtherPlayer(playerModel.id) { character in
                    runOnMainThread {
                        self.character = character
                        OldDataManager.shared.load([.skills, .skillCategories]) {
                            runOnMainThread {
                                self.skills = OldDataManager.shared.skills ?? []
                                self.skillCategories = OldDataManager.shared.skillCategories
                                self.loadingSkills = false
                                self.loadingCharacter = false
                            }
                        }
                        OldDataManager.shared.selectedPlayer = playerModel
                        OldDataManager.shared.charForSelectedPlayer = character
                        OldDataManager.shared.load([.profileImage]) {
                            runOnMainThread {
                                self.image = OldDataManager.shared.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                                self.loadingProfileImage = false
                            }
                        }
                    }
                } failureCase: { error in
                    runOnMainThread {
                        self.character = nil
                        self.loadingCharacter = false
                        self.loadingSkills = false
                        OldDataManager.shared.selectedPlayer = playerModel
                        OldDataManager.shared.load([.profileImage]) {
                            runOnMainThread {
                                self.image = OldDataManager.shared.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                                self.loadingProfileImage = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.charForSelectedPlayer = md.fullCharacters().first!
    var vps = ViewPlayerStuffView(player: md.player())
    vps._dm = dm
    return vps
}
