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

    let event: FullEventModel

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        globalCreateTitleView("Preregistrations for\n\(event.title)", DM: DM)
                        let regNums = event.preregs.getRegNumbers()
                        KeyValueView(key: "Premiums", value: "\(regNums.premium) Total (\(regNums.premiumNpc) NPCs)")
                        KeyValueView(key: "Basics", value: "\(regNums.basic) Total (\(regNums.basicNpc) NPCs)")
                        KeyValueView(key: "Frees", value: "\(regNums.free) Total (All Are NPCs)")
                        KeyValueView(key: "Not Attending", value: "\(regNums.notAttending)")
                        LazyVStack(spacing: 8) {
                            ForEach(getSortedPreregs()) { prereg in
                                PreregCell(prereg: prereg)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
    
    func getSortedPreregs() -> [EventPreregModel] {
        return event.preregs.sorted { prereg1, prereg2 in
            let firstName = DM.players.first(where: { $0.id == prereg1.playerId })?.fullName ?? ""
            let secondName = DM.players.first(where: { $0.id == prereg2.playerId })?.fullName ?? ""
            return firstName < secondName
        }
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return ViewPreregForEventView(event: md.event())
//}
