//
//  OfflineAccountView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/21/23.
//

import SwiftUI

struct OfflineAccountView: View {
    @ObservedObject private var _dm = DataManager.shared

    @State private var loading = false

    var body: some View {
        VStack {
            ScrollView {
                GeometryReader { gr in
                    VStack {
                        Text("My Account (Offline)")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        if loading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else if let player = DataManager.shared.selectedPlayer {
                            Text(player.fullName)
                                .font(.system(size: 20))
                                .underline()
                                .frame(alignment: .center)
                            NavArrowView(title: "Player Stats") { _ in
                                PlayerStatsView(offline: true, player: DataManager.shared.selectedPlayer)
                            }
                            if DataManager.shared.charForSelectedPlayer != nil {
                                NavArrowView(title: "Character Stats") { _ in
                                    CharacterStatusAndGearView(offline: true)
                                }
                                NavArrowView(title: "Character Skills") { _ in
                                    SkillManagementView(offline: true)
                                }
                                NavArrowView(title: "Character Bio") { _ in
                                    BioView(allowEdit: false, offline: true)
                                }
                                NavArrowView(title: "Character Gear") { _ in
                                    GearView(offline: true)
                                }
                            }

                        }
                        Divider().background(Color.black).padding( 8)
                        NavArrowView(title: "All Skills") { _ in
                            SkillListView(skills: SkillManager.shared.getSkillsOffline())
                        }
                        if DataManager.shared.rulebook != nil {
                            NavArrowView(title: "View Rules") { _ in
                                ViewRulesView(rulebook: DataManager.shared.rulebook)
                            }
                        }
                        NavArrowView(title: "Skill Tree Diagram") { _ in
                            if let image = LocalDataHandler.shared.getImage(.skillTree) {
                                DownloadedImageView(image: image)
                            }
                        }
                        NavArrowView(title: "Skill Tree Diagram (Dark)") { _ in
                            if let image = LocalDataHandler.shared.getImage(.skillTreeDark) {
                                DownloadedImageView(image: image)
                            }
                        }
                        NavArrowView(title: "Treating Wounds Diagram") { _ in
                            if let image = LocalDataHandler.shared.getImage(.treatingWounds) {
                                DownloadedImageView(image: image)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.lightGray)
        .onAppear {
            loading = true
            runOnMainThread {
                DataManager.shared.loadLocalData()
                DataManager.shared.loadingSelectedCharacterGear = false
                DataManager.shared.loadingCharForSelectedPlayer = false
                DataManager.shared.loadingRulebook = false
                self.loading = false
                DataManager.shared.loadingSkills = false
            }
        }
    }
}
