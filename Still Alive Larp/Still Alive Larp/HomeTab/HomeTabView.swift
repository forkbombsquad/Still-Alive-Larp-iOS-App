//
//  HomeTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import SwiftUI

struct HomeTabView: View {
    @ObservedObject var _dm = DataManager.shared
    @State private var firstLoad = true

    var body: some View {
        NavigationView {
            VStack {
            GeometryReader { gr in
                    ScrollView(showsIndicators: false) {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh_HomeTab", spinnerOffsetY: -100, pullDownDistance: 60) {
                            self.refreshEverything()
                        }
                        VStack {
                            Text("Home")
                                .font(.system(size: 32, weight: .bold))
                            AnnouncementsView()
                            if showIntrigueSection() {
                                IntrigueView()
                            }
                            if showCheckoutSection() {
                                CardWithTitleView(title: "Checkout") {
                                    NavArrowViewRed(title: "Checkout", loading: DataManager.$shared.loadingEventAttendees, content: {
                                        GenerateCheckoutBarcodeView()
                                    })
                                }
                            }
                            if showCurrentCharSection() {
                                CurrentCharacterView(grWidth: gr.size.width)
                            }
                            if DataManager.shared.loadingEvents || DataManager.shared.events?.isEmpty == false {
                                EventsView()
                            }
                            if DataManager.shared.loadingAwards || !DataManager.shared.loadingEvents {
                                AwardsView()
                            }
                        }
                    }.coordinateSpace(name: "pullToRefresh_HomeTab")
                }
            }
            .padding(16)
            .background(Color.lightGray)
            .onAppear {
                if firstLoad {
                    firstLoad = false
                    self.refreshEverything()
                }
            }
        }
    }

    func showIntrigueSection() -> Bool {
        return DataManager.shared.player?.isCheckedIn.boolValueDefaultFalse ?? false && !(DataManager.shared.player?.isCheckedInAsNpc.boolValueDefaultFalse ?? false) && (DataManager.shared.character?.getIntrigueSkills() ?? []).count > 0 && !(DataManager.shared.loadingIntrigue) && DataManager.shared.intrigue != nil
    }

    private func getCurrentEvent() -> EventModel? {
        return DataManager.shared.events?.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse})
    }

    func showCheckoutSection() -> Bool {
        return getCurrentEvent() == nil && DataManager.shared.player?.isCheckedIn.boolValueDefaultFalse == true && !DataManager.shared.loadingCharacter
    }

    func showCurrentCharSection() -> Bool {
        return !showIntrigueSection() && !showCheckoutSection()
    }

    func showEventsSection() -> Bool {
        return DataManager.shared.loadingEvents || DataManager.shared.events?.isEmpty == false
    }

    func refreshEverything() {
        DataManager.shared.load([.player, .character, .announcements, .events, .awards, .intrigue, .skills, .eventAttendees, .featureFlags], forceDownloadIfApplicable: true) {
            DataManager.shared.load([.eventPreregs], forceDownloadIfApplicable: true) {}
            runOnMainThread {
                DataManager.shared.selectedChar = DataManager.shared.character?.baseModel
                DataManager.shared.load([.selectedCharacterGear]) {}
            }
        }
    }

}

struct IntrigueView: View {
    @ObservedObject var _dm = DataManager.shared

    var body: some View {
        VStack {
            if let character = DataManager.shared.character, let intrigue = DataManager.shared.intrigue {
                CardWithTitleView(title: "Intrigue") {
                    Text("The following information is only given to those with one (or more) of the following skills: Investigator, Interrogator, and Web of Informants. You are free to share this information with others or keep it to yourself.")
                    let intrigueSkills = character.getIntrigueSkills()
                    if intrigueSkills.contains(where: { $0 == Constants.SpecificSkillIds.investigator }) {
                        Divider().padding([.leading, .trailing], 16)
                        Text("Rumor (Investigator)").font(.system(size: 14, weight: .bold)).multilineTextAlignment(.center)
                        Text(intrigue.investigatorMessage)
                    }
                    if intrigueSkills.contains(where: { $0 == Constants.SpecificSkillIds.interrogator }) {
                        Divider().padding([.leading, .trailing], 16)
                        Text("Fact (Interrogator)").font(.system(size: 14, weight: .bold)).multilineTextAlignment(.center)
                        Text(intrigue.interrogatorMessage)
                    }
                    if intrigueSkills.contains(where: { $0 == Constants.SpecificSkillIds.webOfInformants }) {
                        Divider().padding([.leading, .trailing], 16)
                        Text("Additional Fact (Web of Informants)").font(.system(size: 14, weight: .bold)).multilineTextAlignment(.center)
                        Text(intrigue.webOfInformantsMessage)
                    }
                }
            }
        }
    }

}

