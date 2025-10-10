//
//  XpReductionsListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import SwiftUI

struct XpReductionsListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .center) {
                    globalCreateTitleView("XP Reductions For\n\(character.fullName)", DM: DM)
                    Divider()
                    if character.xpReductions.isEmpty {
                        Text("You have no Xp Reductions from classes you've taken. Try taking a Special class with someone who has the Professor skill to reduce the xp cost of specific skills! Don't forget to pay them!")
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(character.allSkillsWithCharacterModifications().filter({ $0.hasXpReduction() })) { skill in
                                KeyValueView(key: skill.name, value: skill.getXpCostText(allowFreeSkillUse: false))
                            }
                        }
                    }
                }
            }
            HStack {
                Spacer()
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
}
