//
//  EventModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import Foundation

struct FullEventModel: CustomCodeable, Identifiable {
    let id: Int
    // TODO
}

struct EventModel: CustomCodeable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let date: String
    let startTime: String
    let endTime: String
    var isStarted: String
    var isFinished: String

    var barcodeModel: EventBarcodeModel {
        return EventBarcodeModel(self)
    }

    func isToday() -> Bool {
        return Calendar.current.isDateInToday(date.yyyyMMddtoDate())
    }

    func isInFuture() -> Bool {
        return Date() < date.yyyyMMddtoDate()
    }

    func startedFinishedText() -> String {
        if isFinished.boolValueDefaultFalse {
            return "Finished"
        }
        if isStarted.boolValueDefaultFalse {
            return "Ongoing"
        }
        return ""
    }
}

struct EventBarcodeModel: CustomCodeable, Identifiable {
    let id: Int
    let title: String
    let date: String
    let startTime: String
    let endTime: String
    var isStarted: String
    var isFinished: String

    init(_ event: EventModel) {
        self.id = event.id
        self.title = event.title
        self.date = event.date
        self.startTime = event.startTime
        self.endTime = event.endTime
        self.isStarted = event.isStarted
        self.isFinished = event.isFinished
    }
}

struct EventListModel: CustomCodeable {
    let events: [EventModel]
}

struct CreateEventModel: CustomCodeable {
    let title: String
    let description: String
    let date: String
    let startTime: String
    let endTime: String
    let isStarted: String
    let isFinished: String
}

