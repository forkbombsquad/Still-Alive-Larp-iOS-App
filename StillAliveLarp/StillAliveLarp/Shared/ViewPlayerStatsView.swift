//
//  ViewPlayerStatsView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 1/6/23.
//

import SwiftUI

struct ViewPlayerStatsView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let player: FullPlayerModel

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .center) {
                    globalCreateTitleView("Player Stats", DM: DM)
                        .padding([.bottom], 16)
                    Divider()
                    KeyValueView(key: "Name", value: player.fullName)
                    if player.isAdmin || DM.playerIsCurrentPlayer(player.id) {
                        KeyValueView(key: "Email", value: player.username)
                    }
                    KeyValueView(key: "Start Date", value: player.startDate.yyyyMMddToMonthDayYear())
                    KeyValueView(key: "Experience", value: player.experience.stringValue)
                    KeyValueView(key: "Free Tier-1 Skills", value: player.freeTier1Skills.stringValue)
                    KeyValueView(key: "Prestige Points", value: player.prestigePoints.stringValue)
                    KeyValueView(key: "Total Events Attended", value: player.numEventsAttended.stringValue)
                    KeyValueView(key: "NPC Events Attended", value: player.numNpcEventsAttended.stringValue)
                    KeyValueView(key: "Last Event Attended", value: player.lastCheckIn.yyyyMMddToMonthDayYear(), showDivider: player.isAdmin)
                    if player.isAdmin {
                        KeyValueView(key: "Admin", value: player.isAdmin.stringValue)
                    }
                    if player.isAdmin || DM.playerIsCurrentPlayer(player.id) {
                        KeyValueView(key: "PlayerId", value: player.id.stringValue)
                    }
                }
            }
            HStack {
                Spacer()
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}
