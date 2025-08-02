//
//  AdminView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI
import CodeScanner

struct AdminView: View {

    @ObservedObject var _dm = DataManager.shared

    @State var loadingPlayers: Bool = true
    @State var allPlayers = [PlayerModel]()

    @State var loadingCharacters: Bool = true
    @State var allCharacters = [CharacterModel]()

    @State var charactersWhoNeedBios = [CharacterModel]()
    @State var unapprovedBioText = ""

    @State var loadingEvents: Bool = true
    @State var events = [EventModel]()

    @State var loadingContacts: Bool = true
    @State var unreadContactsText = ""
    @State var contactRequests = [ContactRequestModel]()
    
    @State var researchProjects: [ResearchProjectModel] = []
    @State var loadingResearchProjects: Bool = true
    
    @State var loadingNPCs: Bool = true
    @State var npcs: [CharacterModel] = []
    
    @State var firstLoad = true

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    PullToRefresh(coordinateSpaceName: "pullToRefresh_AccountTab", spinnerOffsetY: -100, pullDownDistance: 150) {
                        self.reloadData()
                    }
                    VStack {
                        Text("Admin Tools")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        Text("Event Tools")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        EventToolsView(events: $events, loadingEvents: $loadingEvents)
                        Text("Player/Character Management")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        PlayerCharacterManagementView(allCharacters: $allCharacters, npcs: $npcs, loadingCharacters: $loadingCharacters, allPlayers: $allPlayers, loadingPlayers: $loadingPlayers, loadingNPCs: $loadingNPCs)
                        Text("Misc Administration")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        MiscAdminView(allCharacters: $allCharacters, loadingCharacters: $loadingCharacters, unapprovedBioText: $unapprovedBioText, charactersWhoNeedBios: $charactersWhoNeedBios, researchProjects: $researchProjects, loadingContacts: $loadingContacts, unreadContactsText: $unreadContactsText, contactRequests: $contactRequests, loadingResearchProjects: $loadingResearchProjects)
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            if firstLoad {
                firstLoad = false
                reloadData()
            }
        }
    }
    
    private func reloadData() {
        runOnMainThread {
            self.loadingPlayers = true
            self.loadingCharacters = true
            self.loadingEvents = true
            self.loadingContacts = true
            self.loadingResearchProjects = true
            self.loadingNPCs = true
            PlayerService.getAllPlayers { playerList in
                runOnMainThread {
                    self.allPlayers = playerList.players
                    self.loadingPlayers = false
                }
            } failureCase: { _ in
                runOnMainThread {
                    self.loadingPlayers = false
                }
            }
            CharacterService.getAllCharacters { characterList in
                runOnMainThread {
                    self.allCharacters = characterList.characters
                    self.charactersWhoNeedBios = self.allCharacters.filter({ c in
                        !c.approvedBio.boolValueDefaultFalse && !c.bio.isEmpty
                    })
                    self.unapprovedBioText = self.getUnapprovedBioCount()
                    self.loadingCharacters = false
                }
            } failureCase: { _ in
                runOnMainThread {
                    self.loadingCharacters = false
                }
            }
            EventManager.shared.getEvents(overrideLocal: true) { events in
                runOnMainThread {
                    self.loadingEvents = false
                    self.events = events.reversed()
                    OldDataManager.shared.events = events
                }
            }
            AdminService.getAllContactRequests { contactRequestList in
                runOnMainThread {
                    self.loadingContacts = false
                    self.contactRequests = self.sortContactRequests(contactRequestList)
                }
            } failureCase: { error in
                runOnMainThread {
                    self.loadingContacts = false
                }
            }
            OldDataManager.shared.load([.researchProjects], forceDownloadIfApplicable: true) {
                runOnMainThread {
                    self.researchProjects = OldDataManager.shared.researchProjects
                    self.loadingResearchProjects = false
                }
            }
            OldDataManager.shared.load([.featureFlags], forceDownloadIfApplicable: true)
            OldDataManager.shared.load([.npcs], forceDownloadIfApplicable: true) {
                runOnMainThread {
                    self.npcs = OldDataManager.shared.npcs
                    self.loadingNPCs = false
                }
            }
        }
    }

    func getUnapprovedBioCount() -> String {
        let count = self.charactersWhoNeedBios.count
        return count == 0 ? "" : count.stringValue
    }

    func sortContactRequests(_ contactRequestList: ContactRequestListModel) -> [ContactRequestModel] {
        let unsorted = contactRequestList.contactRequests
        let unread = unsorted.filter { crm in
            !crm.read.boolValueDefaultFalse
        }
        let read = unsorted.filter { crm in
            crm.read.boolValueDefaultFalse
        }
        var newList = [ContactRequestModel]()
        newList = unread.sorted(by: { f, s in
            f.fullName.caseInsensitiveCompare(s.fullName) == .orderedAscending
        })
        newList.append(contentsOf: read.sorted(by: { f, s in
            f.fullName.caseInsensitiveCompare(s.fullName) == .orderedAscending
        }))
        return newList
    }

}

