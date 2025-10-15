//
//  ViewAwardsView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/8/25.
//

import SwiftUI

struct ViewAwardsView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let player: FullPlayerModel
    let awards: [AwardModel]
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        globalCreateTitleView("Awards", DM: DM)
                        ForEach(awards) { award in
                            AwardCell(player: player, award: award, showDivider: award != awards.last)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
}

