//
//  ManageEventView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct ManageEventView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var event: FullEventModel

    @State var loading: Bool = false
    
    @State var foodRequired = "2"
    @State var foodCollected = ""

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { gr in
                ScrollView {
                    VStack(alignment: .center) {
                        globalCreateTitleView("Manage Event", DM: DM)
                        Divider()
                        KeyValueView(key: "Title", value: event.title)
                        KeyValueView(key: "Date", value: event.date.yyyyMMddToMonthDayYear())
                        KeyValueView(key: "Start Time", value: event.startTime)
                        KeyValueView(key: "End Time", value: event.endTime)
                        KeyValueView(key: "Is Started", value: event.isStarted)
                        KeyValueView(key: "Is Finished", value: event.isFinished)
                        KeyValueView(key: "Description", value: event.description)
                    }
                    if !DM.offlineMode {
                        NavArrowViewRed(title: "Edit Event Details") {
                            CreateEditEventView(event: event)
                        }.padding(.top, 16)
                    }
                    NavArrowViewBlue(title: "View Attendees") {
                        ViewEventAttendeesView(event: event)
                    }.padding(.top, 8)
                    if !event.isFinished && !DM.offlineMode {
                        LoadingButtonView($loading, width: gr.size.width - 32, buttonText: event.isStarted ? "Finish Event" : "Start Event") {
                            self.loading = true
                            var started = false
                            if !event.isStarted {
                                event.isStarted = true
                                started = true
                            } else {
                                event.isFinished = true
                            }
                            AdminService.updateEvent(event.baseModel()) { updatedEvent in
                                runOnMainThread {
                                    self.event.isStarted = updatedEvent.isStarted.boolValueDefaultFalse
                                    self.event.isFinished = updatedEvent.isFinished.boolValueDefaultFalse
                                    if started {
                                        self.handleEventStart()
                                    } else {
                                        self.promptForRaffleAward()
                                    }
                                }
                            } failureCase: { error in
                                self.loading = false
                            }

                        }.padding(.top, 16)
                    }
                }
            }

        }.padding(16)
        .background(Color.lightGray)
    }

    private func handleEventStart() {
        let commanderDavis = DM.getAllCharacters().first(where: { $0.id == Constants.SpecificCharacterIds.commanderDavis })
        let materialsMessage = """
        Materials Gathered By NPCs over the past month that are for sale in the camp store:

        Wood: \(commanderDavis?.woodSupplies ?? 0)
        Metal: \(commanderDavis?.metalSupplies ?? 0)
        Cloth: \(commanderDavis?.clothSupplies ?? 0)
        Tech: \(commanderDavis?.techSupplies ?? 0)
        Medical: \(commanderDavis?.medicalSupplies ?? 0)
        """

        alertManager.showOkAlert("Materials For Sale!", message: materialsMessage, onOkAction: {
            DM.load()
            alertManager.showOkAlert("Event Started", onOkAction: {
                runOnMainThread {
                    self.loading = false
                    self.mode.wrappedValue.dismiss()
                }
            })
        })
    }

    private func promptForRaffleAward() {
        alertManager.showDynamicAlert(model: CustomAlertModel(title: "Award Raffle Winner?", message: "Players: Xp, Free Tier 1 Skills, Prestige Points\nCharacters: Infection, Ammo, Materials", textFields: [], checkboxes: [], verticalButtons: [], buttons: [
            AlertButton(title: "Continue", onPress: {
                self.finishEventFlowPromptForFood()
            }),
            AlertButton(title: "Character", onPress: {
                // TODO: Launch character award selection
                self.finishEventFlowPromptForFood()
            }),
            AlertButton(title: "Player", onPress: {
                // TODO: Launch player award selection
                self.finishEventFlowPromptForFood()
            })
        ]))
    }

    private func finishEventFlowPromptForFood() {

        alertManager.showDynamicAlert(model: CustomAlertModel(
            title: "How Much Food Was Collected?",
            textFields: [
                AlertTextField(placeholder: "Food Required Per Player (default: 2)", value: $foodRequired),
                AlertTextField(placeholder: "Food Collected", value: $foodCollected)
            ],
            checkboxes: [],
            verticalButtons: [],
            buttons: [
                AlertButton(title: "Submit", onPress: {
                    let req = Double(foodRequired) ?? 2.0
                    let food = Int(foodCollected) ?? 0
                    self.processFoodCollection(foodRequired: req, foodCollected: food)
                }),
                AlertButton(title: "Skip", onPress: {
                    finishEventFlow()
                })
            ]
        ))
    }

    private func processFoodCollection(foodRequired: Double, foodCollected: Int) {
        let attendeeCount = event.attendees.count
        let totalFoodRequired = Int(ceil(Double(attendeeCount) * foodRequired))
        let percentagePerFood = 100.0 / Double(totalFoodRequired)
        let allNpcs = DM.getAllCharacters(.npc).filter { $0.isAlive }

        if foodCollected == totalFoodRequired {
            // AT THRESHOLD - No bonus or penalty
            zeroOutCommanderDavisMaterials {
                alertManager.showOkAlert(
                    "Food Threshold Reached!",
                    message: "No additional bonuses or penalties!\n\nFood Donated: \(foodCollected)\nFood Required: \(totalFoodRequired)",
                    onOkAction: {
                        finishEventFlow()
                    }
                )
            }
        } else if foodCollected > totalFoodRequired {
            // ABOVE THRESHOLD
            let npcGathered = getNPCGatheredMaterials(npcs: allNpcs)
            alertManager.showOkAlert(
                "Food Threshold Exceeded!",
                message: npcGathered.getPrintString(),
                onOkAction: {
                    self.updateCommanderDavisMaterials(wood: npcGathered.wood, metal: npcGathered.metal, cloth: npcGathered.cloth, tech: npcGathered.tech, medical: npcGathered.medical) {
                        self.handleNPCAttraction(npcs: allNpcs, food: foodCollected, totalFoodRequired: totalFoodRequired, percentagePerFood: percentagePerFood)
                    }
                }
            )
        } else {
            // BELOW THRESHOLD
            zeroOutCommanderDavisMaterials {
                handleNPCDeath(npcs: allNpcs, totalFoodRequired: totalFoodRequired, foodCollected: foodCollected, percentagePerFood: percentagePerFood)
            }
        }
    }

    private func zeroOutCommanderDavisMaterials(onCompletion: @escaping () -> Void) {
        updateCommanderDavisMaterials(wood: 0, metal: 0, cloth: 0, tech: 0, medical: 0, onCompletion: onCompletion)
    }

    private func updateCommanderDavisMaterials(wood: Int, metal: Int, cloth: Int, tech: Int, medical: Int, onCompletion: @escaping () -> Void) {
        guard let cm = DM.getAllCharacters().first(where: { $0.id == Constants.SpecificCharacterIds.commanderDavis }) else {
            onCompletion()
            return
        }
        let updated = CharacterModel(id: cm.id, fullName: cm.fullName, startDate: cm.startDate, isAlive: cm.isAlive.stringValue, deathDate: cm.deathDate, infection: cm.infection.stringValue, bio: cm.bio, approvedBio: cm.approvedBio.stringValue, bullets: cm.bullets.stringValue, megas: cm.megas.stringValue, rivals: cm.rivals.stringValue, rockets: cm.rockets.stringValue, bulletCasings: cm.bulletCasings.stringValue, clothSupplies: cloth.stringValue, woodSupplies: wood.stringValue, metalSupplies: metal.stringValue, techSupplies: tech.stringValue, medicalSupplies: medical.stringValue, armor: cm.armor, unshakableResolveUses: cm.unshakableResolveUses.stringValue, mysteriousStrangerUses: cm.mysteriousStrangerUses.stringValue, playerId: cm.playerId, characterTypeId: cm.characterTypeId)

        AdminService.updateCharacter(updated) { _ in
            runOnMainThread {
                DM.load()
                onCompletion()
            }
        } failureCase: { _ in
            runOnMainThread {
                DM.load()
                onCompletion()
            }
        }
    }

    private func getNPCGatheredMaterials(npcs: [FullCharacterModel]) -> NPCGatheredMaterials {
        var ngm = NPCGatheredMaterials()
        for _ in npcs {
            ngm.addNew(roll: roll1to100())
        }
        return ngm
    }

    private func handleNPCDeath(npcs: [FullCharacterModel], totalFoodRequired: Int, foodCollected: Int, percentagePerFood: Double) {
        let chanceOfDeath = Int(ceil(Double(totalFoodRequired - foodCollected) * percentagePerFood))
        var rollsMessage = ""
        var deadNPC: FullCharacterModel? = nil

        for npc in npcs.shuffled() {
            let roll = roll1to100()
            if roll <= chanceOfDeath {
                rollsMessage += "\(npc.fullName) DIED OF STARVATION! (\(roll)% ≤ \(chanceOfDeath)%)"
                deadNPC = npc
            } else {
                rollsMessage += "\(npc.fullName) Survived (\(roll)% > \(chanceOfDeath)%"
            }
            if deadNPC != nil {
                break
            } else {
                rollsMessage += "\n"
            }
        }

        let title = deadNPC != nil ? "STARVATION!" : "Everyone Survived!"
        alertManager.showOkAlert(title, message: rollsMessage, onOkAction: {
            if let npc = deadNPC {
                self.killNPC(npc)
            } else {
                self.finishEventFlow()
            }
        })
    }

    private func killNPC(_ npc: FullCharacterModel) {
        var updated = npc
        updated.isAlive = false

        AdminService.updateCharacter(updated.baseModel()) { _ in
            runOnMainThread {
                DM.load()
                self.finishEventFlow()
            }
        } failureCase: { _ in
            runOnMainThread {
                self.finishEventFlow()
            }
        }
    }

    private func handleNPCAttraction(npcs: [FullCharacterModel], food: Int, totalFoodRequired: Int, percentagePerFood: Double) {
        let maxNpcs = DM.campStatus?.npcSlots ?? 10

        if npcs.count >= maxNpcs {
            alertManager.showOkAlert(
                "NPC Slots Full!",
                message: "You cannot attract any more NPCs without increasing the NPC capacity",
                onOkAction: {
                    self.finishEventFlow()
                }
            )
            return
        }

        let chanceForAttraction = min(100 - Int(ceil(Double(food - totalFoodRequired) * (percentagePerFood / 2.0))), 50)
        let roll = roll1to100()

        if roll > chanceForAttraction {
            alertManager.showOkAlert(
                "Success! New NPC Attracted!",
                message: "Soon, an opportunity to recruit a new NPC will arise!\n(Rolled: \(roll)%, which is > than \(chanceForAttraction)%)",
                onOkAction: {
                    self.finishEventFlow()
                }
            )
        } else {
            alertManager.showOkAlert(
                ":(",
                message: "Failed To Attract A New NPC This Time. Rolled \(roll)%, which was ≤ \(chanceForAttraction)%!",
                onOkAction: {
                    self.finishEventFlow()
                }
            )
        }
    }

    private func finishEventFlow() {
        DM.load()
        alertManager.showOkAlert("Event Finished", onOkAction: {
            runOnMainThread {
                self.loading = false
                self.mode.wrappedValue.dismiss()
            }
        })
    }

    private func roll1to100() -> Int {
        return Int.random(in: 1...100)
    }
}

struct NPCGatheredMaterials {
    var wood: Int = 0
    var metal: Int = 0
    var cloth: Int = 0
    var tech: Int = 0
    var medical: Int = 0

    func getPrintString() -> String {
        return "Your NPCs were well fed enough to gather additional materials for sale at the next event!\n\nWood: \(wood)\nMetal: \(metal)\nCloth: \(cloth)\nTech: \(tech)\nMedical: \(medical)"
    }

    mutating func addNew(roll: Int) {
        switch roll {
        case 1...20:
            wood += 1
        case 21...40:
            metal += 1
        case 41...60:
            cloth += 1
        case 61...80:
            tech += 1
        case 81...100:
            medical += 1
        default:
            break
        }
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return ManageEventView(events: .constant(md.events.events), event: .constant(md.event(2)))
//}
