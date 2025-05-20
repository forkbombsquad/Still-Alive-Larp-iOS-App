//
//  AnnouncementManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import Foundation

class AnnouncementManager {

    static let shared = AnnouncementManager()

    private var announcementExpireDate = Date()

    private var allAnnouncements: [AnnouncementSubModel] = []

    private var cachedAnnouncements: [AnnouncementModel] = []
    private let cacheKey = "cachedAnnouncement"

    private init() {
        var counter = 1
        while let announcement: AnnouncementModel =  (UserDefaults.standard.object(forKey: "\(cacheKey)\(counter)") as? Data)?.toJsonObject() {
            cachedAnnouncements.append(announcement)
            counter += 1
        }
    }

    func getAnnouncements(_ forceNewAnnouncements: Bool = false, callback: @escaping (_ announcements: [AnnouncementSubModel]) -> Void, failureCase: @escaping FailureCase) {
        if needToRequestAnnouncements() || forceNewAnnouncements {
            ServiceController.makeRequest(.announcementsAll, responseObject: AnnouncementsListModel.self, success: { success in
                self.allAnnouncements = success.jsonObject.announcements
                callback(self.allAnnouncements)
                self.startCachingNewAnnouncements()
                self.setAnnouncementExpireDate()
            }, failureCase: failureCase)
        } else {
            callback(self.allAnnouncements)
        }

    }

    private func needToRequestAnnouncements() -> Bool {
        guard !allAnnouncements.isEmpty else { return true }
        return Date() >= announcementExpireDate
    }

    private func setAnnouncementExpireDate() {
        let currentDate = Date()
        var components = DateComponents()

        components.day = 1
        announcementExpireDate = Calendar.current.date(byAdding: components, to: currentDate) ?? currentDate
    }

    private func startCachingNewAnnouncements() {
        let uncachedAnnouncements = allAnnouncements.filter { allAn in
            return !cachedAnnouncements.contains(where: { caAn in
                caAn.id == allAn.id
            })
        }

        if let firstAn = uncachedAnnouncements.first {
            cacheAnnouncementRecursive(firstAn.id, uncachedAnnouncements: uncachedAnnouncements)
        }
    }

    private func cacheAnnouncementRecursive(_ currentAn: Int, uncachedAnnouncements: [AnnouncementSubModel]) {
        getAnnouncementFromService(currentAn, onSuccess: { announcement in
            self.cacheAnnouncement(announcement)
            let ua = uncachedAnnouncements.filter { $0.id != currentAn }
            if let firstAn = ua.first {
                self.cacheAnnouncementRecursive(firstAn.id, uncachedAnnouncements: ua)
            }
        }, failureCase: { _ in })
    }

    private func cacheAnnouncement(_ an: AnnouncementModel) {
        UserDefaults.standard.set(an.toData(), forKey: "\(cacheKey)\(an.id)")
        cachedAnnouncements.append(an)
    }

    func getAnnouncement(_ id: Int, onSuccess: @escaping (_ announcement: AnnouncementModel) -> Void, failureCase: @escaping FailureCase) {
        let an = cachedAnnouncements.first { $0.id == id }
        if let cachedAnnouncement = an {
            onSuccess(cachedAnnouncement)
        } else {
            getAnnouncementFromService(id, onSuccess: onSuccess, failureCase: failureCase)
        }
    }

    private func getAnnouncementFromService(_ id: Int, onSuccess: @escaping (_ announcement: AnnouncementModel) -> Void, failureCase: @escaping FailureCase) {
        AnnouncementService.getAnnouncement(id, onSuccess: { announcement in
            onSuccess(announcement)
            self.cacheAnnouncement(announcement)
        }, failureCase: failureCase)
    }

}
