//
//  ManageEventView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct ManageEventView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var event: FullEventModel

    @State var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { gr in
                ScrollView {
                    VStack(alignment: .center) {
                        globalCreateTitleView("Manage Event", DM: DM)
                        Divider()
                        KeyValueView(key: "Title", value: event.title)
                        KeyValueView(key: "Date", value: event.date.yyyyMMddToMonthDayYear())
                        KeyValueView(key: "Start Time", value: event.startTime)
                        KeyValueView(key: "End Time", value: event.endTime)
                        KeyValueView(key: "Is Started", value: event.isStarted)
                        KeyValueView(key: "Is Finished", value: event.isFinished)
                        KeyValueView(key: "Description", value: event.description)
                    }
                    if !DM.offlineMode {
                        NavArrowViewRed(title: "Edit Event Details") {
                            CreateEditEventView(event: event)
                        }.padding(.top, 16)
                    }
                    NavArrowViewBlue(title: "View Attendees") {
                        ViewEventAttendeesView(event: event)
                    }.padding(.top, 8)
                    if !event.isFinished && !DM.offlineMode {
                        LoadingButtonView($loading, width: gr.size.width - 32, buttonText: event.isStarted ? "Finish Event" : "Start Event") {
                            self.loading = true
                            var started = false
                            if !event.isStarted {
                                event.isStarted = true
                                started = true
                            } else {
                                event.isFinished = true
                            }
                            AdminService.updateEvent(event.baseModel()) { updatedEvent in
                                runOnMainThread {
                                    self.event.isStarted = updatedEvent.isStarted.boolValueDefaultFalse
                                    self.event.isFinished = updatedEvent.isFinished.boolValueDefaultFalse
                                    DM.load()
                                    alertManager.showOkAlert(started ? "Event Started" : "Event Finished") {
                                        runOnMainThread {
                                            self.loading = false
                                            self.mode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            } failureCase: { error in
                                self.loading = false
                            }

                        }.padding(.top, 16)
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
//    return ManageEventView(events: .constant(md.events.events), event: .constant(md.event(2)))
//}
