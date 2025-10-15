//
//  AdminView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/13/23.
//

import SwiftUI

struct AdminView: View {

    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    PullToRefresh(coordinateSpaceName: "pullToRefresh_AdminTab", spinnerOffsetY: -100, pullDownDistance: 150) {
                        self.reloadData()
                    }
                    LoadingLayoutView {
                        VStack {
                            globalCreateTitleView("Admin Panel", DM: DM)
                            Text("Event Tools")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            EventToolsView()
                            Text("Player/Character Management")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            PlayerCharacterManagementView()
                            Text("Misc Administration")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            MiscAdminView()
                        }
                    }
                }.coordinateSpace(name: "pullToRefresh_AdminTab")
            }
        }.padding(16)
        .background(Color.lightGray)
    }
    
    private func reloadData() {
        runOnMainThread {
            DM.load()
        }
    }

}

struct EventToolsView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    var body: some View {
        VStack {
            let online = !DM.offlineMode
            if online {
                NavArrowView(title: "Player Check-In") { _ in
                    CheckInPlayerView()
                }
                NavArrowView(title: "Player Check-Out") { _ in
                    CheckOutPlayerView()
                }
            }
            NavArrowView(title: "View Preregistrations") { _ in
                EventsListView(title: "Select Event To View Preregistrations", destination: .prereg, additionalDestination: .none, events: DM.events)
            }
            NavArrowView(title: "Event Management") { _ in
                EventsListView(title: "Event Management", destination: .eventManagement, additionalDestination: .createNewEvent, events: DM.events)
            }
            if online {
                NavArrowView(title: "Manage Intrigue") { _ in
                    EventsListView(title: "Select Event To Manage Intrigue", destination: .intrigue, additionalDestination: .none, events: DM.events)
                }
            }
        }
    }
}

struct PlayerCharacterManagementView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    var body: some View {
        VStack {
            let online = !DM.offlineMode
            if online {
                NavArrowView(title: "Manage NPCs") { _ in
                    NPCListView(npcs: DM.getAllCharacters(.npc), title: "Select NPC To Manage", destination: .manage)
                }
                NavArrowView(title: "Award Player") { _ in
                    PlayersListView(title: "Select Player To Award", destination: .awardPlayer, players: DM.players)
                }
                NavArrowView(title: "Award Character") { _ in
                    CharactersListView(title: "Select Character To Award", destination: .awardCharacter, characters: DM.getAllCharacters(.standard))
                }
                NavArrowView(title: "Give Class Xp Reduction") { _ in
                    CharactersListView(title: "Select Character for Xp Reduction", destination: .selectSkillForXpReduction, characters: DM.getAllCharacters(.standard))
                }
            }
            NavArrowView(title: "Manage Character Gear") { _ in
                CharactersListView(title: "Select Character for Gear Management", destination: DM.offlineMode ? .viewGear : .manageGear, characters: DM.getAllCharacters(.standard))
            }
            if online {
                NavArrowView(title: "Update Player Password") { _ in
                    PlayersListView(title: "Select Player To Change Password For", destination: .changePass, players: DM.players)
                }
            }
        }
    }
}

struct MiscAdminView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    var body: some View {
        VStack {
            let online = !DM.offlineMode
            NavArrowView(title: "Manage Research Projects") { _ in
                ViewOrManageResearchProjectsView(researchProjects: DM.researchProjects, allowEdit: online)
            }
            if online {
                NavArrowView(title: "Create Announcement") { _ in
                    CreateAnnouncementView()
                }
                let chars = DM.getCharactersWhoNeedBiosApproved()
                NavArrowView(title: "Approve Bios", notificationBubbleText: .constant(chars.count == 0 ? "" : chars.count.stringValue)) { _ in
                    CharactersListView(title: "Select Character To Approve Bio For", destination: .approveBio, characters: chars)
                }
            }

            let contacts = DM.contactRequests.count(where: { !$0.read.boolValueDefaultFalse })
            NavArrowView(title: "Contact Requests", notificationBubbleText: .constant(contacts == 0 ? "" : contacts.stringValue)) { _ in
                ContactListView(contactRequests: DM.contactRequests)
            }
            NavArrowView(title: "Feature Flag Management") { _ in
                FeatureFlagManagementView(featureFlags: DM.featureFlags)
            }
            .padding(.bottom, 32)
        }
    }
}


//#Preview {
//    DataManager.shared.setDebugMode(true)
//    return AdminView()
//}
