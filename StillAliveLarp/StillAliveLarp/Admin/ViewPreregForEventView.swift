//
//  ViewPreregForEventView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/17/23.
//

import SwiftUI

struct ViewPreregForEventView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var loadingPlayers = true
    @State var loadingCharacters = true
    @State var loadingEventPreregs = true
    
    @State var eventPreregs: [Int : [EventPreregModel]] = [:]
    @State var allPlayers: [PlayerModel] = []
    @State var allCharacters: [CharacterModel] = []

    let event: EventModel

    var body: some View {
        VStack {
            Text("Preregistration for\n\(event.title)")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .frame(alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
            if loadingPlayers || loadingCharacters || loadingEventPreregs {
                ScrollView {
                    LoadingBlock()
                }
            } else {
                let sortedPreregs = sortedPreregs()
                KeyValueView(key: "Premiums", value: "\(sortedPreregs.count(where: { $0.eventRegType == .premium })) Total (\(sortedPreregs.count(where: { $0.eventRegType == .premium && $0.getCharId() == nil })) NPCs)")
                KeyValueView(key: "Basics", value: "\(sortedPreregs.count(where: { $0.eventRegType == .basic })) Total (\(sortedPreregs.count(where: { $0.eventRegType == .basic && $0.getCharId() == nil })) NPCs)")
                KeyValueView(key: "Frees", value: "\(sortedPreregs.count(where: { $0.eventRegType == .free })) Total (\(sortedPreregs.count(where: { $0.eventRegType == .free && $0.getCharId() == nil })) NPCs)")
                KeyValueView(key: "Not Attending", value: "\(sortedPreregs.count(where: { $0.eventRegType == .notPrereged }))", showDivider: false)
                List() {
                    ForEach(sortedPreregs) { prereg in
                        CardView {
                            VStack {
                                KeyValueView(key: "Name", value: getPlayerName(prereg.playerId))
                                if prereg.eventRegType != .notPrereged {
                                    KeyValueView(key: "Character", value: getCharName(prereg.getCharId() ?? -1))
                                }
                                KeyValueView(key: "Reg Type", value: prereg.eventRegType.rawValue, showDivider: false)
                            }
                        }.listRowSeparator(.hidden)
                        .listRowBackground(Color.lightGray)
                    }
                }.scrollContentBackground(.hidden)
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            runOnMainThread {
                OldDM.load([.allPlayers, .allCharacters]) {
                    runOnMainThread {
                        self.allPlayers = OldDM.allPlayers ?? []
                        self.allCharacters = OldDM.allCharacters ?? []
                        self.loadingPlayers = false
                        self.loadingCharacters = false
                        OldDM.load([.eventPreregs], forceDownloadIfApplicable: true) {
                            self.eventPreregs = OldDM.eventPreregs
                            self.loadingEventPreregs = false
                        }
                    }
                }
            }
        }
    }

    func sortedPreregs() -> [EventPreregModel] {
        return (eventPreregs[event.id] ?? []).sorted(by: { f, s in
            getPlayerName(f.playerId).caseInsensitiveCompare(getPlayerName(s.playerId)) == .orderedAscending
        })
    }

    func getPlayerName(_ id: Int) -> String {
        return allPlayers.first(where: { $0.id == id })?.fullName ?? ""
    }

    func getCharName(_ id: Int) -> String {
        return allCharacters.first(where: { $0.id == id })?.fullName ?? "NPC"
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    dm.loadingAllPlayers = false
    dm.loadingAllCharacters = false
    dm.loadingEventPreregs = false
    let md = getMockData()
    return ViewPreregForEventView(_dm: dm, event: md.event())
}
