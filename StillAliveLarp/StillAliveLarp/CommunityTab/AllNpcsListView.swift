//
//  AllNpcsListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/14/25.
//

import SwiftUI

struct AllNpcsListView: View {
    
    static func Offline(npcs: [OldFullCharacterModel], skills: [OldFullSkillModel]) -> AllNpcsListView {
        return AllNpcsListView(fullCharacterModels: npcs, skills: skills, allowEdit: false)
    }
    
    @ObservedObject var _dm = OldDataManager.shared
    
    let offline: Bool
    let allowEdit: Bool
    
    @State var npcs: [CharacterModel] = []
    @State var fullNpcModelsOffline: [OldFullCharacterModel] = []
    @State var offlineSkills: [OldFullSkillModel] = []
    
    private init(_dm: OldDataManager = OldDataManager.shared, fullCharacterModels: [OldFullCharacterModel], skills: [OldFullSkillModel], allowEdit: Bool) {
        self._dm = _dm
        self.offline = true
        self.allowEdit = allowEdit
        self._npcs = globalState(fullCharacterModels.map({ $0.baseModel }))
        self._fullNpcModelsOffline = globalState(fullCharacterModels)
        self._offlineSkills = globalState(skills)
        
    }
    
    init(_dm: OldDataManager = OldDataManager.shared, npcs: [CharacterModel], allowEdit: Bool) {
        self._dm = _dm
        self.offline = false
        self.allowEdit = allowEdit
        self._npcs = globalState(npcs)
    }
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("\(allowEdit ? "Manage" : "All") NPCs")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        Divider().padding(.horizontal, 16).padding(.bottom, 8)
                        let livingCount = npcs.filter({ $0.isAlive.boolValueDefaultFalse }).count
                        KeyValueView(key: "Total Living NPCs", value: "\(livingCount) / 10", showDivider: false)
                        KeyValueView(key: "Quest Rewards Reduced By", value: "\(100 - (10 * livingCount))%").padding(.top, 8)
                        LazyVStack(spacing: 8) {
                            ForEach(aliveNpcs()) { npc in
                                NavArrowView(title: npc.fullName) { _ in
                                    if self.allowEdit {
                                        ManageNPCView(npcs: $npcs, npc: npc)
                                    } else if self.offline {
                                        ViewNPCStuffView.Offline(characterModel: fullNpcModelsOffline.first(where: { $0.id == npc.id })!, skills: offlineSkills)
                                    } else {
                                        ViewNPCStuffView(characterModel: npc)
                                    }
                                }
                            }
                            ForEach(deadNpcs()) { npc in
                                NavArrowViewRed(title: "\(npc.fullName) (Dead)") {
                                    if self.allowEdit {
                                        ManageNPCView(npcs: $npcs, npc: npc)
                                    } else if self.offline {
                                        ViewNPCStuffView.Offline(characterModel: fullNpcModelsOffline.first(where: { $0.id == npc.id })!, skills: offlineSkills)
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
    
    func aliveNpcs() -> [CharacterModel] {
        return npcs.filter({ $0.isAlive.boolValueDefaultFalse }).sorted(by: { $0.fullName < $1.fullName })
    }
    
    func deadNpcs() -> [CharacterModel] {
        return npcs.filter({ !$0.isAlive.boolValueDefaultFalse }).sorted(by: { $0.fullName < $1.fullName })
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return AllNpcsListView(_dm: dm, npcs: md.characterListFullModel.characters, allowEdit: false)
}
