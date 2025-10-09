//
//  AwardCell.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/8/25.
//

import SwiftUI

struct AwardCell: View {
    
    let player: FullPlayerModel
    let award: AwardModel
    let showDivider: Bool
    
    var body: some View {
        VStack {
            HStack {
                if let character = player.characters.first(where: { $0.id == award.characterId }) {
                    Text(character.fullName)
                        .font(.system(size: 16, weight: .bold))
                } else {
                    Text(player.fullName)
                        .font(.system(size: 16, weight: .bold))
                }
                Text("\(award.date.yyyyMMddToMonthDayYear())")
                Spacer()
                Text(award.getDisplayText())
            }.padding([.top, .bottom], 8)
            Text("\(award.reason)")
            if showDivider {
                Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
            }
        }
    }
}
