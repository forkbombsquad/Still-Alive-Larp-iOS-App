//
//  PreregCell.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/10/25.
//

import SwiftUI

struct PreregCell: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let prereg: EventPreregModel
    
    var body: some View {
        CardView {
            VStack {
                KeyValueView(key: "Name", value: DM.players.first(where: { $0.id == prereg.playerId })?.fullName ?? "")
                if prereg.eventRegType != .notPrereged {
                    KeyValueView(key: "Character", value: DM.characters.first(where: { $0.id == prereg.getCharId() })?.fullName ?? "NPC")
                }
                KeyValueView(key: "Reg Type", value: prereg.eventRegType.getAttendingText(), showDivider: false)
            }
        }
        .padding(.horizontal, 16)
    }
}
