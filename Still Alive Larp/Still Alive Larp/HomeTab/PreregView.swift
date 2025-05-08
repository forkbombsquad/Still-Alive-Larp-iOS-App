//
//  PreregView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/15/23.
//

import SwiftUI

struct PreregView: View {
    @ObservedObject var _dm = DataManager.shared

    @State var loading = true
    @State var loadingSubmit = false

    @State private var charName: String = "NPC"
    @State private var regTypeOptions = ["Not Attending", "Free Entry", "Basic Donation Tier ($15)", "Premium Donation Tier ($25 or more)"]
    @State var regType: String = "Premium Donation Tier ($25 or more)"

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        if let ev = DataManager.shared.selectedEvent {
                            let prereg = getExistingPrereg(ev: ev)
                            Text(prereg == nil ? "Preregistration" : "Update Preregistration")
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(alignment: .center)
                                .padding([.bottom], 16)
                            if loading {
                                ProgressView()
                            } else {
                                Divider()
                                KeyValueView(key: "Player", value: DataManager.shared.player!.fullName)
                                if DataManager.shared.character != nil {
                                    Picker(selection: $charName, label: Text("Character")) {
                                        ForEach(getCharNameOptions(), id: \.self) { type in
                                            Text(type)
                                        }
                                    }
                                    .pickerStyle(.segmented).padding(.top, 32)
                                }
                                KeyValueView(key: "Character", value: charName).padding(.top, 8)
                                KeyValueView(key: "Event", value: ev.title).padding(.top, 16)

                                Picker(selection: $regType, label: Text("Select Attendance and Donation Type")) {
                                    ForEach(regTypeOptions, id: \.self) { type in
                                        Text(type)
                                    }
                                }
                                .pickerStyle(.segmented).pickerStyle(SegmentedPickerStyle()).padding(.top, 32)

                                KeyValueView(key: "Select Attendance and Donation Type", value: regType, showDivider: false)
                                    .padding(.top, 8)

                                Text("Free Tier - Still Alive is completely free to play, but you'll receive several benefits if you give a donation, including the ability to earn experience and play as a personalized character!\n\nBasic Donation Tier - $15 (If you donate $15, you are able to play the game with a personal character and earn experience to take skills from the skill tree (NPC characters at this tier will earn double the experience of a PC character!) If you choose this option, you will need to provide your own food.)\n\nPremium Donation Tier - $25 or more (If you donate at least $25, you gain all the benefits of the Basic Donation Tier as well as 1 Meal Ticket to the Commander's Feast and 1 free Raffle Ticket for The Raffle at the end of the event.)").padding(.top, 16)

                                LoadingButtonView($loadingSubmit, width: gr.size.width - 32, buttonText: prereg == nil ? "Submit" : "Update") {
                                    loadingSubmit = true
                                    if prereg == nil {
                                        // create
                                        let preregModel = EventPreregCreateModel(playerId: DataManager.shared.player!.id, characterId: charName == "NPC" ? nil : DataManager.shared.character?.id, eventId: ev.id, regType: getEventRegType())
                                        EventPreregService.preregPlayer(preregModel) { _ in
                                            runOnMainThread {
                                                self.loadingSubmit = false
                                                DataManager.shared.load([.eventPreregs], forceDownloadIfApplicable: true)
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
                                        let preregModel = EventPreregModel(id: p.id, playerId: p.playerId, characterId: charName == "NPC" ? nil : DataManager.shared.character?.id, eventId: p.eventId, regType: getEventRegType().rawValue)
                                        EventPreregService.updatePrereg(preregModel) { _ in
                                            runOnMainThread {
                                                self.loadingSubmit = false
                                                DataManager.shared.load([.eventPreregs], forceDownloadIfApplicable: true)
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
                                .padding(.top, 16)
                            }
                        }
                    }
                }
            }

        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            self.loading = true
            DataManager.shared.selectedEvent = DataManager.shared.currentEvent
            DataManager.shared.load([.player, .character, .eventPreregs]) {
                self.loading = false
            }
        }
    }

    func getExistingPrereg(ev: EventModel?) -> EventPreregModel? {
        if let ev = ev, let preregs = DataManager.shared.eventPreregs[ev.id] {
            return preregs.first(where: { $0.playerId == DataManager.shared.player?.id })
        } else {
            return nil
        }
    }

    func getCharNameOptions() -> [String] {
        return ["NPC", DataManager.shared.character?.fullName ?? ""]
    }

    func getEventRegType() -> EventRegType {
        switch regType {
            case "Not Attending": return .notPrereged
            case "Free Entry": return .free
            case "Basic Donation Tier ($15)": return .basic
            case "Premium Donation Tier ($25 or more)": return .premium
            default: return .notPrereged
        }
    }

    func getStringForRegType(_ regType: EventRegType) -> String {
        switch regType {
            case .notPrereged: return "Not Attending"
            case .free: return "Free Entry"
            case .basic: return "Basic Donation Tier ($15)"
            case .premium: return "Premium Donation Tier ($25 or more)"
        }
    }
}
