//
//  SelectEventForPreregView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/17/23.
//

import SwiftUI

struct SelectEventForPreregView: View {
    @ObservedObject private var _dm = DataManager.shared

    let events: [EventModel]

    init(events: [EventModel]) {
        self.events = events.filter({ $0.isInFuture() && !$0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse })
    }

    var body: some View {
        VStack {
            ScrollView {
                GeometryReader { gr in
                    VStack {
                        Text("Select Event For Preregistration")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ForEach(events) { event in
                            NavArrowViewBlue(title: "\(event.title) - \(event.date.yyyyMMddToMonthDayYear())") {
                                ViewPreregForEventView(event: event)
                            }.navigationViewStyle(.stack)
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }

}
