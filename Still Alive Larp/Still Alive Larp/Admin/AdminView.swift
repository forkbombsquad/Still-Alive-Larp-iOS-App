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

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
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
                        PlayerCharacterManagementView(allCharacters: $allCharacters, loadingCharacters: $loadingCharacters, allPlayers: $allPlayers, loadingPlayers: $loadingPlayers)
                        Text("Misc Administration")
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        MiscAdminView(allCharacters: $allCharacters, loadingCharacters: $loadingCharacters, unapprovedBioText: $unapprovedBioText, charactersWhoNeedBios: $charactersWhoNeedBios, loadingContacts: $loadingContacts, unreadContactsText: $unreadContactsText, contactRequests: $contactRequests)
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            self.loadingPlayers = true
            self.loadingCharacters = true
            self.loadingEvents = true
            self.loadingContacts = true
            PlayerService.getAllPlayers { playerList in
                self.allPlayers = playerList.players
                self.loadingPlayers = false
            } failureCase: { _ in
                self.loadingPlayers = false
            }
            CharacterService.getAllCharacters { characterList in
                self.allCharacters = characterList.characters
                self.charactersWhoNeedBios = self.allCharacters.filter({ c in
                    !c.approvedBio.boolValueDefaultFalse && !c.bio.isEmpty
                })
                self.unapprovedBioText = self.getUnapprovedBioCount()
                self.loadingCharacters = false
            } failureCase: { _ in
                self.loadingCharacters = false
            }
            EventManager.shared.getEvents(overrideLocal: true) { events in
                self.loadingEvents = false
                self.events = events.reversed()
            }
            AdminService.getAllContactRequests { contactRequestList in
                self.loadingContacts = false
                self.contactRequests = self.sortContactRequests(contactRequestList)
            } failureCase: { error in
                self.loadingContacts = false
            }
            DataManager.shared.load([.featureFlags], forceDownloadIfApplicable: true)
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
            NavArrowView(title: "View Preregistration", loading: $loadingEvents) { _ in
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
    @Binding var loadingCharacters: Bool
    @Binding var allPlayers: [PlayerModel]
    @Binding var loadingPlayers: Bool

    var body: some View {
        VStack {
            NavArrowView(title: "Manage NPCs", loading: $loadingCharacters) { _ in
                // TODO change the loading to be loadingNPCs and create destination view. Don't forget to add to load onAppear
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
                // TODO probably need to change something here
                SelectCharacterForGearManagementView(characters: allCharacters)
            }
            NavArrowView(title: "Refund Skills", loading: $loadingCharacters) { _ in
                // TODO
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
    
    @Binding var loadingContacts: Bool
    @Binding var unreadContactsText: String
    @Binding var contactRequests: [ContactRequestModel]
    
    var body: some View {
        VStack {
            NavArrowView(title: "Manage Research Projects") { _ in
                // TODO don't forget to add loading
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
            NavArrowView(title: "Feature Flag Management", loading: DataManager.$shared.loadingFeatureFlags) { _ in
                FeatureFlagManagementView(featureFlags: DataManager.$shared.featureFlags)
            }
        }
    }
}


#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return AdminView(_dm: dm)
}
