//
//  AnnouncementsView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/11/22.
//

import SwiftUI

struct AnnouncementsView: View {
    @ObservedObject private var _dm = DataManager.shared

    @State private var currentAnnouncementIndex: Int = 0

    var body: some View {
        CardWithTitleView(title: "Announcements") {
            VStack {
                if DataManager.shared.loadingAnnouncements {
                    ProgressView().padding(.bottom, 8)
                    Text("Loading Announcements...")
                } else if (DataManager.shared.announcements ?? []).isEmpty {
                    Text("No announcements found!")
                } else if let ca = DataManager.shared.currentAnnouncement {
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
                        if currentAnnouncementIndex < (DataManager.shared.announcements?.count ?? 0) - 1 {
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
                DataManager.shared.load([.announcements])
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
        AnnouncementManager.shared.getAnnouncement(DataManager.shared.announcements?[currentAnnouncementIndex].id ?? -1) { announcement in
            DataManager.shared.currentAnnouncement = announcement
        } failureCase: { _ in
            // Do nothing
        }
    }

}

struct AnnouncementsView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementsView()
    }
}
