//
//  AnnouncementsView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/11/22.
//

import SwiftUI

struct AnnouncementsView: View {
    @ObservedObject var _dm = DataManager.shared

    @State private var currentAnnouncementIndex: Int = 0
    @State private var currentAnnouncement: AnnouncementModel?
    @State private var announcements: [AnnouncementSubModel] = []
    @State private var loadingAnnouncements: Bool = false

    var body: some View {
        CardWithTitleView(title: "Announcements") {
            VStack {
                if loadingAnnouncements {
                    ProgressView().padding(.bottom, 8)
                    Text("Loading Announcements...")
                } else if announcements.isEmpty {
                    Text("No announcements found!")
                } else if let ca = currentAnnouncement {
                    Text(ca.title)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(ca.date.yyyyMMddToMonthDayYear())
                        .font(.system(size: 16))
                        .lineLimit(nil)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(ca.text)
                        .font(.system(size: 16))
                        .lineLimit(nil)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        if currentAnnouncementIndex > 0 {
                            Image(systemName: "arrow.left.circle")
                                .font(.system(size: 44))
                                .foregroundColor(.midRed)
                                .padding(.top, 8)
                                .onTapGesture {
                                    self.goToPreviousAnnouncement()
                                }
                        }
                        Spacer()
                        if currentAnnouncementIndex < announcements.count - 1 {
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 44))
                                .foregroundColor(.midRed)
                                .padding(.top, 8)
                                .onTapGesture {
                                    self.goToNextAnnouncement()
                                }
                        }
                    }
                }
            }.onAppear(perform: {
                self.loadingAnnouncements = true
                DataManager.shared.load([.announcements]) {
                    runOnMainThread {
                        self.loadingAnnouncements = false
                        self.announcements = DataManager.shared.announcements ?? []
                        self.currentAnnouncement = DataManager.shared.currentAnnouncement
                    }
                }
            })
        }
    }

    private func goToPreviousAnnouncement() {
        changeShownAnnouncement(-1)
    }

    private func goToNextAnnouncement() {
        changeShownAnnouncement(1)
    }

    private func changeShownAnnouncement(_ byAmount: Int) {
        currentAnnouncementIndex = currentAnnouncementIndex + byAmount
        AnnouncementManager.shared.getAnnouncement(announcements[currentAnnouncementIndex].id) { announcement in
            runOnMainThread {
                self.currentAnnouncement = announcement
            }
        } failureCase: { _ in
            // Do nothing
        }
    }

}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    dm.loadingAnnouncements = false
    return AnnouncementsView(_dm: dm)
}
