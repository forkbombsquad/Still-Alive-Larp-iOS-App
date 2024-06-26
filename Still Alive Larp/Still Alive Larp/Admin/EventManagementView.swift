//
//  EventManagement.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct EventManagementView: View {
    @ObservedObject private var _dm = DataManager.shared

    @Binding var events: [EventModel]

    var body: some View {
        VStack {
            ScrollView {
                GeometryReader { gr in
                    VStack {
                        Text("Event Management")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        NavArrowViewRed(title: "Add New Event") {
                            CreateEventView(events: $events)
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
