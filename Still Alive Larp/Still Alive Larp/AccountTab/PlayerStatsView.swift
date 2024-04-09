//
//  PlayerStatsView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 1/6/23.
//

import SwiftUI

struct PlayerStatsView: View {
    @ObservedObject private var _dm = DataManager.shared

    let player: PlayerModel?
    let offline: Bool

    init(offline: Bool = false, player: PlayerModel?) {
        self.offline = offline
        self.player = player
    }

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .center) {
                    Text("Player Stats\(offline ? " (Offline)" : "")")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                        .padding([.bottom], 16)
                    Divider()
                    if let player = player {
                        KeyValueView(key: "Name", value: player.fullName)
                        if DataManager.shared.player?.id == player.id {
                            KeyValueView(key: "Email", value: player.username)
                        }
                        KeyValueView(key: "Start Date", value: player.startDate.yyyyMMddToMonthDayYear())
                        KeyValueView(key: "Experience", value: player.experience)
                        KeyValueView(key: "Free Tier-1 Skills", value: player.freeTier1Skills)
                        KeyValueView(key: "Prestige Points", value: player.prestigePoints)
                        KeyValueView(key: "Total Events Attended", value: player.numEventsAttended)
                        KeyValueView(key: "NPC Events Attended", value: player.numNpcEventsAttended)
                        KeyValueView(key: "Last Event Attended", value: player.lastCheckIn.yyyyMMddToMonthDayYear(), showDivider: player.isAdmin.boolValueDefaultFalse)
                        if player.isAdmin.boolValueDefaultFalse {
                            KeyValueView(key: "Admin", value: player.isAdmin)
                        }
                    } else {
                        Text("Something went wrong...")
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
