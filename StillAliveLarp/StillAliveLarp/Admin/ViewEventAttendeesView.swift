//
//  ViewEventAttendeesView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/14/25.
//

import SwiftUI

// TODO redo view

struct ViewEventAttendeesView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let event: FullEventModel
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        globalCreateTitleView("Attendees for\n\(event.title)", DM: DM)
                        Text("Players")
                            .font(.system(size: 28, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .padding([.horizontal, .top], 16)
                            .padding(.bottom, 8)
                        LazyVStack(spacing: 8) {
                            ForEach(event.attendees.filter({ !$0.asNpc.boolValueDefaultFalse })) { attendee in
                                KeyValueView(key: getPlayerName(attendee.playerId), value: attendee.isCheckedIn.boolValueDefaultFalse ? "Checked In" : "Checked Out")
                            }
                        }
                        Text("NPCs")
                            .font(.system(size: 28, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .padding([.horizontal, .top], 16)
                            .padding(.bottom, 8)
                        LazyVStack(spacing: 8) {
                            ForEach(event.attendees.filter({ $0.asNpc.boolValueDefaultFalse })) { attendee in
                                KeyValueView(key: getPlayerName(attendee.playerId), value: attendee.isCheckedIn.boolValueDefaultFalse ? "Checked In" : "Checked Out")
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
    
    private func getPlayerName(_ id: Int) -> String {
        return DM.players.first(where: { $0.id == id })?.fullName ?? "Unknown Player"
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return ViewEventAttendeesView(eventModel: md.event())
//}
