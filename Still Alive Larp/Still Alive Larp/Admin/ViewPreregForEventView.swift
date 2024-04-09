//
//  ViewPreregForEventView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/17/23.
//

import SwiftUI

struct ViewPreregForEventView: View {
    @ObservedObject private var _dm = DataManager.shared

    let event: EventModel

    var body: some View {
        VStack {
            VStack {
                Text("Preregistration for\n\(event.title)")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .frame(alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                if DataManager.shared.loadingAllPlayers || DataManager.shared.loadingAllCharacters || DataManager.shared.loadingEventPreregs {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    List() {
                        ForEach(sortedPreregs()) { prereg in
                            CardView {
                                VStack {
                                    KeyValueView(key: "Name", value: getPlayerName(prereg.playerId))
                                    if prereg.eventRegType != .notPrereged {
                                        KeyValueView(key: "Character", value: getCharName(prereg.getCharId() ?? -1))
                                    }
                                    KeyValueView(key: "Reg Type", value: prereg.eventRegType.getAttendingText(), showDivider: false)
                                }
                            }.listRowSeparator(.hidden)
                            .listRowBackground(Color.lightGray)
                        }
                    }.scrollContentBackground(.hidden)
                }
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            runOnMainThread {
                DataManager.shared.load([.eventPreregs, .allPlayers, .character], forceDownloadIfApplicable: true)
            }
        }
    }

    func sortedPreregs() -> [EventPreregModel] {
        return (DataManager.shared.eventPreregs[event.id] ?? []).sorted(by: { f, s in
            getPlayerName(f.playerId).caseInsensitiveCompare(getPlayerName(s.playerId)) == .orderedAscending
        })
    }

    func getPlayerName(_ id: Int) -> String {
        return (DataManager.shared.allPlayers ?? []).first(where: { $0.id == id })?.fullName ?? ""
    }

    func getCharName(_ id: Int) -> String {
        return (DataManager.shared.allCharacters ?? []).first(where: { $0.id == id })?.fullName ?? "NPC"
    }
}
