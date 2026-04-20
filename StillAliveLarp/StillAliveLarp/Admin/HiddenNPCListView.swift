//
//  HiddenNPCListView.swift
//  Still Alive Larp
//

import SwiftUI

struct HiddenNPCListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let destination: NPCListView.NPCListViewDestination

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        let npcs = DM.getAllCharacters(.hidden)
                        let living = npcs.filter({ $0.isAlive })
                        let dead = npcs.filter({ !$0.isAlive })

                        globalCreateTitleView("Hidden NPCs", DM: DM)
                        Divider().padding(.horizontal, 16).padding(.bottom, 8)

                        NavArrowViewGreen(title: "Create New Hidden NPC") {
                            CreateNPCView(isHidden: true)
                        }
                        .padding(.vertical, 8)

                        LazyVStack(spacing: 8) {
                            ForEach(living.alphabetized) { npc in
                                NavArrowView(title: npc.fullName) { _ in
                                    switch destination {
                                    case .view:
                                        ViewNPCStuffView(npc: npc)
                                    case .manage:
                                        ManageNPCView(character: npc)
                                    }
                                }
                            }
                            ForEach(dead.alphabetized) { npc in
                                NavArrowViewRed(title: "\(npc.fullName) (Dead)") {
                                    switch destination {
                                    case .view:
                                        ViewNPCStuffView(npc: npc)
                                    case .manage:
                                        ManageNPCView(character: npc)
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
