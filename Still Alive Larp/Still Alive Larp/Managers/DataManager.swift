//
//  DataManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/30/23.
//

import SwiftUI

class DataManager: ObservableObject {

    enum DataManagerType {
        case player, character, announcements, events, awards, intrigue, skills, allPlayers, allCharacters, charForSelectedPlayer, contactRequests, eventAttendees, xpReductions, eventPreregs, selectedCharXpReductions, intrigueForSelectedEvent, selectedCharacterGear, rulebook, featureFlags, profileImage
    }

    @ObservedObject static var shared = DataManager()

    static func forceReset() {
        runOnMainThread {
            shared.targetCount = [:]
            shared.countReturned = [:]
            shared.callbacks = [:]

            shared.selectedPlayer = nil
            shared.selectedEvent = nil
            shared.selectedChar = nil
            shared.selectedContactRequest = nil
            shared.checkinBarcodeModel = nil
            shared.checkoutBarcodeModel = nil

            shared.announcements = nil
            shared.currentAnnouncement = nil
            shared.loadingAnnouncements = true

            shared.player = nil
            shared.loadingPlayer = true

            shared.character = nil
            shared.loadingCharacter = true

            shared.events = nil
            shared.currentEvent = nil
            shared.loadingEvents = true

            shared.awards = nil
            shared.loadingAwards = true

            shared.intrigue = nil
            shared.loadingIntrigue = true

            shared.skills = nil
            shared.loadingSkills = true

            shared.allPlayers = nil
            shared.loadingAllPlayers = true

            shared.allCharacters = nil
            shared.loadingAllCharacters = true

            shared.charForSelectedPlayer = nil
            shared.loadingCharForSelectedPlayer = true

            shared.contactRequests = nil
            shared.loadingContactRequests = true

            shared.eventAttendeesForPlayer = nil
            shared.loadingEventAttendees = true

            shared.xpReductions = nil
            shared.loadingXpReductions = true

            shared.eventPreregs = [:]
            shared.loadingEventPreregs = true

            shared.selectedCharacterXpReductions = nil
            shared.loadingSelectedCharacterXpReductions = true

            shared.intrigueForSelectedEvent = nil
            shared.loadingIntrigueForSelectedEvent = true

            shared.featureFlags = []
            shared.loadingFeatureFlags = true

            shared.profileImage = nil
            shared.loadingProfileImage = true
        }
    }

    private init() {}

    @Published private var targetCount: [Int: Int] = [:]
    @Published private var countReturned: [Int: Int] = [:]
    @Published private var callbacks: [Int: () -> Void] = [:]

    @Published var selectedPlayer: PlayerModel? = nil

    func setSelectedPlayer(player: PlayerModel?) {
        self.selectedPlayer = selectedPlayer
    }

    func popToRoot() {
        runOnMainThread {
            self.actionState = 0
        }
    }
    
    // TODO ALWAYS set this to false before release
    var debugMode = false

    @Published var actionState: Int? = 0

    @Published var selectedEvent: EventModel? = nil
    @Published var selectedChar: CharacterModel? = nil
    @Published var selectedContactRequest: ContactRequestModel? = nil
    @Published var checkinBarcodeModel: PlayerCheckInBarcodeModel? = nil
    @Published var checkoutBarcodeModel: PlayerCheckOutBarcodeModel? = nil

    @Published var announcements: [AnnouncementSubModel]? = nil
    @Published var currentAnnouncement: AnnouncementModel? = nil
    @Published var loadingAnnouncements: Bool = true

    @Published var player: PlayerModel? = nil
    @Published var loadingPlayer: Bool = true

    @Published var character: FullCharacterModel? = nil
    @Published var loadingCharacter = true

    @Published var events: [EventModel]? = nil
    @Published var currentEvent: EventModel? = nil
    @Published var loadingEvents: Bool = true

    @Published var awards: [AwardModel]? = nil
    @Published var loadingAwards: Bool = true

    @Published var intrigue: IntrigueModel? = nil
    @Published var loadingIntrigue: Bool = true

    @Published var skills: [FullSkillModel]? = nil
    @Published var loadingSkills: Bool = true

    @Published var allPlayers: [PlayerModel]? = nil
    @Published var loadingAllPlayers: Bool = true

