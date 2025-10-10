//
//  EventsListView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 10/10/25.
//

import SwiftUI

struct EventsListView: View {
    
    enum EventsListViewDestination {
        case prereg, eventManagement, intrigue
    }
    
    enum EventsListViewAdditionalDestination {
        case none, createNewEvent
    }
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let title: String
    let destination: EventsListViewDestination
    let additionalDestination: EventsListViewAdditionalDestination
    @State var events: [FullEventModel]
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        globalCreateTitleView(title, DM: DM)
                        if !DM.offlineMode && additionalDestination == .createNewEvent {
                            NavArrowViewBlue(title: "Create New Event") {
                                CreateEditEventView()
                            }
                        }
                        LazyVStack(spacing: 8) {
                            ForEach(events.sorted(by: { first, second in
                                first.id > second.id
                            })) { event in
                                if event.isOngoing() {
                                    NavArrowViewGreen(title: event.title) {
                                        switch destination {
                                        case .prereg:
                                            ViewPreregForEventView(event: event)
                                        case .eventManagement:
                                            ManageEventView(event: event)
                                        case .intrigue:
                                            AddEditEventIntrigueView(event: event)
                                        }
                                    }
                                } else if event.isFinished {
                                    NavArrowViewRed(title: event.title) {
                                        switch destination {
                                        case .prereg:
                                            ViewPreregForEventView(event: event)
                                        case .eventManagement:
                                            ManageEventView(event: event)
                                        case .intrigue:
                                            AddEditEventIntrigueView(event: event)
                                        }
                                    }
                                } else {
                                    NavArrowView(title: event.title) { _ in
                                        switch destination {
                                        case .prereg:
                                            ViewPreregForEventView(event: event)
                                        case .eventManagement:
                                            ManageEventView(event: event)
                                        case .intrigue:
                                            AddEditEventIntrigueView(event: event)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
}
