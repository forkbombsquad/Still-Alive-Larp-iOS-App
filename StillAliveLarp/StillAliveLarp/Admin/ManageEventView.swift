//
//  ManageEventView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct ManageEventView: View {
    @ObservedObject var _dm = OldDataManager.shared

    @Binding var events: [EventModel]
    @Binding var event: EventModel

    @State var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { gr in
                ScrollView {
                    VStack(alignment: .center) {
                        Text("Manage Event")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                            .padding([.bottom], 16)
                        Divider()
                        KeyValueView(key: "Title", value: event.title)
                        KeyValueView(key: "Date", value: event.date.yyyyMMddToMonthDayYear())
                        KeyValueView(key: "Start Time", value: event.startTime)
                        KeyValueView(key: "End Time", value: event.endTime)
                        KeyValueView(key: "Is Started", value: event.isStarted)
                        KeyValueView(key: "Is Finished", value: event.isFinished)
                        KeyValueView(key: "Description", value: event.description)
                    }
                    NavArrowViewRed(title: "Edit Event Details") {
                        CreateEditEventView(events: $events, event: event)
                    }.padding(.top, 16)
                    NavArrowViewBlue(title: "View Attendees") {
                        ViewEventAttendeesView(eventModel: event)
                    }.padding(.top, 8)
                    if !event.isFinished.boolValueDefaultFalse {
                        LoadingButtonView($loading, width: gr.size.width - 32, buttonText: event.isStarted.boolValueDefaultFalse ? "Finish Event" : "Start Event") {
                            self.loading = true
                            var started = false
                            if !event.isStarted.boolValueDefaultFalse {
                                event.isStarted = "TRUE"
                                started = true
                            } else {
                                event.isFinished = "TRUE"
                            }
                            AdminService.updateEvent(event) { updatedEvent in
                                runOnMainThread {
                                    self.event = updatedEvent
                                    AlertManager.shared.showOkAlert(started ? "Event Started" : "Event Finished") {
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

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return ManageEventView(_dm: dm, events: .constant(md.events.events), event: .constant(md.event(2)))
}
