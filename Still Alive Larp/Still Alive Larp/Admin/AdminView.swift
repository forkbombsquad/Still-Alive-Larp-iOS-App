//
//  AdminView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI
import CodeScanner

struct AdminView: View {

    @ObservedObject private var _dm = DataManager.shared

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
                        EventStuffView(events: $events, loadingEvents: $loadingEvents)
                        CheckInCheckOutGiveClassView(allCharacters: $allCharacters, loadingCharacters: $loadingCharacters)
                        NavArrowView(title: "Award Player", loading: $loadingPlayers) { _ in
                            AwardPlayerView(players: allPlayers)
                        }
                        CharStuffView(allCharacters: $allCharacters, loadingCharacters: $loadingCharacters)
                        NavArrowView(title: "Create Announcement") { _ in
                            CreateAnnouncementView()
                        }
                        NavArrowView(title: "Manage Intrigue", loading: $loadingEvents) { _ in
                            SelectEventForIntrigueView(events: events)
                        }
                        NavArrowView(title: "Approve Bios", loading: $loadingCharacters, notificationBubbleText: $unapprovedBioText) { _ in
                            CharacterBioListView(charactersWhoNeedBiosApproved: $charactersWhoNeedBios)
                        }
                        NavArrowView(title: "Contact Requests", loading: $loadingContacts, notificationBubbleText: $unreadContactsText) { _ in
                            ContactListView(contactRequests: $contactRequests)
                        }
                        NavArrowView(title: "Update Player Password", loading: $loadingPlayers) { _ in
                            ChangePasswordListView(players: allPlayers)
                        }
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

struct EventStuffView: View {
    @ObservedObject private var _dm = DataManager.shared

    @Binding var events: [EventModel]
    @Binding var loadingEvents: Bool

    var body: some View {
        VStack {
            NavArrowView(title: "View Preregistration", loading: $loadingEvents) { _ in
                SelectEventForPreregView(events: events)
            }
            NavArrowView(title: "Event Management", loading: $loadingEvents) { _ in
                EventManagementView(events: $events)
            }
        }
    }
}

struct CharStuffView: View {
    @ObservedObject private var _dm = DataManager.shared

    @Binding var allCharacters: [CharacterModel]
    @Binding var loadingCharacters: Bool

    var body: some View {
        VStack {
            NavArrowView(title: "Award Character", loading: $loadingCharacters) { _ in
                AwardCharacterView(characters: allCharacters)
            }
            NavArrowView(title: "Register Primary Firearm", loading: $loadingCharacters) { _ in
                SelectCharacterForPrimaryWeaponView(characters: allCharacters)
            }
            NavArrowView(title: "Manage Character Gear", loading: $loadingCharacters) { _ in
                SelectCharacterForGearManagementView(characters: allCharacters)
            }
        }
    }
}


struct CheckInCheckOutGiveClassView: View {
    @ObservedObject private var _dm = DataManager.shared

    @Binding var allCharacters: [CharacterModel]
    @Binding var loadingCharacters: Bool

    var body: some View {
        VStack {
            NavArrowView(title: "Player Check-In") { _ in
                CheckInPlayerView()
            }
            NavArrowView(title: "Player Check-Out") { _ in
                CheckOutPlayerView()
            }
            NavArrowView(title: "Give Class Xp Reduction", loading: $loadingCharacters) { _ in
                SelectCharacterForClassXpReducitonView(characters: allCharacters)
            }
        }
    }
}


struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}
