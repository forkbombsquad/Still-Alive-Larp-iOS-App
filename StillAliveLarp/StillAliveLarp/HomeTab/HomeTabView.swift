//
//  HomeTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var showAllEvents = false

    var body: some View {
        NavigationView {
            VStack {
            GeometryReader { gr in
                    ScrollView(showsIndicators: false) {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh_HomeTab", spinnerOffsetY: -100, pullDownDistance: 150) {
                            DM.load()
                        }
                        VStack {
                            Text(DM.getTitlePotentiallyOffline("Home"))
                                .font(.stillAliveTitleFont)
                                .frame(alignment: .center)
                            LoadingLayoutView {
                                VStack {
                                    AnnouncementsView()
                                    if showIntrigueSection() {
                                        IntrigueView()
                                    }
                                    if showCheckoutSection() {
                                        CheckoutView()
                                    }
                                    if showCurrentCharSection() {
                                        CurrentCharacterView(grWidth: gr.size.width)
                                    }
                                    if showEventsSection() {
                                        EventsView(showAllEvents: $showAllEvents, grWidth: gr.size.width)
                                    }
                                    AwardsView()
                                }
                            }
                        }
                    }.coordinateSpace(name: "pullToRefresh_HomeTab")
                }
            }
            .padding(16)
            .background(Color.lightGray)
        }.navigationViewStyle(.stack)
    }

    func showIntrigueSection() -> Bool {
        let show = DM.getOngoingOrTodayEvent()?.intrigue != nil
        if let char = DM.getActiveCharacter() {
            return char.getPurchasedIntrigueSkills().isNotEmpty && show
        } else {
            let npcId = DM.getOngoingOrTodayEvent()?.attendees.first(where: { $0.playerId == (DM.getCurrentPlayer()?.id ?? -1) })?.npcId ?? -1
            let npc = DM.getAllCharacters(.npc).first(where: { $0.id == npcId })
            if let npc = npc {
                return npc.getPurchasedIntrigueSkills().isNotEmpty && show
            }
        }
        return false
    }

    func showCheckoutSection() -> Bool {
        return DM.getOngoingEvent() != nil && DM.getCurrentPlayer()?.isCheckedIn ?? false
    }

    func showCurrentCharSection() -> Bool {
        return !(DM.getCurrentPlayer()?.isCheckedIn ?? true)
    }

    func showEventsSection() -> Bool {
        return showAllEvents ? DM.events.isNotEmpty : DM.getRelevantEvents().isNotEmpty
    }

}

struct AnnouncementsView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State private var currentAnnouncementIndex: Int = 0

    var body: some View {
        CardWithTitleView(title: DM.getTitlePotentiallyOffline("Announcements")) {
            VStack {
                if DM.announcements.isEmpty {
                    Text("No announcements found!")
                } else {
                    let announcement = DM.announcements[currentAnnouncementIndex]
                    Text(announcement.title)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(announcement.date.yyyyMMddToMonthDayYear())
                        .font(.system(size: 16))
                        .lineLimit(nil)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(announcement.text)
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
                        if currentAnnouncementIndex < DM.announcements.count - 1 {
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
            }
        }
    }

    private func goToPreviousAnnouncement() {
        currentAnnouncementIndex -= 1
    }

    private func goToNextAnnouncement() {
        currentAnnouncementIndex += 1
    }

}

struct IntrigueView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    var body: some View {
        VStack {
            CardWithTitleView(title: DM.getTitlePotentiallyOffline("Intrigue")) {
                Text("The following information is only given to those with one or both of the following skills: Investigator, Interrogator. You are free to share this information with others or keep it to yourself.")
                let intrigueSkills = getIntrigueSkillIds()
                let intrigue = getCurrentIntrigue()
                if intrigueSkills.contains(where: { $0 == Constants.SpecificSkillIds.investigator }) {
                    Divider().padding([.leading, .trailing], 16)
                    Text("Fact 1 (Investigator)").font(.system(size: 14, weight: .bold)).multilineTextAlignment(.center)
                    Text(intrigue?.investigatorMessage ?? "")
                }
                if intrigueSkills.contains(where: { $0 == Constants.SpecificSkillIds.interrogator }) {
                    Divider().padding([.leading, .trailing], 16)
                    Text("Fact 2 (Interrogator)").font(.system(size: 14, weight: .bold)).multilineTextAlignment(.center)
                    Text(intrigue?.interrogatorMessage ?? "")
                }
            }
        }
    }
    
    func getIntrigueSkillIds() -> [Int] {
        if let char = DM.getActiveCharacter() {
            return char.getPurchasedIntrigueSkills()
        } else {
            let npcId = DM.getOngoingOrTodayEvent()?.attendees.first(where: { $0.playerId == (DM.getCurrentPlayer()?.id ?? -1) })?.npcId ?? -1
            let npc = DM.getAllCharacters(.npc).first(where: { $0.id == npcId })
            if let npc = npc {
                return npc.getPurchasedIntrigueSkills()
            }
        }
        return []
    }
    
    func getCurrentIntrigue() -> IntrigueModel? {
        return DM.getOngoingOrTodayEvent()?.intrigue
    }

}

