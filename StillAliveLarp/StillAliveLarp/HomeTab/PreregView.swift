//
//  PreregView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/15/23.
//

import SwiftUI

struct PreregView: View {
    @ObservedObject var _dm = DataManager.shared

    @State var loadingSubmit = false
    
    let event: EventModel
    let prereg: EventPreregModel?
    let player: PlayerModel?
    let character: CharacterModel?

    @State private var selectedChar: String = "NPC"
    @State var regType: String = EventRegType.premium.getAttendingText()

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                VStack {
                    ScrollView {
                        VStack {
                            Text(prereg == nil ? "Preregistration" : "Update Preregistration")
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(alignment: .center)
                                .padding([.bottom], 16)
                            Divider()
                            KeyValueView(key: "Player", value: player?.fullName ?? "")
                            
                            StyledPickerView(title: "Character", selection: $selectedChar, options: character == nil ? ["NPC"] : ["NPC", character!.fullName]) { _ in }
                            Divider()
                            
                            KeyValueView(key: "Event", value: event.title).padding(.top, 16)
                            
                            StyledPickerView(title: "Attendance and Donation", selection: $regType, options: [EventRegType.notPrereged.getAttendingText(), EventRegType.free.getAttendingText(), EventRegType.basic.getAttendingText(), EventRegType.premium.getAttendingText()]) { _ in }
                            
                            Text("**Free Entry - $0** Still Alive is completely free to play! However, there are 2 tiers of donations that you can give which afford you multiple benefits!\n\n**Basic Donation Tier - $15** if you donate $15, you are able to play the game with your PC if you wish. Playing as a PC, you will earn 1xp. If you choose to play as an NPC, you will earn 2xp. If you choose this tier, you will need to provide your own food.\n\n**Premium Donation Tier - $25+** if you donate at least $25, you gain all the benefits of the Basic Donation Tier as well as 1 Meal Ticket to the COmmander's Feast and 1 free Raffle Ticket for The Raffle at the end of the event. If you NPC for the event along with your usual 2xp, you get 2 free raffle tickets instead of 1.").padding(.top, 16)
                            
                        }
                    }
                    LoadingButtonView($loadingSubmit, width: gr.size.width - 32, buttonText: prereg == nil ? "Submit" : "Update") {
                        loadingSubmit = true
                        if prereg == nil {
                            // create
                            let preregModel = EventPreregCreateModel(playerId: player?.id ?? -1, characterId: selectedChar == "NPC" ? nil : character?.id ?? -1, eventId: event.id, regType: getEventRegType())
                            EventPreregService.preregPlayer(preregModel) { _ in
                                runOnMainThread {
                                    self.loadingSubmit = false
                                    AlertManager.shared.showSuccessAlert("Preregistration Created") {
                                        runOnMainThread {
                                            self.mode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            } failureCase: { error in
                                loadingSubmit = false
                            }
                        } else if let p = prereg {
                            // update
                            let preregModel = EventPreregModel(id: p.id, playerId: p.playerId, characterId: selectedChar == "NPC" ? nil : character?.id ?? -1, eventId: p.eventId, regType: getEventRegType().rawValue)
                            EventPreregService.updatePrereg(preregModel) { _ in
                                runOnMainThread {
                                    self.loadingSubmit = false
                                    AlertManager.shared.showSuccessAlert("Preregistration Updated") {
                                        runOnMainThread {
                                            self.mode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            } failureCase: { error in
                                loadingSubmit = false
                            }

                        }
                    }
                    .padding(.top, 8)
                }
            }

        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear() {
            if let prereg = prereg {
                self.selectedChar = prereg.getCharId() == nil ? "NPC" : (character?.fullName ?? "NPC")
                self.regType = prereg.eventRegType.getAttendingText()
            } else if let character = character {
                self.selectedChar = character.fullName
            }
        }
    }

    func getEventRegType() -> EventRegType {
        switch regType {
        case EventRegType.notPrereged.getAttendingText(): return .notPrereged
        case EventRegType.free.getAttendingText(): return .free
        case EventRegType.basic.getAttendingText(): return .basic
        case EventRegType.premium.getAttendingText(): return .premium
            default: return .notPrereged
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return PreregView(_dm: dm, event: md.events.events.first!, prereg: nil, player: md.player(id: 2), character: md.character(id: 2))
}
