//
//  OfflineAccountView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/21/23.
//

import SwiftUI

struct OfflineAccountView: View {
    @ObservedObject var _dm = DataManager.shared

    @State private var loading = false

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Offline Mode")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        if loading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else if let player = DataManager.shared.selectedPlayer {
                            Text("Personal")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            NavArrowView(title: "Player Stats") { _ in
                                PlayerStatsView(offline: true, player: DataManager.shared.selectedPlayer)
                            }
                            if DataManager.shared.charForSelectedPlayer != nil {
                                NavArrowView(title: "Character Stats") { _ in
                                    CharacterStatusView(offline: true)
                                }
                                NavArrowView(title: "Character Skills") { _ in
                                    SkillManagementView(offline: true)
                                }
                                NavArrowView(title: "Personal Skill Tree Diagram") { _ in
                                    // TODO
                                }
                                NavArrowView(title: "Character Bio") { _ in
                                    BioView(allowEdit: false, offline: true)
                                }
                                NavArrowView(title: "Character Gear") { _ in
                                    GearView(character: DataManager.shared.charForSelectedPlayer!.baseModel, offline: true, allowEdit: false)
                                }
                            }

                        }
                        Text("Global")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        NavArrowView(title: "All Skills") { _ in
                            SkillListView(skills: SkillManager.shared.getSkillsOffline())
                        }
                        NavArrowView(title: "Skill Tree Diagram") { _ in
                            // TODO
                        }
                        if DataManager.shared.rulebook != nil {
                            NavArrowView(title: "Rulebook") { _ in
                                ViewRulesView(rulebook: DataManager.shared.rulebook)
                            }
                        }
                        NavArrowView(title: "Treating Wounds Diagram") { _ in
                            if let image = LocalDataHandler.shared.getImage(.treatingWounds) {
                                DownloadedImageView(image: image)
                            }
                        }
                        NavArrowView(title: "All NPCs") { _ in
                            AllNpcsListView(fullNpcModelsOffline: LocalDataHandler.shared.getNPCs() ?? [])
                        }
                        if FeatureFlag.oldSkillTreeImage.isActive() {
                            NavArrowView(title: "Skill Tree Diagram Image (Legacy)") { _ in
                                if let image = LocalDataHandler.shared.getImage(.skillTree) {
                                    DownloadedImageView(image: image)
                                }
                            }
                            NavArrowView(title: "Dark Skill Tree Diagram Image (Legacy)") { _ in
                                if let image = LocalDataHandler.shared.getImage(.skillTreeDark) {
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

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return OfflineAccountView(_dm: dm)
}