struct CheckoutView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    var body: some View {
        VStack {
            CardWithTitleView(title: DM.getTitlePotentiallyOffline("Checkout")) {
                let player = DM.getCurrentPlayer()!
                let attendee = player.eventAttendees.first(where: { attendee in attendee.isCheckedIn.boolValueDefaultFalse })!
                NavArrowViewRed(title: "Checkout From Event:\n\(DM.events.first(where: { event in event.id == attendee.eventId })?.title ?? "")") {
                    GenerateCheckoutBarcodeView(player: DM.getCurrentPlayer()!, attendee: attendee)
                }
            }
        }
    }
}

struct CurrentCharacterView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let grWidth: CGFloat

    var body: some View {
        CardWithTitleView(title: DM.getTitlePotentiallyOffline("Current Character")) {
            VStack {
                if let currentCharacter = DM.getActiveCharacter() {
                    Text(currentCharacter.fullName)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(nil)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                } else if DM.getCurrentPlayer() != nil {
                    Text("You don't have any living characters!")
                        .font(.system(size: 16))
                        .lineLimit(nil)
                        .padding(.top, 8)
                    NavigationLink(destination: CreateCharacterView()) {
                        Text("Create New Character")
                            .frame(width: grWidth - 32, height: 90)
                            .background(Color.midRed)
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .tint(.midRed)
                            .controlSize(.large)
                            .padding(.top, 8)
                    }.navigationViewStyle(.stack)
                }
            }
        }
    }
}

