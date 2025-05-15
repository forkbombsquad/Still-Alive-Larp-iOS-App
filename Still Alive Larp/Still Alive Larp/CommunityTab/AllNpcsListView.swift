//
//  AllNpcsListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/14/25.
//

import SwiftUI

struct AllNpcsListView: View {
    
    // TODO offline mode is crashing. Might be an issue with the Offline Data Cacheing
    
    @ObservedObject var _dm = DataManager.shared
    
    let offline: Bool
    
    @State var npcs: [CharacterModel]
    @State var fullNpcModelsOffline: [FullCharacterModel] = []
    
    init(_dm: DataManager = DataManager.shared, fullNpcModelsOffline: [FullCharacterModel]) {
        self._dm = _dm
        self.offline = true
        self.npcs = fullNpcModelsOffline.map({ $0.baseModel })
        self.fullNpcModelsOffline = fullNpcModelsOffline
    }
    
    init(_dm: DataManager = DataManager.shared, npcs: [CharacterModel]) {
        self._dm = _dm
        self.offline = false
        self.npcs = npcs
        self.fullNpcModelsOffline = fullNpcModelsOffline
    }
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("All NPCs")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        Divider().padding(.horizontal, 16).padding(.bottom, 8)
                        let livingCount = npcs.filter({ $0.isAlive.boolValueDefaultFalse }).count
                        KeyValueView(key: "Total Living NPCs", value: "\(livingCount) / 10", showDivider: false)
                        KeyValueView(key: "Quest Rewards Reduced By", value: "\(100 - (10 * livingCount))%").padding(.top, 8)
                        LazyVStack(spacing: 8) {
                            ForEach(npcs.filter({ $0.isAlive.boolValueDefaultFalse }).sorted(by: { $0.fullName < $1.fullName })) { npc in
                                NavArrowView(title: npc.fullName) { _ in
                                    if self.offline {
                                        ViewNPCStuffView(offlineCharacterModel: fullNpcModelsOffline.first(where: { $0.id == npc.id })!)
                                    } else {
                                        ViewNPCStuffView(characterModel: npc)
                                    }
                                }
                            }
                            ForEach(npcs.filter({ !$0.isAlive.boolValueDefaultFalse }).sorted(by: { $0.fullName < $1.fullName })) { npc in
                                NavArrowViewRed(title: "\(npc.fullName) (Dead)") {
                                    if self.offline {
                                        ViewNPCStuffView(offlineCharacterModel: fullNpcModelsOffline.first(where: { $0.id == npc.id })!)
                                    } else {
                                        ViewNPCStuffView(characterModel: npc)
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

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return AllNpcsListView(_dm: dm, npcs: md.characterListFullModel.characters)
}
