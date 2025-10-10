//
//  EventModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import Foundation

struct FullEventModel: CustomCodeable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let date: String
    let startTime: String
    let endTime: String
    var isStarted: Bool
    var isFinished: Bool
    var attendees: [EventAttendeeModel]
    var preregs: [EventPreregModel]
    var intrigue: IntrigueModel?
    
    init(event: EventModel, attendees: [EventAttendeeModel], preregs: [EventPreregModel], intrigue: IntrigueModel?) {
        self.id = event.id
        self.title = event.title
        self.description = event.description
        self.date = event.date
        self.startTime = event.startTime
        self.endTime = event.endTime
        self.isStarted = event.isStarted.boolValueDefaultFalse
        self.isFinished = event.isFinished.boolValueDefaultFalse
        self.attendees = attendees
        self.preregs = preregs
        self.intrigue = intrigue
    }
    
    func isOngoing() -> Bool {
        return isStarted && !isFinished
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDate(Date(), inSameDayAs: date.yyyyMMddtoDate())
    }
    
    func isInFuture() -> Bool {
        return date.yyyyMMddtoDate().isAfter(Date())
    }
    
    func isRelevant() -> Bool {
        return (isOngoing() || isToday() || isInFuture()) && !isFinished
    }
    
    func baseModel() -> EventModel {
        return EventModel(id: id, title: title, description: description, date: date, startTime: startTime, endTime: endTime, isStarted: isStarted.stringValue, isFinished: isFinished.stringValue)
    }
    
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

