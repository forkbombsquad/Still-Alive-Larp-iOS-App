//
//  ViewEventAttendeesView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/14/25.
//

import SwiftUI

struct ViewEventAttendeesView: View {
    
    @ObservedObject var _dm = DataManager.shared
    
    let eventModel: EventModel
    
    @State var eventAttendees: [EventAttendeeModel] = []
    @State var loadingEventAttendees = true
    @State var loadingPlayers = true
    @State var allPlayers: [PlayerModel] = []
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Attendees for\n\(eventModel.title)")
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                        if loadingEventAttendees || loadingPlayers {
                            LoadingBlock()
                        } else {
                            Text("Players")
                                .font(.system(size: 28, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .padding([.horizontal, .top], 16)
                                .padding(.bottom, 8)
                            LazyVStack(spacing: 8) {
                                ForEach(getCharacterAttendees()) { attendee in
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
                                ForEach(getNPCAttendees()) { attendee in
                                    KeyValueView(key: getPlayerName(attendee.playerId), value: attendee.isCheckedIn.boolValueDefaultFalse ? "Checked In" : "Checked Out")
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            self.loadingEventAttendees = true
            self.loadingPlayers = true
            DataManager.shared.selectedEvent = eventModel
            DataManager.shared.load([.allPlayers, .eventAttendeesForSelectedEvent]) {
                runOnMainThread {
                    self.allPlayers = DataManager.shared.allPlayers ?? []
                    self.eventAttendees = DataManager.shared.eventAttendeesForEvent
                    self.loadingEventAttendees = false
                    self.loadingPlayers = false
                }
            }
        }
    }
    
    private func getCharacterAttendees() -> [EventAttendeeModel] {
        return eventAttendees.filter({ !$0.asNpc.boolValueDefaultFalse })
    }
    
    private func getNPCAttendees() -> [EventAttendeeModel] {
        return eventAttendees.filter({ $0.asNpc.boolValueDefaultFalse })
    }
    
    private func getPlayerName(_ id: Int) -> String {
        return allPlayers.first(where: { $0.id == id })?.fullName ?? "Unknown Player"
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.eventAttendeesForEvent = md.eventAttendees.eventAttendees
    return ViewEventAttendeesView(_dm: dm, eventModel: md.event())
}
