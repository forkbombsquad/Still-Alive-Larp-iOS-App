//
//  ViewNPCStuffView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/14/25.
//

import SwiftUI

struct ViewNPCStuffView: View {
    
    @ObservedObject var _dm = DataManager.shared
    
    let offline: Bool
    let characterModel: CharacterModel
    @State var fullModel: FullCharacterModel? = nil
    @State var loadingFullModel: Bool = false
    
    init(_dm: DataManager = DataManager.shared, characterModel: CharacterModel) {
        self._dm = _dm
        self.offline = false
        self.characterModel = characterModel
    }
    
    init(_dm: DataManager = DataManager.shared, offlineCharacterModel: FullCharacterModel) {
        self._dm = _dm
        self.offline = false
        self.characterModel = offlineCharacterModel.baseModel
        self.fullModel = offlineCharacterModel
    }
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text(characterModel.fullName)
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        if loadingFullModel {
                            Spacer()
                            ProgressView().controlSize(.large)
                            Spacer()
                        } else if let char = fullModel {
                            Divider().padding(.horizontal, 16)
                            KeyValueView(key: "Infection Rating", value: "\(char.infection)%", showDivider: false).padding(.top, 8)
                            KeyValueView(key: "Bullets", value: "\(char.bullets)%")
                            NavArrowView(title: "NPC Skills") { _ in
                                SkillManagementView(offline: offline)
                            }
                            NavArrowView(title: "NPC Bio") { _ in
                                BioView(allowEdit: false, offline: offline)
                            }
                        } else {
                            Text("Something went wrong...")
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            if offline {
                DataManager.shared.charForSelectedPlayer = fullModel
            } else {
                self.loadingFullModel = true
                if DataManager.shared.charForSelectedPlayer?.id == characterModel.id {
                    self.loadingFullModel = false
                } else {
                    CharacterManager.shared.fetchFullCharacter(characterId: characterModel.id) { fcm in
                        runOnMainThread {
                            if let fcm = fcm {
                                self.fullModel = fcm
                                DataManager.shared.selectedPlayer = DataManager.shared.player
                                DataManager.shared.charForSelectedPlayer = fcm
                            }
                            self.loadingFullModel = false
                        }
                    }
                }
            }
            DataManager.shared.load([])
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return ViewNPCStuffView(_dm: dm, characterModel: md.character())
}
