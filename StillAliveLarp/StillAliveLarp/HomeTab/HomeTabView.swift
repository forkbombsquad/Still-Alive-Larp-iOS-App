//
//  HomeTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/10/22.
//

import SwiftUI

struct HomeTabView: View {
    @ObservedObject var _dm = OldDataManager.shared
    @State private var firstLoad = true
    
    @State var loadingEvents = false
    @State var loadingEventAttendees = false
    @State var loadingIntrigues = false
    @State var loadingCharacter = false
    @State var loadingAwards = false
    @State var loadingPreregs = false
    
    @State var player: PlayerModel?
    @State var character: FullCharacterModel?
    @State var events: [EventModel] = []
    @State var currentEvent: EventModel?
    @State var awards: [AwardModel] = []
    @State var intrigue: IntrigueModel?
    @State var eventAttendees: [EventAttendeeModel] = []
    @State var preregs: [Int : [EventPreregModel]] = [:]

    var body: some View {
        NavigationView {
            VStack {
            GeometryReader { gr in
                    ScrollView(showsIndicators: false) {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh_HomeTab", spinnerOffsetY: -100, pullDownDistance: 150) {
                            self.refreshEverything()
                        }
                        VStack {
                            Text("Home")
                                .font(.system(size: 32, weight: .bold))
                            AnnouncementsView()
                            if showIntrigueSection() && !loadingIntrigues && !loadingCharacter {
                                IntrigueView(character: $character, intrigue: $intrigue)
                            }
                            if showCheckoutSection() {
                                CardWithTitleView(title: "Checkout") {
                                    NavArrowViewRed(title: "Checkout", loading: $loadingEventAttendees, content: {
                                        GenerateCheckoutBarcodeView()
                                    })
                                }
                            }
                            if showCurrentCharSection() {
                                CurrentCharacterView(grWidth: gr.size.width, loadingCharacter: $loadingCharacter, character: $character, player: $player)
                            }
                            if loadingEvents || events.isNotEmpty {
                                EventsView(loadingEvents: $loadingEvents, events: $events, currentEvent: $currentEvent, loadingPreregs: $loadingPreregs, eventPreregs: $preregs, player: $player, character: $character, loadingCharacter: $loadingCharacter)
                            }
                            if loadingAwards || awards.isNotEmpty {
                                AwardsView(loadingAwards: $loadingAwards, awards: $awards)
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
        }.navigationViewStyle(.stack)
    }

    func showIntrigueSection() -> Bool {
        return player?.isCheckedIn.boolValueDefaultFalse ?? false &&
        !(player?.isCheckedInAsNpc.boolValueDefaultFalse ?? false) &&
        (character?.getIntrigueSkills() ?? []).isNotEmpty &&
        intrigue != nil
    }

    private func getCurrentEvent() -> EventModel? {
        return events.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse})
    }

    func showCheckoutSection() -> Bool {
        return getCurrentEvent() == nil && player?.isCheckedIn.boolValueDefaultFalse == true && !loadingCharacter
    }

    func showCurrentCharSection() -> Bool {
        var value = true
        if let player = player {
            if player.isCheckedIn.boolValueDefaultFalse {
                if !loadingCharacter && character == nil {
                    value = false
                }
            }
        }
        return value
    }

    func showEventsSection() -> Bool {
        return loadingEvents || events.isNotEmpty
    }

    func refreshEverything() {
        runOnMainThread {
            self.loadingEvents = true
            self.loadingEventAttendees = true
            self.loadingIntrigues = true
            self.loadingCharacter = true
            self.loadingAwards = true
            self.loadingPreregs = true
            
            OldDataManager.shared.load([.player, .character, .announcements, .events, .awards, .skills, .eventAttendees, .featureFlags], forceDownloadIfApplicable: true) {
                runOnMainThread {
                    let dm = OldDataManager.shared
                    self.loadingEvents = false
                    self.loadingEventAttendees = false
                    self.loadingCharacter = false
                    self.loadingAwards = false
                    
                    self.player = dm.player
                    self.character = dm.character
                    self.events = dm.events ?? []
                    self.currentEvent = dm.currentEvent
                    self.awards = dm.awards ?? []
                    self.eventAttendees = dm.eventAttendeesForPlayer ?? []
                    
                    OldDataManager.shared.load([.eventPreregs, .intrigue], forceDownloadIfApplicable: true) {
                        runOnMainThread {
                            self.preregs = OldDataManager.shared.eventPreregs
                            self.intrigue = OldDataManager.shared.intrigue
                            self.loadingPreregs = false
                            self.loadingIntrigues = false
                        }
                    }
                }
            }
        }
        
    }

}

struct IntrigueView: View {
    @ObservedObject var _dm = OldDataManager.shared
    
    @Binding var character: FullCharacterModel?
    @Binding var intrigue: IntrigueModel?

    var body: some View {
        VStack {
            if let character = character, let intrigue = intrigue {
                CardWithTitleView(title: "Intrigue") {
                    Text("The following information is only given to those with one or both of the following skills: Investigator, Interrogator. You are free to share this information with others or keep it to yourself.")
                    let intrigueSkills = character.getIntrigueSkills()
                    if intrigueSkills.contains(where: { $0 == Constants.SpecificSkillIds.investigator }) {
                        Divider().padding([.leading, .trailing], 16)
                        Text("Fact 1 (Investigator)").font(.system(size: 14, weight: .bold)).multilineTextAlignment(.center)
                        Text(intrigue.investigatorMessage)
                    }
                    if intrigueSkills.contains(where: { $0 == Constants.SpecificSkillIds.interrogator }) {
                        Divider().padding([.leading, .trailing], 16)
                        Text("Fact 2 (Interrogator)").font(.system(size: 14, weight: .bold)).multilineTextAlignment(.center)
                        Text(intrigue.interrogatorMessage)
                    }
                }
            }
        }
    }

}

struct EventsView: View {
    @ObservedObject var _dm = OldDataManager.shared

    @State var currentEventIndex: Int = 0
    @Binding var loadingEvents: Bool
    @Binding var events: [EventModel]
    @Binding var currentEvent: EventModel?
    @Binding var loadingPreregs: Bool
    @Binding var eventPreregs: [Int : [EventPreregModel]]
    @Binding var player: PlayerModel?
    @Binding var character: FullCharacterModel?
    @Binding var loadingCharacter: Bool

    var body: some View {
        if loadingEvents {
            CardWithTitleView(title: "Events") {
                ProgressView().padding(.bottom, 8)
                Text("Loading Events...")
            }
        } else if let event = (events.first(where: { $0.isToday() }) ?? events.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse })) {
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
                        if !(player?.isCheckedIn.boolValueDefaultFalse ?? false) {
                            if let character = character {
                                NavArrowViewGreen(title: "Check In as \(character.fullName)", loading: $loadingCharacter) {
                                    GenerateCheckInBarcodeView(useChar: true)
                                }
                            }
                            NavArrowViewBlue(title: "Check In as NPC") {
                                GenerateCheckInBarcodeView(useChar: false)
                            }
                        } else {
                            Text("\(loadingCharacter ? "Loading Check In Information..." : "Checked in as \(player?.isCheckedInAsNpc.boolValueDefaultFalse == true ? "NPC" : (character?.fullName ?? ""))")")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.top, 8)
                        }
                    }
                }
            }
        } else {
            CardWithTitleView(title: "Events") {
                VStack {
                    if let currentEvent = currentEvent {
                        Text(currentEvent.title)
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                        Text("\(currentEvent.date.yyyyMMddToMonthDayYear())\nfrom \(currentEvent.startTime) to \(currentEvent.endTime)")
                            .font(.system(size: 16))
                            .lineLimit(nil)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                        Text(currentEvent.description)
                            .font(.system(size: 16))
                            .lineLimit(nil)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if currentEvent.isInFuture() {
                            let prereg = (eventPreregs[currentEvent.id] ?? []).first(where: { $0.playerId == player?.id })
                            NavArrowViewBlue(title: loadingPreregs ? "Loading Preregs..." : (prereg != nil ? "Edit Your Pre-Registartion" : "Pre-Register for this event"), loading: $loadingPreregs) {
                                PreregView(event: currentEvent, prereg: prereg, player: player, character: character?.baseModel).onDisappear {
                                    runOnMainThread {
                                        self.loadingPreregs = true
                                        OldDataManager.shared.load([.eventPreregs], forceDownloadIfApplicable: true) {
                                            runOnMainThread {
                                                self.eventPreregs = OldDataManager.shared.eventPreregs
                                                self.loadingPreregs = false
                                            }
                                        }
                                    }
                                }
                            }
                            if let prereg = prereg {
                                Text("You are pre-registered for this event as:\n\n\(prereg.getCharId() == nil ? "NPC" : character?.fullName ?? "") - \(prereg.regType)")
                                    .multilineTextAlignment(.center)
                                    .frame(alignment: .center)
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
                            if currentEventIndex < events.count - 1 {
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
        currentEvent = events[currentEventIndex]
    }

}

struct CurrentCharacterView: View {
    @ObservedObject var _dm = OldDataManager.shared

    let grWidth: CGFloat
    
    @Binding var loadingCharacter: Bool
    @Binding var character: FullCharacterModel?
    @Binding var player: PlayerModel?

    var body: some View {
        CardWithTitleView(title: "Current Character") {
            VStack {
                if loadingCharacter {
                    ProgressView().padding(.bottom, 8)
                    Text("Loading Character Information...")
                } else if let currentCharacter = character {
                    Text(currentCharacter.fullName)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(nil)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                } else if player != nil {
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
    @ObservedObject var _dm = OldDataManager.shared

    @Binding var loadingAwards: Bool
    @Binding var awards: [AwardModel]

    var body: some View {
        CardWithTitleView(title: "Awards") {
            VStack {
                if loadingAwards {
                    ProgressView().padding(.bottom, 8)
                    Text("Loading Awards...")
                } else if awards.isNotEmpty {
                   ForEach(awards) { award in
                       VStack {
                           HStack {
                               Text("\(award.date.yyyyMMddToMonthDayYear())")
                               Spacer()
                               Text("\(award.amount) \(award.awardType)")
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
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.loadingPlayer = false
    dm.loadingCharacter = false
    dm.loadingIntrigue = false
    dm.loadingEvents = false
    dm.loadingAwards = false
    dm.loadingAnnouncements = false
    dm.player = md.player(id: 2)
    dm.character = md.fullCharacters()[1]
    var htv = HomeTabView()
    htv._dm = dm
    return htv
}
