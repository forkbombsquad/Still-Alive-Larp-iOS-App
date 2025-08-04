//
//  CharacterBioListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct CharacterBioListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Binding var charactersWhoNeedBiosApproved: [CharacterModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Select Character Bio")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        if charactersWhoNeedBiosApproved.count == 0 {
                            Text("No bios need approval")
                        } else {
                            ForEach($charactersWhoNeedBiosApproved) { $approve in
                                NavArrowView(title: approve.fullName) { _ in
                                    ApproveBioView(character: $approve)
                                }
                            }
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            self.charactersWhoNeedBiosApproved = self.charactersWhoNeedBiosApproved.filter({ c in
                !c.approvedBio.boolValueDefaultFalse && !c.bio.isEmpty
            })
        }
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return CharacterBioListView(_dm: dm, charactersWhoNeedBiosApproved: .constant(md.characterListFullModel.characters))
}
