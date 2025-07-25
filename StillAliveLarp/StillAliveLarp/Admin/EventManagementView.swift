//
//  EventManagement.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct EventManagementView: View {
    @ObservedObject var _dm = OldDataManager.shared

    @Binding var events: [EventModel]

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Event Management")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        NavArrowViewRed(title: "Add New Event") {
                            CreateEditEventView(events: $events)
                        }
                        ForEach($events) { $event in
                            if event.isFinished.boolValueDefaultFalse {
                                NavArrowViewBlue(title: "\(event.title) - \(event.date.yyyyMMddToMonthDayYear())") {
                                    ManageEventView(events: $events, event: $event)
                                }.navigationViewStyle(.stack)
                            } else if event.isStarted.boolValueDefaultFalse {
                                NavArrowViewGreen(title: "\(event.title) - \(event.date.yyyyMMddToMonthDayYear())") {
                                    ManageEventView(events: $events, event: $event)
                                }.navigationViewStyle(.stack)
                            } else {
                                NavArrowView(title: "\(event.title) - \(event.date.yyyyMMddToMonthDayYear())") { _ in
                                    ManageEventView(events: $events, event: $event)
                                }.navigationViewStyle(.stack)
                            }
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return EventManagementView(_dm: dm, events: .constant(md.events.events))
}
