//
//  AnnouncementModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import Foundation

struct AnnouncementModel: CustomCodeable {
    let id: Int
    let title: String
    let text: String
    let date: String
}

struct CreateAnnouncementModel: CustomCodeable {
    let title: String
    let text: String
    let date: String
}

struct AnnouncementSubModel: CustomCodeable {
    let id: Int
}

struct AnnouncementsListModel: CustomCodeable {
    let announcements: [AnnouncementSubModel]
}

struct AnnouncementFullListModel: CustomCodeable {
    let announcements: [AnnouncementModel]
}
