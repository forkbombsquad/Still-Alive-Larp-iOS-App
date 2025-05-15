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
    
    @State var character: FullCharacterModel? = nil
    @State var loadingCharacter: Bool = true
    @State var loadingProfileImage: Bool = true

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
                                SkillManagementView()
                            }
                            NavArrowView(title: "Skill Tree Diagram", loading: $loadingCharacter) { _ in
                                // TODO
                            }
                            NavArrowView(title: "Bio", loading: $loadingCharacter) { _ in
                                BioView(allowEdit: false)
                            }
                            if let character = character {
                                NavArrowView(title: "Gear", loading: $loadingCharacter) { _ in
                                    GearView(character: character.baseModel, offline: false, allowEdit: false)
                                }
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
            self.loadingCharacter = true
            self.loadingProfileImage = true
            DataManager.shared.selectedPlayer = self.playerModel
            DataManager.shared.load([.charForSelectedPlayer, .profileImage]) {
                runOnMainThread {
                    self.character = DataManager.shared.charForSelectedPlayer
                    self.image = DataManager.shared.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                    self.loadingProfileImage = false
                    self.loadingCharacter = false
                }
            }
            runOnMainThread {
                DataManager.shared.profileImage = nil
                DataManager.shared.load([.charForSelectedPlayer])
                DataManager.shared.load([.profileImage]) {
                    runOnMainThread {
                        self.image = DataManager.shared.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                    }
                }
            }
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.charForSelectedPlayer = md.fullCharacters().first!
    var vps = ViewPlayerStuffView(player: md.player())
    vps._dm = dm
    return vps
}