struct EventToolsView: View {
    @ObservedObject var _dm = DataManager.shared

    @Binding var events: [EventModel]
    @Binding var loadingEvents: Bool

    var body: some View {
        VStack {
            NavArrowView(title: "Player Check-In") { _ in
                CheckInPlayerView()
            }
            NavArrowView(title: "Player Check-Out") { _ in
                CheckOutPlayerView()
            }
            NavArrowView(title: "View Preregistrations", loading: $loadingEvents) { _ in
                SelectEventForPreregView(events: events)
            }
            NavArrowView(title: "Event Management", loading: $loadingEvents) { _ in
                EventManagementView(events: $events)
            }
            NavArrowView(title: "Manage Intrigue", loading: $loadingEvents) { _ in
                SelectEventForIntrigueView(events: events)
            }
        }
    }
}

struct PlayerCharacterManagementView: View {
    @ObservedObject var _dm = DataManager.shared

    @Binding var allCharacters: [CharacterModel]
    @Binding var npcs: [CharacterModel]
    @Binding var loadingCharacters: Bool
    @Binding var allPlayers: [PlayerModel]
    @Binding var loadingPlayers: Bool
    @Binding var loadingNPCs: Bool

    var body: some View {
        VStack {
            NavArrowView(title: "Manage NPCs", loading: $loadingNPCs) { _ in
                AllNpcsListView(npcs: npcs, allowEdit: true)
            }
            NavArrowView(title: "Award Player", loading: $loadingPlayers) { _ in
                AwardPlayerView(players: allPlayers)
            }
            NavArrowView(title: "Award Character", loading: $loadingCharacters) { _ in
                AwardCharacterView(characters: allCharacters)
            }
            NavArrowView(title: "Give Class Xp Reduction", loading: $loadingCharacters) { _ in
                SelectCharacterForClassXpReducitonView(characters: allCharacters)
            }
            NavArrowView(title: "Manage Character Gear", loading: $loadingCharacters) { _ in
                SelectCharacterForGearManagementView(characters: allCharacters)
            }
            NavArrowView(title: "Update Player Password", loading: $loadingPlayers) { _ in
                ChangePasswordListView(players: allPlayers)
            }
        }
    }
}

struct MiscAdminView: View {
    @ObservedObject var _dm = DataManager.shared

    @Binding var allCharacters: [CharacterModel]
    @Binding var loadingCharacters: Bool
    @Binding var unapprovedBioText: String
    @Binding var charactersWhoNeedBios: [CharacterModel]
    @Binding var researchProjects: [ResearchProjectModel]
    
    @Binding var loadingContacts: Bool
    @Binding var unreadContactsText: String
    @Binding var contactRequests: [ContactRequestModel]
    @Binding var loadingResearchProjects: Bool
    
    var body: some View {
        VStack {
            NavArrowView(title: "Manage Research Projects") { _ in
                AllResearchProjectsListView(researchProjects: researchProjects, allowEdit: true).onDisappear {
                    runOnMainThread {
                        self.researchProjects = OldDataManager.shared.researchProjects
                    }
                }
            }
            NavArrowView(title: "Create Announcement") { _ in
                CreateAnnouncementView()
            }
            NavArrowView(title: "Approve Bios", loading: $loadingCharacters, notificationBubbleText: $unapprovedBioText) { _ in
                CharacterBioListView(charactersWhoNeedBiosApproved: $charactersWhoNeedBios)
            }
            NavArrowView(title: "Contact Requests", loading: $loadingContacts, notificationBubbleText: $unreadContactsText) { _ in
                ContactListView(contactRequests: $contactRequests)
            }
            NavArrowView(title: "Feature Flag Management", loading: OldDataManager.$shared.loadingFeatureFlags) { _ in
                FeatureFlagManagementView(featureFlags: OldDataManager.$shared.featureFlags)
            }
        }
    }
}


#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return AdminView(_dm: dm)
}