    @Published var allCharacters: [CharacterModel]? = nil
    @Published var loadingAllCharacters: Bool = true

    @Published var charForSelectedPlayer: FullCharacterModel? = nil
    @Published var loadingCharForSelectedPlayer: Bool = true

    @Published var contactRequests: [ContactRequestModel]? = nil
    @Published var loadingContactRequests: Bool = true

    @Published var eventAttendeesForPlayer: [EventAttendeeModel]? = nil
    @Published var loadingEventAttendees: Bool = true

    @Published var xpReductions: [SpecialClassXpReductionModel]? = nil
    @Published var loadingXpReductions: Bool = true

    @Published var eventPreregs: [Int: [EventPreregModel]] = [:]
    @Published var loadingEventPreregs: Bool = true

    @Published var selectedCharacterXpReductions: [SpecialClassXpReductionModel]? = nil
    @Published var loadingSelectedCharacterXpReductions: Bool = true

    @Published var intrigueForSelectedEvent: IntrigueModel? = nil
    @Published var loadingIntrigueForSelectedEvent: Bool = true

    @Published var loadingSelectedCharacterGear: Bool = true
    @Published var selectedCharacterGear: [GearModel]? = nil

    @Published var rulebook: Rulebook? = nil
    @Published var loadingRulebook: Bool = true

    @Published var featureFlags: [FeatureFlagModel] = []
    @Published var loadingFeatureFlags: Bool = true

    @Published var profileImage: ProfileImageModel? = nil
    @Published var loadingProfileImage: Bool = true

    @Published var downloadedImage: UIImage?

