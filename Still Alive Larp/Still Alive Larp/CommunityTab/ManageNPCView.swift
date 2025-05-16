//
//  ManageNPCView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

import SwiftUI

struct ManageNPCView: View {
    
    @ObservedObject var _dm = DataManager.shared
    
    @Binding var npcs: [CharacterModel]
    let npc: CharacterModel
    
    @State var loading = false
    
    // TODO don't forget to update the binding so that it updates the view below
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Manage NPC\n\(npc.fullName)")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ArrowViewButton(title: "Manage Bullets and Infection", loading: $loading) {
                            // TODO edit bullets and infection. dont forget loading
                            /*
                             Adjust .fullName Values
                             Field(Bullets)
                             Field(Infection Rating)
                             Checkbox(Is Alive)
                             ok/cancel
                             */
                        }
                        NavArrowView(title: "Manage Skills", loading: $loading) { attachedObject in
                            // TODO
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            DataManager.shared.load([])
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return ManageNPCView(_dm: dm, npcs: .constant(md.characterListFullModel.characters), npc: md.character())
}
