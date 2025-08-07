//
//  NPCListView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/7/25.
//

import SwiftUI

struct NPCListView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    enum NPCListViewDestination {
        case view, manage
    }
    
    let npcs: [FullCharacterModel]
    let title: String
    let destination: NPCListViewDestination
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        let living = npcs.filter({ $0.isAlive })
                        let dead = npcs.filter({ !$0.isAlive })
                        Text(DM.getTitlePotentiallyOffline(title))
                            .font(.stillAliveTitleFont)
                            .frame(alignment: .center)
                        Divider().padding(.horizontal, 16).padding(.bottom, 8)
                        KeyValueView(key: "Total Living NPCs", value: "\(living.count) / 10", showDivider: false)
                        KeyValueView(key: "Quest Rewards Reduced By", value: "\((10 - living.count) * 10)%").padding(.top, 8)
                        LazyVStack(spacing: 8) {
                            ForEach(living.alphabetized) { npc in
                                NavArrowView(title: npc.fullName) { _ in
                                    switch destination {
                                    case .view:
                                        ViewNPCStuffView(npc: npc)
                                    case .manage:
                                        // TODO manage npc
                                    }
                                }
                            }
                            ForEach(dead.alphabetized) { npc in
                                NavArrowViewRed(title: "\(npc.fullName) (Dead)") {
                                    switch destination {
                                    case .view:
                                        ViewNPCStuffView(npc: npc)
                                    case .manage:
                                        // TODO manage npc
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
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return NPCListView(npcs: md.fullCharacters(), title: "All NPCs", destination: .view)
}