    func load(_ types: [DataManagerType], forceDownloadIfApplicable: Bool = false, incrementalIndex: Int = IncrementalIndexManager.shared.getNextIndex(), finished: @escaping () -> Void = {}) {
        guard !debugMode else {
            finished()
            return
        }
        runOnMainThread {
            self.targetCount[incrementalIndex] = types.count
            self.countReturned[incrementalIndex] = 0
            self.callbacks[incrementalIndex] = finished
            if self.targetCount[incrementalIndex] == 0 {
                self.callbacks[incrementalIndex]?()
            }

            for t in types {
                switch t {
                case .player:
                    self.loadingPlayer = true
                    if let pid = self.player?.id, forceDownloadIfApplicable {
                        PlayerService.getPlayer(pid) { player in
                            runOnMainThread {
                                self.player = player
                                PlayerManager.shared.setPlayer(player)
                                self.loadingPlayer = false
                                self.finishedRequest(incrementalIndex, "Player Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.player = PlayerManager.shared.getPlayer()
                                self.loadingPlayer = false
                                self.finishedRequest(incrementalIndex, "Player Failure")
                            }
                        }
                    } else {
                        self.player = PlayerManager.shared.getPlayer()
                        self.loadingPlayer = false
                        self.finishedRequest(incrementalIndex, "Player From Memory")
                    }
                case .character:
                    self.loadingCharacter = true
                    CharacterManager.shared.fetchActiveCharacter(overrideLocal: forceDownloadIfApplicable) { character in
                        runOnMainThread {
                            self.character = character
                            self.loadingCharacter = false
                            self.finishedRequest(incrementalIndex, "Load Character")
                        }
                    }
                case .announcements:
                    self.loadingAnnouncements = true
                    AnnouncementManager.shared.getAnnouncements(forceDownloadIfApplicable) { announcements in
                        runOnMainThread {
                            self.announcements = announcements.reversed()
                            if let an = self.announcements?.first {
                                AnnouncementManager.shared.getAnnouncement(an.id) { announcement in
                                    runOnMainThread {
                                        self.currentAnnouncement = announcement
                                        self.loadingAnnouncements = false
                                        self.finishedRequest(incrementalIndex, "Announcement Success")
                                    }
                                } failureCase: { error in
                                    runOnMainThread {
                                        self.currentAnnouncement = nil
                                        self.loadingAnnouncements = false
                                        self.finishedRequest(incrementalIndex, "Announcement Failure")
                                    }
                                }
                            } else {
                                self.currentAnnouncement = nil
                                self.loadingAnnouncements = false
                                self.finishedRequest(incrementalIndex, "Announcements Failure")
                            }
                        }
                    } failureCase: { error in
                        runOnMainThread {
                            self.loadingAnnouncements = false
                            self.finishedRequest(incrementalIndex, "Announcements From Memory")
                        }
                    }

                case .events:
                    self.loadingEvents = true
                    EventManager.shared.getEvents(overrideLocal: forceDownloadIfApplicable) { eventList in
                        runOnMainThread {
                            self.events = eventList.inChronologicalOrder
                            self.currentEvent = self.events?.first
                            if self.loadingIntrigue, let ev = self.events?.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse }) {
                                self.currentEvent = ev
                                IntrigueService.getIntrigue(ev.id) { intrigue in
                                    runOnMainThread {
                                        self.loadingIntrigue = false
                                        self.intrigue = intrigue
                                        self.finishedRequest(incrementalIndex, "Intriuge Success")
                                    }
                                } failureCase: { error in
                                    runOnMainThread {
                                        self.loadingIntrigue = false
                                        self.intrigue = nil
                                        self.finishedRequest(incrementalIndex, "Intrigue Failure")
                                    }
                                }
                            } else {
                                self.loadingIntrigue = false
                                self.intrigue = nil
                            }
                            self.loadingEvents = false
                            self.finishedRequest(incrementalIndex, "Events Success")
                        }
                    }
                case .awards:
                    self.loadingAwards = true
                    if let pid = self.player?.id, self.awards == nil || forceDownloadIfApplicable {
                        AwardService.getAwardsForPlayer(pid) { awardList in
                            runOnMainThread {
                                self.awards = awardList.awards.reversed()
                                self.loadingAwards = false
                                self.finishedRequest(incrementalIndex, "Awards Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.loadingAwards = false
                                self.awards = nil
                                self.finishedRequest(incrementalIndex, "Awards Failure")
                            }
                        }
                    } else {
                        self.loadingAwards = false
                        self.finishedRequest(incrementalIndex, "Awards From Memory")
                    }
                case .intrigue:
                    self.loadingIntrigue = true
                    if self.events == nil && !self.loadingEvents {
                        self.intrigue = nil
                        self.loadingIntrigue = false
                        self.finishedRequest(incrementalIndex, "Intrigue (other) None")
                    } else if self.events != nil, let current = self.events?.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse }) {
                        IntrigueService.getIntrigue(current.id) { intrigue in
                            runOnMainThread {
                                self.loadingIntrigue = false
                                self.intrigue = intrigue
                                self.finishedRequest(incrementalIndex, "Intrigue (other) Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.intrigue = nil
                                self.loadingIntrigue = false
                                self.finishedRequest(incrementalIndex, "Intrigue (other) Failure")
                            }
                        }
                    } else {
                        self.intrigue = nil
                        self.loadingIntrigue = false
                        self.finishedRequest(incrementalIndex, "Intrigue (other) Nonex2")
                    }
                case .skills:
                    self.loadingSkills = true
                    SkillManager.shared.getSkills(overrideLocal: forceDownloadIfApplicable) { skills in
                        runOnMainThread {
                            self.skills = skills
                            self.loadingSkills = false
                            self.finishedRequest(incrementalIndex, "Skills Success")
                        }
                    }
                case .allPlayers:
                    self.loadingAllPlayers = true
                    if self.allPlayers == nil || forceDownloadIfApplicable {
                        PlayerService.getAllPlayers { playerList in
                            runOnMainThread {
                                self.allPlayers = playerList.players.filter({ $0.username.lowercased() != "googletestaccount@gmail.com" })
                                self.loadingAllPlayers = false
                                self.finishedRequest(incrementalIndex, "All Players Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.allPlayers = nil
                                self.loadingAllPlayers = false
                                self.finishedRequest(incrementalIndex, "All Players Failure")
                            }
                        }
                    } else {
                        self.loadingAllPlayers = false
                        self.finishedRequest(incrementalIndex, "All Players From Memory")
                    }
                case .allCharacters:
                    self.loadingAllCharacters = true
                    if (self.allCharacters == nil || forceDownloadIfApplicable) {
                        CharacterService.getAllCharacters { characterList in
                            runOnMainThread {
                                self.allCharacters = characterList.characters.filter({ $0.fullName.lowercased() != "google test" })
                                self.loadingAllCharacters = false
                                self.finishedRequest(incrementalIndex, "All Characters Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.allCharacters = nil
                                self.loadingAllCharacters = false
                                self.finishedRequest(incrementalIndex, "All Characters Failure")
                            }
                        }
                    } else {
                        self.loadingAllCharacters = false
                        self.finishedRequest(incrementalIndex, "All Characters From Memory")
                    }
                case .charForSelectedPlayer:
                    self.loadingCharForSelectedPlayer = true
                    if let player = self.selectedPlayer {
                        if self.charForSelectedPlayer == nil || forceDownloadIfApplicable || self.charForSelectedPlayer?.playerId != player.id {
                            CharacterManager.shared.getActiveCharacterForOtherPlayer(player.id) { character in
                                runOnMainThread {
                                    self.charForSelectedPlayer = character
                                    self.loadingCharForSelectedPlayer = false
                                    self.finishedRequest(incrementalIndex, "Char For Selected Player Success")
                                }
                            } failureCase: { error in
                                runOnMainThread {
                                    self.charForSelectedPlayer = nil
                                    self.loadingCharForSelectedPlayer = false
                                    self.finishedRequest(incrementalIndex, "Char For Selected Player Failure")
                                }
                            }
                        } else {
                            self.loadingCharForSelectedPlayer = false
                            self.finishedRequest(incrementalIndex, "Char For Selected Player From Memory")
                        }
                    } else {
                        self.charForSelectedPlayer = nil
                        self.loadingCharForSelectedPlayer = false
                        self.finishedRequest(incrementalIndex, "Char For Selected Player No Player")
                    }
                case .contactRequests:
                    self.loadingContactRequests = true
                    if self.contactRequests == nil || forceDownloadIfApplicable {
                        AdminService.getAllContactRequests { contactRequestList in
                            runOnMainThread {
                                self.contactRequests = contactRequestList.contactRequests
                                self.loadingContactRequests = false
                                self.finishedRequest(incrementalIndex, "Contact Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.contactRequests = nil
                                self.loadingContactRequests = false
                                self.finishedRequest(incrementalIndex, "Contact Failure")
                            }
                        }
                    } else {
                        self.loadingContactRequests = false
                        self.finishedRequest(incrementalIndex, "Contact From Memory")
                    }
                case .eventAttendees:
                    self.loadingEventAttendees = true
                    if let pid = self.player?.id, self.eventAttendeesForPlayer == nil || forceDownloadIfApplicable {
                        EventAttendeeService.getEventsForPlayer(pid) { attendeeList in
                            runOnMainThread {
                                self.eventAttendeesForPlayer = attendeeList.eventAttendees
                                self.loadingEventAttendees = false
                                self.finishedRequest(incrementalIndex, "Attendees Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.eventAttendeesForPlayer = nil
                                self.loadingEventAttendees = false
                                self.finishedRequest(incrementalIndex, "Attendees Failure")
                            }
                        }

                    } else {
                        self.loadingEventAttendees = false
                        self.finishedRequest(incrementalIndex, "Attendees From Memory")
                    }
                case .xpReductions:
                    self.loadingXpReductions = true
                    if let charId = self.character?.id, self.xpReductions == nil || forceDownloadIfApplicable {
                        SpecialClassXpReductionService.getXpReductionsForCharacter(charId) { xpReductions in
                            runOnMainThread {
                                self.xpReductions = xpReductions.specialClassXpReductions
                                self.loadingXpReductions = false
                                self.finishedRequest(incrementalIndex, "Xp Reductions Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.xpReductions = nil
                                self.loadingXpReductions = false
                                self.finishedRequest(incrementalIndex, "Xp Reductions Failure")
                            }
                        }

                    } else {
                        self.loadingXpReductions = false
                        self.finishedRequest(incrementalIndex, "Xp Reductions From Memory")
                    }
                case .eventPreregs:
                    self.loadingEventPreregs = true
                    if self.hasEventWithoutPreregs() || (forceDownloadIfApplicable && (self.events == nil || self.events?.isEmpty == true)) {
                        var count = 0
                        let max = self.events?.count ?? 0
                        for event in self.events ?? [] {
                            EventPreregService.getPreregsForEvent(event.id) { preregList in
                                runOnMainThread {
                                    self.eventPreregs[event.id] = preregList.eventPreregs
                                    count += 1
                                    if count == max {
                                        self.loadingEventPreregs = false
                                        self.finishedRequest(incrementalIndex, "Preregs Success")
                                    }
                                }
                            } failureCase: { error in
                                runOnMainThread {
                                    self.eventPreregs[event.id] = []
                                    count += 1
                                    if count == max {
                                        self.loadingEventPreregs = false
                                        self.finishedRequest(incrementalIndex, "Preregs Failure")
                                    }
                                }
                            }
                        }
                    } else {
                        self.loadingEventPreregs = false
                        self.finishedRequest(incrementalIndex, "Preregs From Memory")
                    }
                case .selectedCharXpReductions:
                    self.loadingSelectedCharacterXpReductions = true
                    if let charId = self.selectedChar?.id, self.selectedCharacterXpReductions == nil || forceDownloadIfApplicable {
                        SpecialClassXpReductionService.getXpReductionsForCharacter(charId) { xpReductions in
                            runOnMainThread {
                                self.selectedCharacterXpReductions = xpReductions.specialClassXpReductions
                                self.loadingSelectedCharacterXpReductions = false
                                self.finishedRequest(incrementalIndex, "Selected Char Xp Reductions Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.selectedCharacterXpReductions = nil
                                self.loadingSelectedCharacterXpReductions = false
                                self.finishedRequest(incrementalIndex, "Selected Char Xp Reductions Failure")
                            }
                        }
                    } else {
                        self.loadingSelectedCharacterXpReductions = false
                        self.finishedRequest(incrementalIndex, "Selected Char Xp Reductions From Memory")
                    }
                case .intrigueForSelectedEvent:
                    self.loadingIntrigueForSelectedEvent = true
                    if let eid = self.selectedEvent?.id, self.intrigueForSelectedEvent == nil || forceDownloadIfApplicable {
                        IntrigueService.getIntrigue(eid) { intrigue in
                            runOnMainThread {
                                self.intrigueForSelectedEvent = intrigue
                                self.loadingIntrigueForSelectedEvent = false
                                self.finishedRequest(incrementalIndex, "Intrigue For Event Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.intrigueForSelectedEvent = nil
                                self.loadingIntrigueForSelectedEvent = false
                                self.finishedRequest(incrementalIndex, "Intrigue For Event Failure")
                            }
                        }

                    } else {
                        self.loadingIntrigueForSelectedEvent = false
                        self.finishedRequest(incrementalIndex, "Intrigue For Event From Memory")
                    }
                case .selectedCharacterGear:
                    self.loadingSelectedCharacterGear = true
                    if let cid = self.selectedChar?.id, self.selectedCharacterGear == nil || forceDownloadIfApplicable {
                        GearService.getAllGearForCharacter(characterId: cid) { gearListModel in
                            runOnMainThread {
                                self.selectedCharacterGear = gearListModel.charGear
                                self.loadingSelectedCharacterGear = false
                                self.finishedRequest(incrementalIndex, "Selected Char Gear Success")
                                // Store gear in local data
                                if self.player != nil && self.selectedChar?.playerId == self.player?.id {
                                    LocalDataHandler.shared.storeGear(gearListModel)
                                }
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.selectedCharacterGear = nil
                                self.loadingSelectedCharacterGear = false
                                self.finishedRequest(incrementalIndex, "Selected Char Gear Failure")
                            }
                        }

                    } else {
                        self.loadingSelectedCharacterGear = false
                        self.finishedRequest(incrementalIndex, "Selected Char Gear From Memory")
                    }
                case .rulebook:
                    self.loadingRulebook = true
                    if self.rulebook == nil || forceDownloadIfApplicable {
                        RulebookManager.shared.getOnlineVersion { rulebook in
                            runOnMainThread {
                                self.rulebook = rulebook
                                self.loadingRulebook = false
                                self.finishedRequest(incrementalIndex, "Rulebook Success and/or Fail")
                            }
                        }
                    } else {
                        self.loadingRulebook = false
                        self.finishedRequest(incrementalIndex, "Rulebook From Memory")
                    }
                case .featureFlags:
                    self.loadingFeatureFlags = true
                    if self.featureFlags.isEmpty || forceDownloadIfApplicable {
                        FeatureFlagService.getAllFeatureFlags { featureFlags in
                            runOnMainThread {
                                self.featureFlags = featureFlags.results
                                self.loadingFeatureFlags = false
                                self.finishedRequest(incrementalIndex, "Feature Flag Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.featureFlags = []
                                self.loadingFeatureFlags = false
                                self.finishedRequest(incrementalIndex, "Feature Flag Failure")
                            }
                        }

                    } else {
                        self.loadingFeatureFlags = false
                        self.finishedRequest(incrementalIndex, "Feature Flags From Memory")
                    }
                case .profileImage:
                    self.loadingProfileImage = true
                    if self.profileImage == nil || forceDownloadIfApplicable || self.selectedPlayer?.id != self.profileImage?.playerId {
                        self.profileImage = nil
                        ProfileImageService.getProfileImage(self.selectedPlayer?.id ?? -1) { profileImage in
                            runOnMainThread {
                                self.profileImage = profileImage
                                self.loadingProfileImage = false
                                self.finishedRequest(incrementalIndex, "Profile Image Success")
                            }
                            
                        } failureCase: { error in
                            runOnMainThread {
                                self.profileImage = nil
                                self.loadingProfileImage = false
                                self.finishedRequest(incrementalIndex, "Profile Image Failure")
                            }
                        }

                    } else {
                        self.loadingProfileImage = false
                        self.finishedRequest(incrementalIndex, "Profile Image From Memory")
                    }
                }
            }
        }
    }

    func setSelectedPlayerAndCharFromPlayerAndChar() {
        runOnMainThread {
            self.selectedPlayer = self.player
            self.charForSelectedPlayer = self.character
        }
    }

    func loadLocalData() {
        guard !debugMode else { return }
        runOnMainThread {
            self.selectedPlayer = LocalDataHandler.shared.getPlayer()
            self.charForSelectedPlayer = LocalDataHandler.shared.getCharacter()
            self.selectedChar = self.charForSelectedPlayer?.baseModel
            self.selectedCharacterGear = LocalDataHandler.shared.getGear()
            self.rulebook = RulebookManager.shared.getOfflineVersion()
        }
    }

    private func hasEventWithoutPreregs() -> Bool {
        var hasEventWithoutPreregs = false
        for event in events ?? [] {
            if event.isInFuture() && eventPreregs[event.id] == nil {
                hasEventWithoutPreregs = true
                break
            }
        }
        return hasEventWithoutPreregs
    }

    private func finishedRequest(_ incrementalIndex: Int, _ source: String) {
        runOnMainThread {
            self.countReturned[incrementalIndex] = (self.countReturned[incrementalIndex] ?? 0) + 1
            globalPrintServiceLogs("DataManager - finished \(source) request \(self.countReturned[incrementalIndex] ?? 0) of \(self.targetCount[incrementalIndex] ?? 0)")
            if self.targetCount[incrementalIndex] ?? 0 == self.countReturned[incrementalIndex] ?? 0 {
                self.callbacks[incrementalIndex]?()
                // Reset values to save memory
                self.countReturned[incrementalIndex] = 0
                self.targetCount[incrementalIndex] = 0
                self.callbacks[incrementalIndex] = {}
            }
        }
    }
    
    func loadMockData() {
        typealias md = MockData1

        selectedEvent = md.event
        selectedChar = md.character
        selectedContactRequest = md.contact
        announcements = md.announcementsList.announcements
        currentAnnouncement = md.announcement
        player = md.player
        character = FullCharacterModel(md.character)
        events = md.events.events
        currentEvent = md.event
        awards = md.awards.awards
        intrigue = md.intrigue
        skills = [FullSkillModel(md.skill)]
        allPlayers = md.playerList.players
        allCharacters = md.characterListFullModel.characters
        charForSelectedPlayer = FullCharacterModel(md.character)
        contactRequests = md.contacts.contactRequests
        xpReductions = md.xpReductions.specialClassXpReductions
        eventPreregs = [1: md.preregs.eventPreregs]
        selectedCharacterXpReductions = md.xpReductions.specialClassXpReductions
        intrigueForSelectedEvent = md.intrigue
        selectedCharacterGear = md.gearList.charGear
        featureFlags = md.featureFlagList.results
        
        selectedPlayer = md.player
    }

}