struct EventsView: View {
    @ObservedObject var _dm = DataManager.shared

    @State var currentEventIndex: Int = 0

    var body: some View {
        if DataManager.shared.loadingEvents {
            CardWithTitleView(title: "Events") {
                ProgressView().padding(.bottom, 8)
                Text("Loading Events...")
            }
        } else if let events = DataManager.shared.events, let event = (events.first(where: { $0.isToday() }) ?? events.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse })) {
            CardWithTitleView(title: "Event Today!") {
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
                    if event.isStarted.boolValueDefaultFalse && !event.isFinished.boolValueDefaultFalse {
                        if !(DataManager.shared.player?.isCheckedIn.boolValueDefaultFalse ?? false) {
                            if let character = DataManager.shared.character {
                                NavArrowViewGreen(title: "Check In as \(character.fullName)", loading: DataManager.$shared.loadingSelectedCharacterGear) {
                                    GenerateCheckInBarcodeView(useChar: true)
                                }
                            }
                            NavArrowViewBlue(title: "Check In as NPC") {
                                GenerateCheckInBarcodeView(useChar: false)
                            }
                        } else {
                            Text("Checked in as \(DataManager.shared.player?.isCheckedInAsNpc.boolValueDefaultFalse == true ? "NPC" : (DataManager.shared.character?.fullName ?? ""))")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.top, 8)
                        }
                    }
                }
            }
        } else {
            CardWithTitleView(title: "Events") {
                VStack {
                    if let currentEvent = DataManager.shared.currentEvent {
                        Text(currentEvent.title)
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(currentEvent.description)
                            .font(.system(size: 16))
                            .lineLimit(nil)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(currentEvent.date.yyyyMMddToMonthDayYear()) - from \(currentEvent.startTime) to \(currentEvent.endTime)")
                            .font(.system(size: 16))
                            .lineLimit(nil)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                        if currentEvent.isInFuture() {
                            NavArrowViewBlue(title: (DataManager.shared.eventPreregs[currentEvent.id] ?? []).contains(where: { $0.eventId == currentEvent.id }) ? "Edit Your Pre-Registartion" : "Pre-Register for this event") {
                                PreregView()
                            }
                        }
                        HStack {
                            if currentEventIndex > 0 {
                                Image(systemName: "arrow.left.circle")
                                    .font(.system(size: 44))
                                    .foregroundColor(.midRed)
                                    .padding(.top, 8)
                                    .onTapGesture {
                                        self.goToPreviousEvent()
                                    }
                            }
                            Spacer()
                            if currentEventIndex < (DataManager.shared.events?.count ?? 0) - 1 {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 44))
                                    .foregroundColor(.midRed)
                                    .padding(.top, 8)
                                    .onTapGesture {
                                        self.goToNextEvent()
                                    }
                            }
                        }
                    }
                }
            }
        }
    }

    private func goToPreviousEvent() {
        changeEvent(-1)
    }

    private func goToNextEvent() {
        changeEvent(1)
    }

    private func changeEvent(_ byAmount: Int) {
        currentEventIndex += byAmount
        DataManager.shared.currentEvent = DataManager.shared.events?[currentEventIndex]
    }

}

struct CurrentCharacterView: View {
    @ObservedObject var _dm = DataManager.shared

    let grWidth: CGFloat

    var body: some View {
        CardWithTitleView(title: "Current Character") {
            VStack {
                if DataManager.shared.loadingCharacter {
                    ProgressView().padding(.bottom, 8)
                    Text("Loading Character Information...")
                } else if let currentCharacter = DataManager.shared.character {
                    Text(currentCharacter.fullName)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(nil)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                } else if DataManager.shared.player != nil {
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

struct AwardsView: View {
    @ObservedObject var _dm = DataManager.shared

    @Binding private var loading: Bool

    init() {
        _loading = DataManager.$shared.loadingAwards
    }

    var body: some View {
        CardWithTitleView(title: "Awards") {
            VStack {
                if loading {
                    ProgressView().padding(.bottom, 8)
                    Text("Loading Awards...")
                } else if !(DataManager.shared.awards?.isEmpty ?? true) {
                   ForEach(DataManager.shared.awards ?? []) { award in
                       VStack {
                           HStack {
                               Text("\(award.date.yyyyMMddToMonthDayYear())")
                               Spacer()
                               Text("\(award.amount) \(award.awardType)")
                           }.padding([.top, .bottom], 8)
                           Text("\(award.reason)")
                           if award != DataManager.shared.awards?.last {
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

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