struct EventsView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @Binding var showAllEvents: Bool
    @State private var selectedEventIndex = 0
    
    let grWidth: CGFloat

    var body: some View {
        if let event = DM.getOngoingOrTodayEvent(), let player = DM.getCurrentPlayer() {
            CardWithTitleView(title: DM.getTitlePotentiallyOffline("Event Today!")) {
                VStack {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)
                    Text("\(event.date.yyyyMMddToMonthDayYear())\n\(event.startTime) to \(event.endTime)")
                        .font(.system(size: 16))
                        .lineLimit(nil)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(event.description)
                        .font(.system(size: 16))
                        .lineLimit(nil)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                    if event.isOngoing() {
                        if player.isCheckedIn, let attendee = event.attendees.first(where: { $0.playerId == player.id }) {
                            if let character = player.characters.first(where: { $0.id == attendee.characterId }) {
                                Text("Checked in as \(character.fullName)")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.top, 8)
                            } else if let npc = DM.getCharacter(attendee.npcId) {
                                VStack {
                                    Text("Checked in as \(npc.fullName)")
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.top, 8)
                                    NavArrowView(title: "View Info For \(npc.fullName)") { _ in
                                        ViewNPCStuffView(npc: npc)
                                    }
                                }
                                
                            }
                        } else {
                            if let character = player.getActiveCharacter() {
                                NavArrowViewGreen(title: "Check In as \(character.fullName)") {
                                    GenerateCheckInBarcodeView(player: player, useChar: true, event: event)
                                }
                            }
                            NavArrowViewBlue(title: "Check In as NPC") {
                                GenerateCheckInBarcodeView(player: player, useChar: false, event: event)
                            }
                        }
                    }
                }
            }
        } else if let player = DM.getCurrentPlayer() {
            CardWithTitleView(title: DM.getTitlePotentiallyOffline("Events")) {
                VStack {
                    let events = showAllEvents ? DM.events : DM.getRelevantEvents()
                    if events.indexIsInBounds(selectedEventIndex) {
                        let event = events[selectedEventIndex]
                        Text(event.title)
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                        Text("\(event.date.yyyyMMddToMonthDayYear())\nfrom \(event.startTime) to \(event.endTime)")
                            .font(.system(size: 16))
                            .lineLimit(nil)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                        Text(event.description)
                            .font(.system(size: 16))
                            .lineLimit(nil)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if event.isRelevant() {
                            let prereg = event.preregs.first(where: { $0.playerId == player.id })
                            NavArrowViewBlue(title: prereg != nil ? "Edit Your Pre-Registartion" : "Pre-Register For This Event") {
                                PreregView(event: event, prereg: prereg, player: player, character: player.getActiveCharacter())
                            }
                            if let prereg = prereg {
                                let char = player.characters.first(where: { $0.id == prereg.getCharId() })
                                let regType = prereg.eventRegType.getAttendingText()
                                Text("You are pre-registered for this event as:\n\n\(prereg.getCharId() == nil ? "NPC" : char?.fullName ?? "") - \(prereg.regType)")
                                    .multilineTextAlignment(.center)
                                    .frame(alignment: .center)
                            }
                        }
                        HStack {
                            let disabled = selectedEventIndex == 0
                            Image(systemName: "arrow.left.circle")
                                .font(.system(size: 44))
                                .foregroundColor(disabled ? .darkGray : .midRed)
                                .padding(.top, 8)
                                .onTapGesture {
                                    self.goToPreviousEvent()
                                }
                                .disabled(disabled)
                            Spacer()
                            LoadingButtonView(.constant(false), width: grWidth * 0.5, buttonText: showAllEvents ? "Show Only\nRelevant\nEvents" : "Show\nAll\nEvents") {
                                runOnMainThread {
                                    selectedEventIndex = 0
                                    showAllEvents = !showAllEvents
                                }
                            }
                            .padding(.top, 8)
                            Spacer()
                            let disabledFor = selectedEventIndex == events.count - 1
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 44))
                                .foregroundColor(disabledFor ? .darkGray : .midRed)
                                .padding(.top, 8)
                                .onTapGesture {
                                    self.goToNextEvent()
                                }
                                .disabled(disabledFor)
                        }
                    }
                }
            }
        }
    }

    private func goToPreviousEvent() {
        selectedEventIndex -= 1
    }

    private func goToNextEvent() {
        selectedEventIndex += 1
    }

}

struct AwardsView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    var body: some View {
        CardWithTitleView(title: DM.getTitlePotentiallyOffline("Awards")) {
            VStack {
                if let player = DM.getCurrentPlayer(), player.awards.isNotEmpty {
                    let awards = player.getAwardsSorted()
                    ForEach(awards) { award in
                       VStack {
                           HStack {
                               if let character = player.characters.first(where: { $0.id == award.characterId }) {
                                   Text(character.fullName)
                                       .font(.system(size: 16, weight: .bold))
                               } else {
                                   Text(player.fullName)
                                       .font(.system(size: 16, weight: .bold))
                               }
                               Text("\(award.date.yyyyMMddToMonthDayYear())")
                               Spacer()
                               Text(award.getDisplayText())
                           }.padding([.top, .bottom], 8)
                           Text("\(award.reason)")
                           if award != awards.last {
                               Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                           }
                       }
                   }
               } else {
                   Text("You don't have any Awards yet")
                       .font(.system(size: 16))
                       .lineLimit(nil)
                       .padding(.top, 8)
               }
            }
        }
    }

}

#Preview {
    DataManager.shared.setDebugMode(true)
    return HomeTabView()
}
