//
//  ViewNPCStuffView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/14/25.
//

import SwiftUI

struct ViewNPCStuffView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var npc: FullCharacterModel?
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        if let npc = npc {
                            globalCreateTitleView("\(npc.fullName) (NPC\(npc.isAlive ? "" : " - Dead"))", DM: DM)
                            KeyValueView(key: "Times Played", value: DM.events.flatMap({ $0.attendees }).count(where: { $0.npcId == npc.id }).stringValue, showDivider: false).padding(.top, 16)
                            KeyValueView(key: "Infection Rating", value: "\(npc.infection)%", showDivider: false)
                            KeyValueView(key: "Bullets", value: "\(npc.bullets)")
                            if npc.mysteriousStrangerCount() > 0 {
                                KeyValueView(key: "Mysterious Stranger Uses Remaining", value: "\(npc.mysteriousStrangerCount() - npc.mysteriousStrangerUses) / \(npc.mysteriousStrangerCount())")
                            }
                            if npc.hasUnshakableResolve() {
                                KeyValueView(key: "Unshakable Resolve Uses Remaining", value: "\((npc.hasUnshakableResolve() ? 1 : 0) - npc.unshakableResolveUses) / \(npc.hasUnshakableResolve() ? 1 : 0)")
                            }
                            if let player = DM.getCurrentPlayer() {
                                NavArrowView(title: "View SKills (Tree)") { _ in
                                    NativeSkillTree.initAsNPCPersonal(currentPlayer: player, npc: npc)
                                }
                            }
                            NavArrowView(title: "View SKills (List)") { _ in
                                SkillsListView(character: $npc, allowDelete: false)
                            }
                            NavArrowView(title: "NPC Bio") { _ in
                                ViewBioView(character: $npc)
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
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return ViewNPCStuffView(npc: md.fullCharacters().first!)
}
