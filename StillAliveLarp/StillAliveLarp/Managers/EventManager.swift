//
//  EventManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import Foundation

class EventManager {

    // TODO remove this boi completely
    
    static let shared = EventManager()

    private init() {}

    private var events: [EventModel]?
    private var fetching = false

    private var completionBlocks = [((events: [EventModel]) -> Void)?]()

    func getEvents(overrideLocal: Bool = false, _ completion: ((_ events: [EventModel]) -> Void)? = nil) {
        if !overrideLocal, let events = events {
            completion?(events)
        } else {
            completionBlocks.append(completion)
            guard !fetching else { return }
            fetching = true
            EventService.getAllEvents { eventList in
                self.events = eventList.events
                self.fetching = false
                for cb in self.completionBlocks {
                    cb?(self.events ?? [])
                }
                self.completionBlocks = []
            } failureCase: { error in
                self.fetching = false
                for cb in self.completionBlocks {
                    cb?(self.events ?? [])
                }
                self.completionBlocks = []
            }
        }
    }

}
