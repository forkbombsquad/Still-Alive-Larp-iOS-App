//
//  OldDataManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/30/23.
//

import SwiftUI

// TODO remove this completely

class OldDataManager: ObservableObject {

    enum DataManagerType {
        case player, character, announcements, events, awards, intrigue, skills, allPlayers, allCharacters, charForSelectedPlayer, contactRequests, eventAttendees, xpReductions, eventPreregs, selectedCharXpReductions, intrigueForSelectedEvent, selectedCharacterGear, rulebook, featureFlags, profileImage, plannedCharacters, npcs, researchProjects, eventAttendeesForSelectedEvent, skillCategories
    }

    @ObservedObject static var shared = OldDataManager()

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
            
            shared.allPlannedCharacters = []
            shared.loadingAllPlayers = true
            
            shared.npcs = []
            shared.loadingNpcs = true
            
            shared.researchProjects = []
            shared.loadingResearchProjects = true
            
            shared.eventAttendeesForEvent = []
            shared.loadingEventAttendeesForEvent = true
            
            shared.skillCategories = []
            shared.loadingSkillCategories = true
        }
    }

    private init() {}

    @Published private var loadCountIndex: Int = 0
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
    var debugMode = false {
        didSet {
            Constants.ServiceOperationMode.updateServiceMode(debugMode ? .test : .prod)
        }
    }

    @Published var actionState: Int? = 0

    @Published var selectedEvent: EventModel? = nil
    @Published var selectedChar: CharacterModel? = nil
    @Published var selectedContactRequest: ContactRequestModel? = nil
    @Published var checkinBarcodeModel: CheckInOutBarcodeModel? = nil
    @Published var checkoutBarcodeModel: PlayerCheckOutBarcodeModel? = nil

    @Published var announcements: [AnnouncementSubModel]? = nil
    @Published var currentAnnouncement: AnnouncementModel? = nil
    @Published var loadingAnnouncements: Bool = true

    @Published var player: PlayerModel? = nil
    @Published var loadingPlayer: Bool = true

    @Published var character: OldFullCharacterModel? = nil
    @Published var loadingCharacter = true

    @Published var events: [EventModel]? = nil
    @Published var currentEvent: EventModel? = nil
    @Published var loadingEvents: Bool = true

    @Published var awards: [AwardModel]? = nil
    @Published var loadingAwards: Bool = true

    @Published var intrigue: IntrigueModel? = nil
    @Published var loadingIntrigue: Bool = true

    @Published var skills: [OldFullSkillModel]? = nil
    @Published var loadingSkills: Bool = true

    @Published var allPlayers: [PlayerModel]? = nil
    @Published var loadingAllPlayers: Bool = true

    @Published var allCharacters: [CharacterModel]? = nil
    @Published var loadingAllCharacters: Bool = true

    @Published var charForSelectedPlayer: OldFullCharacterModel? = nil
    @Published var loadingCharForSelectedPlayer: Bool = true

    @Published var contactRequests: [ContactRequestModel]? = nil
    @Published var loadingContactRequests: Bool = true

    @Published var eventAttendeesForPlayer: [EventAttendeeModel]? = nil
    @Published var eventAttendeesForEvent: [EventAttendeeModel] = []
    @Published var loadingEventAttendees: Bool = true
    @Published var loadingEventAttendeesForEvent: Bool = true

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
    
    @Published var allPlannedCharacters: [CharacterModel] = []
    @Published var loadingAllPlannedCharacters: Bool = true
    
    @Published var npcs: [CharacterModel] = []
    @Published var loadingNpcs: Bool = true
    
    @Published var researchProjects: [ResearchProjectModel] = []
    @Published var loadingResearchProjects: Bool = true
    
    @Published var skillCategories: [SkillCategoryModel] = []
    @Published var loadingSkillCategories: Bool = true

    func load(_ types: [DataManagerType], forceDownloadIfApplicable: Bool = false, finished: @escaping () -> Void = {}) {
        guard !debugMode else {
            finished()
            return
        }
        runOnMainThread {
            let currentCountIndex = self.loadCountIndex
            self.loadCountIndex += 1
            self.targetCount[currentCountIndex] = types.count
            self.countReturned[currentCountIndex] = 0
            self.callbacks[currentCountIndex] = finished
            if self.targetCount[currentCountIndex] == 0 {
                self.callbacks[currentCountIndex]?()
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
                                self.finishedRequest(currentCountIndex, "Player Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.player = PlayerManager.shared.getPlayer()
                                self.loadingPlayer = false
                                self.finishedRequest(currentCountIndex, "Player Failure")
                            }
                        }
                    } else {
                        self.player = PlayerManager.shared.getPlayer()
                        self.loadingPlayer = false
                        self.finishedRequest(currentCountIndex, "Player From Memory")
                    }
                case .character:
                    self.loadingCharacter = true
                    CharacterManager.shared.fetchActiveCharacter(overrideLocal: forceDownloadIfApplicable) { character in
                        runOnMainThread {
                            self.character = character
                            self.loadingCharacter = false
                            self.finishedRequest(currentCountIndex, "Load Character")
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
                                        self.finishedRequest(currentCountIndex, "Announcement Success")
                                    }
                                } failureCase: { error in
                                    runOnMainThread {
                                        self.currentAnnouncement = nil
                                        self.loadingAnnouncements = false
                                        self.finishedRequest(currentCountIndex, "Announcement Failure")
                                    }
                                }
                            } else {
                                self.currentAnnouncement = nil
                                self.loadingAnnouncements = false
                                self.finishedRequest(currentCountIndex, "Announcements Failure")
                            }
                        }
                    } failureCase: { error in
                        runOnMainThread {
                            self.loadingAnnouncements = false
                            self.finishedRequest(currentCountIndex, "Announcements From Memory")
                        }
                    }

                case .events:
                    self.loadingEvents = true
                    EventManager.shared.getEvents(overrideLocal: forceDownloadIfApplicable) { eventList in
                        runOnMainThread {
                            self.events = eventList.inChronologicalOrder
                            self.currentEvent = self.events?.first
                            self.loadingEvents = false
                            self.finishedRequest(currentCountIndex, "Events Success")
                        }
                    }
                case .awards:
                    self.loadingAwards = true
                    if let pid = self.player?.id, self.awards == nil || forceDownloadIfApplicable {
                        AwardService.getAwardsForPlayer(pid) { awardList in
                            runOnMainThread {
                                self.awards = awardList.awards.reversed()
                                self.loadingAwards = false
                                self.finishedRequest(currentCountIndex, "Awards Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.loadingAwards = false
                                self.awards = nil
                                self.finishedRequest(currentCountIndex, "Awards Failure")
                            }
                        }
                    } else {
                        self.loadingAwards = false
                        self.finishedRequest(currentCountIndex, "Awards From Memory")
                    }
                case .intrigue:
                    self.loadingIntrigue = true
                    if self.events == nil && !self.loadingEvents {
                        self.intrigue = nil
                        self.loadingIntrigue = false
                        self.finishedRequest(currentCountIndex, "Intrigue (other) None")
                    } else if self.events != nil, let current = self.events?.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse }) {
                        IntrigueService.getIntrigue(current.id) { intrigue in
                            runOnMainThread {
                                self.loadingIntrigue = false
                                self.intrigue = intrigue
                                self.finishedRequest(currentCountIndex, "Intrigue (other) Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.intrigue = nil
                                self.loadingIntrigue = false
                                self.finishedRequest(currentCountIndex, "Intrigue (other) Failure")
                            }
                        }
                    } else {
                        self.intrigue = nil
                        self.loadingIntrigue = false
                        self.finishedRequest(currentCountIndex, "Intrigue (other) Nonex2")
                    }
                case .skills:
                    self.loadingSkills = true
                    SkillManager.shared.getSkills(overrideLocal: forceDownloadIfApplicable) { skills in
                        runOnMainThread {
                            self.skills = skills
                            self.loadingSkills = false
                            self.finishedRequest(currentCountIndex, "Skills Success")
                        }
                    }
                case .allPlayers:
                    self.loadingAllPlayers = true
                    if self.allPlayers == nil || forceDownloadIfApplicable {
                        PlayerService.getAllPlayers { playerList in
                            runOnMainThread {
                                self.allPlayers = playerList.players.filter({ $0.username.lowercased() != "googletestaccount@gmail.com" })
                                self.loadingAllPlayers = false
                                self.finishedRequest(currentCountIndex, "All Players Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.allPlayers = nil
                                self.loadingAllPlayers = false
                                self.finishedRequest(currentCountIndex, "All Players Failure")
                            }
                        }
                    } else {
                        self.loadingAllPlayers = false
                        self.finishedRequest(currentCountIndex, "All Players From Memory")
                    }
                case .allCharacters:
                    self.loadingAllCharacters = true
                    if (self.allCharacters == nil || forceDownloadIfApplicable) {
                        CharacterService.getAllCharacters { characterList in
                            runOnMainThread {
                                self.allCharacters = characterList.characters.filter({ $0.fullName.lowercased() != "google test" })
                                self.loadingAllCharacters = false
                                self.finishedRequest(currentCountIndex, "All Characters Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.allCharacters = nil
                                self.loadingAllCharacters = false
                                self.finishedRequest(currentCountIndex, "All Characters Failure")
                            }
                        }
                    } else {
                        self.loadingAllCharacters = false
                        self.finishedRequest(currentCountIndex, "All Characters From Memory")
                    }
                case .charForSelectedPlayer:
                    self.loadingCharForSelectedPlayer = true
                    if let player = self.selectedPlayer {
                        if self.charForSelectedPlayer == nil || forceDownloadIfApplicable || self.charForSelectedPlayer?.playerId != player.id {
                            CharacterManager.shared.getActiveCharacterForOtherPlayer(player.id) { character in
                                runOnMainThread {
                                    self.charForSelectedPlayer = character
                                    self.loadingCharForSelectedPlayer = false
                                    self.finishedRequest(currentCountIndex, "Char For Selected Player Success")
                                }
                            } failureCase: { error in
                                runOnMainThread {
                                    self.charForSelectedPlayer = nil
                                    self.loadingCharForSelectedPlayer = false
                                    self.finishedRequest(currentCountIndex, "Char For Selected Player Failure")
                                }
                            }
                        } else {
                            self.loadingCharForSelectedPlayer = false
                            self.finishedRequest(currentCountIndex, "Char For Selected Player From Memory")
                        }
                    } else {
                        self.charForSelectedPlayer = nil
                        self.loadingCharForSelectedPlayer = false
                        self.finishedRequest(currentCountIndex, "Char For Selected Player No Player")
                    }
                case .contactRequests:
                    self.loadingContactRequests = true
                    if self.contactRequests == nil || forceDownloadIfApplicable {
                        AdminService.getAllContactRequests { contactRequestList in
                            runOnMainThread {
                                self.contactRequests = contactRequestList.contactRequests
                                self.loadingContactRequests = false
                                self.finishedRequest(currentCountIndex, "Contact Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.contactRequests = nil
                                self.loadingContactRequests = false
                                self.finishedRequest(currentCountIndex, "Contact Failure")
                            }
                        }
                    } else {
                        self.loadingContactRequests = false
                        self.finishedRequest(currentCountIndex, "Contact From Memory")
                    }
                case .eventAttendees:
                    self.loadingEventAttendees = true
                    if let pid = self.player?.id, self.eventAttendeesForPlayer == nil || forceDownloadIfApplicable {
                        EventAttendeeService.getEventsForPlayer(pid) { attendeeList in
                            runOnMainThread {
                                self.eventAttendeesForPlayer = attendeeList.eventAttendees
                                self.loadingEventAttendees = false
                                self.finishedRequest(currentCountIndex, "Attendees Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.eventAttendeesForPlayer = nil
                                self.loadingEventAttendees = false
                                self.finishedRequest(currentCountIndex, "Attendees Failure")
                            }
                        }

                    } else {
                        self.loadingEventAttendees = false
                        self.finishedRequest(currentCountIndex, "Attendees From Memory")
                    }
                case .xpReductions:
                    self.loadingXpReductions = true
                    if let charId = self.character?.id, self.xpReductions == nil || forceDownloadIfApplicable {
                        SpecialClassXpReductionService.getXpReductionsForCharacter(charId) { xpReductions in
                            runOnMainThread {
                                self.xpReductions = xpReductions.specialClassXpReductions
                                self.loadingXpReductions = false
                                self.finishedRequest(currentCountIndex, "Xp Reductions Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.xpReductions = nil
                                self.loadingXpReductions = false
                                self.finishedRequest(currentCountIndex, "Xp Reductions Failure")
                            }
                        }

                    } else {
                        self.loadingXpReductions = false
                        self.finishedRequest(currentCountIndex, "Xp Reductions From Memory")
                    }
                case .eventPreregs:
                    self.loadingEventPreregs = true
                    if self.hasEventWithoutPreregs() || (forceDownloadIfApplicable && self.events.isNotNullOrEmpty) {
                        var count = 0
                        let max = self.events?.count ?? 0
                        for event in self.events ?? [] {
                            EventPreregService.getPreregsForEvent(event.id) { preregList in
                                runOnMainThread {
                                    self.eventPreregs[event.id] = preregList.eventPreregs
                                    count += 1
                                    if count == max {
                                        self.loadingEventPreregs = false
                                        self.finishedRequest(currentCountIndex, "Preregs Success")
                                    }
                                }
                            } failureCase: { error in
                                runOnMainThread {
                                    self.eventPreregs[event.id] = []
                                    count += 1
                                    if count == max {
                                        self.loadingEventPreregs = false
                                        self.finishedRequest(currentCountIndex, "Preregs Failure")
                                    }
                                }
                            }
                        }
                    } else {
                        self.loadingEventPreregs = false
                        self.finishedRequest(currentCountIndex, "Preregs From Memory or no events yet")
                    }
                case .selectedCharXpReductions:
                    self.loadingSelectedCharacterXpReductions = true
                    if let charId = self.selectedChar?.id, self.selectedCharacterXpReductions == nil || forceDownloadIfApplicable {
                        SpecialClassXpReductionService.getXpReductionsForCharacter(charId) { xpReductions in
                            runOnMainThread {
                                self.selectedCharacterXpReductions = xpReductions.specialClassXpReductions
                                self.loadingSelectedCharacterXpReductions = false
                                self.finishedRequest(currentCountIndex, "Selected Char Xp Reductions Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.selectedCharacterXpReductions = nil
                                self.loadingSelectedCharacterXpReductions = false
                                self.finishedRequest(currentCountIndex, "Selected Char Xp Reductions Failure")
                            }
                        }
                    } else {
                        self.loadingSelectedCharacterXpReductions = false
                        self.finishedRequest(currentCountIndex, "Selected Char Xp Reductions From Memory")
                    }
                case .intrigueForSelectedEvent:
                    self.loadingIntrigueForSelectedEvent = true
                    if let eid = self.selectedEvent?.id, self.intrigueForSelectedEvent == nil || forceDownloadIfApplicable {
                        IntrigueService.getIntrigue(eid) { intrigue in
                            runOnMainThread {
                                self.intrigueForSelectedEvent = intrigue
                                self.loadingIntrigueForSelectedEvent = false
                                self.finishedRequest(currentCountIndex, "Intrigue For Event Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.intrigueForSelectedEvent = nil
                                self.loadingIntrigueForSelectedEvent = false
                                self.finishedRequest(currentCountIndex, "Intrigue For Event Failure")
                            }
                        }

                    } else {
                        self.loadingIntrigueForSelectedEvent = false
                        self.finishedRequest(currentCountIndex, "Intrigue For Event From Memory")
                    }
                case .selectedCharacterGear:
                    self.loadingSelectedCharacterGear = true
                    if let cid = self.selectedChar?.id, self.selectedCharacterGear == nil || forceDownloadIfApplicable {
                        GearService.getAllGearForCharacter(characterId: cid) { gearListModel in
                            runOnMainThread {
                                self.selectedCharacterGear = gearListModel.charGear
                                self.loadingSelectedCharacterGear = false
                                self.finishedRequest(currentCountIndex, "Selected Char Gear Success")
                                // Store gear in local data
                                if self.player != nil && self.selectedChar?.playerId == self.player?.id {
                                    OldLocalDataHandler.shared.storeGear(gearListModel)
                                }
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.selectedCharacterGear = nil
                                self.loadingSelectedCharacterGear = false
                                self.finishedRequest(currentCountIndex, "Selected Char Gear Failure")
                            }
                        }

                    } else {
                        self.loadingSelectedCharacterGear = false
                        self.finishedRequest(currentCountIndex, "Selected Char Gear From Memory")
                    }
                case .rulebook:
                    self.loadingRulebook = true
                    if self.rulebook == nil || forceDownloadIfApplicable {
                        RulebookUtils.shared.getOnlineVersion { rulebook in
                            runOnMainThread {
                                self.rulebook = rulebook
                                self.loadingRulebook = false
                                self.finishedRequest(currentCountIndex, "Rulebook Success and/or Fail")
                            }
                        }
                    } else {
                        self.loadingRulebook = false
                        self.finishedRequest(currentCountIndex, "Rulebook From Memory")
                    }
                case .featureFlags:
                    self.loadingFeatureFlags = true
                    if self.featureFlags.isEmpty || forceDownloadIfApplicable {
                        FeatureFlagService.getAllFeatureFlags { featureFlags in
                            runOnMainThread {
                                self.featureFlags = featureFlags.results
                                self.loadingFeatureFlags = false
                                self.finishedRequest(currentCountIndex, "Feature Flag Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.featureFlags = []
                                self.loadingFeatureFlags = false
                                self.finishedRequest(currentCountIndex, "Feature Flag Failure")
                            }
                        }

                    } else {
                        self.loadingFeatureFlags = false
                        self.finishedRequest(currentCountIndex, "Feature Flags From Memory")
                    }
                case .profileImage:
                    self.loadingProfileImage = true
                    if self.profileImage == nil || forceDownloadIfApplicable || self.selectedPlayer?.id != self.profileImage?.playerId {
                        self.profileImage = nil
                        ProfileImageService.getProfileImage(self.selectedPlayer?.id ?? -1) { profileImage in
                            runOnMainThread {
                                self.profileImage = profileImage
                                self.loadingProfileImage = false
                                self.finishedRequest(currentCountIndex, "Profile Image Success")
                            }
                            
                        } failureCase: { error in
                            runOnMainThread {
                                self.profileImage = nil
                                self.loadingProfileImage = false
                                self.finishedRequest(currentCountIndex, "Profile Image Failure")
                            }
                        }

                    } else {
                        self.loadingProfileImage = false
                        self.finishedRequest(currentCountIndex, "Profile Image From Memory")
                    }
                case .plannedCharacters:
                    self.loadingAllPlannedCharacters = true
                    if self.allPlannedCharacters.isEmpty || forceDownloadIfApplicable {
                        CharacterService.getAllPlayerCharactersForCharacterType(self.player?.id ?? -1, characterType: Constants.CharacterTypes.planner) { charList in
                            runOnMainThread {
                                self.allPlannedCharacters = charList.characters
                                self.loadingAllPlannedCharacters = false
                                self.finishedRequest(currentCountIndex, "Planned Character Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.allPlannedCharacters = []
                                self.loadingAllPlannedCharacters = false
                                self.finishedRequest(currentCountIndex, "Planned Character Failure")
                            }
                        }

                    } else {
                        self.loadingAllPlannedCharacters = false
                        self.finishedRequest(currentCountIndex, "Planned Characters From Memory")
                    }
                case .npcs:
                    self.loadingNpcs = true
                    if self.npcs.isEmpty || forceDownloadIfApplicable {
                        CharacterService.getAllNPCCharacters { characterList in
                            runOnMainThread {
                                self.npcs = characterList.characters
                                self.loadingNpcs = false
                                self.finishedRequest(currentCountIndex, "NPCs Success")
                                self.storeNPCs()
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.npcs = []
                                self.loadingNpcs = false
                                self.finishedRequest(currentCountIndex, "NPCs Failure")
                            }
                        }

                    } else {
                        self.loadingNpcs = false
                        self.finishedRequest(currentCountIndex, "NPCs From Memory")
                    }
                case .researchProjects:
                    self.loadingResearchProjects = true
                    if self.researchProjects.isEmpty || forceDownloadIfApplicable {
                        ResearchProjectService.getAllResearchProjects { projectList in
                            runOnMainThread {
                                self.researchProjects = projectList.researchProjects
                                self.loadingResearchProjects = false
                                self.finishedRequest(currentCountIndex, "Research Projects Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.researchProjects = []
                                self.loadingResearchProjects = false
                                self.finishedRequest(currentCountIndex, "Research Projects Failure")
                            }
                        }

                    } else {
                        self.loadingResearchProjects = false
                        self.finishedRequest(currentCountIndex, "Research Projects From Memory")
                    }
                case .eventAttendeesForSelectedEvent:
                    self.loadingEventAttendeesForEvent = true
                    if (self.eventAttendeesForEvent.isEmpty || forceDownloadIfApplicable), let se = self.selectedEvent {
                        EventAttendeeService.getEventAttendeesForEvent(se.id) { attendeeList in
                            runOnMainThread {
                                self.eventAttendeesForEvent = attendeeList.eventAttendees
                                self.loadingEventAttendeesForEvent = false
                                self.finishedRequest(currentCountIndex, "Event Attendees For Event Success")
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.eventAttendeesForEvent = []
                                self.loadingEventAttendeesForEvent = false
                                self.finishedRequest(currentCountIndex, "Event Attendees For Event Failure")
                            }
                        }

                    } else {
                        self.loadingEventAttendeesForEvent = false
                        self.finishedRequest(currentCountIndex, "Event Attendees For Event From Memory or selected event null")
                    }
                case .skillCategories:
                    self.loadingSkillCategories = true
                    if self.skillCategories.isEmpty || forceDownloadIfApplicable {
                        SkillCategoryService.getAllSkillCategories { skillCategories in
                            runOnMainThread {
                                self.skillCategories = skillCategories.results
                                self.loadingSkillCategories = false
                                self.finishedRequest(currentCountIndex, "Skill Categories Success")
                                OldLocalDataHandler.shared.storeSkillCategories(skillCategories)
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.skillCategories = []
                                self.loadingSkillCategories = false
                                self.finishedRequest(currentCountIndex, "Skill Categories Failure")
                            }
                        }

                    } else {
                        self.loadingSkillCategories = false
                        self.finishedRequest(currentCountIndex, "Skill Categores From Memory")
                    }
                }
            }
        }
    }
    
    func storeNPCs() {
        var fullNPCs: [OldFullCharacterModel] = []
        var counter = 0
        self.npcs.forEach { npc in
            CharacterManager.shared.fetchFullCharacter(characterId: npc.id) { fullChar in
                if let fullNPC = fullChar {
                    fullNPCs.append(fullNPC)
                }
                counter += 1
                if counter == self.npcs.count {
                    OldLocalDataHandler.shared.storeNPCs(fullNPCs)
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

    private func hasEventWithoutPreregs() -> Bool {
        var hasEventWithoutPreregs = false
        for event in events ?? [] {
            if eventPreregs[event.id] == nil {
                hasEventWithoutPreregs = true
                break
            }
        }
        return hasEventWithoutPreregs
    }

    private func finishedRequest(_ currentCountIndex: Int, _ source: String) {
        runOnMainThread {
            let cr = self.countReturned[currentCountIndex] ?? 0
            let tc = self.targetCount[currentCountIndex] ?? 0
            self.countReturned[currentCountIndex] = cr + 1
            globalPrintServiceLogs("DataManager - finished \(source) request \(cr + 1) of \(tc)")
            if tc == (cr + 1) {
                self.callbacks[currentCountIndex]?()
                // Reset values to save memory
                self.countReturned[currentCountIndex] = 0
                self.targetCount[currentCountIndex] = 0
                self.callbacks[currentCountIndex] = {}
            }
        }
    }
    
    func loadMockData() {
        let md = getMockData()

        selectedEvent = md.event()
        selectedChar = md.character()
        selectedContactRequest = md.contact()
        announcements = md.announcementsList.announcements
        currentAnnouncement = md.announcement
        player = md.player()
        character = md.fullCharacters().first
        events = md.events.events
        currentEvent = md.event()
        awards = md.awards.awards
        intrigue = md.intrigue()
        skills = md.fullSkills()
        allPlayers = md.playerList.players
        allCharacters = md.characterListFullModel.characters
        charForSelectedPlayer = md.fullCharacters().first
        contactRequests = md.contacts.contactRequests
        xpReductions = md.xpReductions.specialClassXpReductions
        eventPreregs = md.preregs.getAsDict()
        selectedCharacterXpReductions = md.xpReductions.specialClassXpReductions
        intrigueForSelectedEvent = md.intrigue()
        selectedCharacterGear = md.gearList.charGear
        featureFlags = md.featureFlagList.results
        rulebook = md.rulebook
        eventAttendeesForPlayer = md.eventAttendees.eventAttendees
        
        selectedPlayer = md.player()
    }

}
