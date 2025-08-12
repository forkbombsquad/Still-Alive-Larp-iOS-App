//
//  SelectEventForPreregView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/17/23.
//

import SwiftUI

struct SelectEventForPreregView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let events: [EventModel]

    init(events: [EventModel]) {
        self.events = events
    }

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Select Event For Preregistration")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ForEach(events) { event in
                            if event.isFinished.boolValueDefaultFalse {
                                NavArrowViewRed(title: "\(event.title) - \(event.date.yyyyMMddToMonthDayYear())") {
                                    ViewPreregForEventView(event: event)
                                }.navigationViewStyle(.stack)
                            } else if event.isStarted.boolValueDefaultFalse {
                                NavArrowViewBlue(title: "\(event.title) - \(event.date.yyyyMMddToMonthDayYear())") {
                                    ViewPreregForEventView(event: event)
                                }.navigationViewStyle(.stack)
                            } else {
                                NavArrowView(title: "\(event.title) - \(event.date.yyyyMMddToMonthDayYear())") { _ in
                                    
                                    ViewPreregForEventView(event: event)
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

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return SelectEventForPreregView(events: md.events.events)
//}
