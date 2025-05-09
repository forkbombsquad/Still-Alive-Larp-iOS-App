//
//  CheckInPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/20/23.
//

import SwiftUI
import CodeScanner

struct CheckInPlayerView: View {
    @ObservedObject var _dm = DataManager.shared

    @State var isScanning: Bool = true
    @State var playerCheckInModel: PlayerCheckInBarcodeModel?

    @State var loading: Bool = false
    @State var loadingText = ""

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        if isScanning {
            VStack {
                Text("Scan Check In Code")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .frame(alignment: .center)
                    .padding([.bottom], 16)
                CodeScannerView(codeTypes: [.qr]) { result in
                    self.isScanning = false
                    switch result {
                    case .success(let data):
                        guard let json = data.string.data(using: .utf8) else {
                            self.scannerFailed("Unable to parse data")
                            return
                        }
                        guard let model: PlayerCheckInBarcodeModel = json.toJsonObject() else {
                            self.scannerFailed("Unable to parse data")
                            return
                        }
                        self.playerCheckInModel = model
                        self.isScanning = false
                    case .failure(let error):
                        self.scannerFailed(error.localizedDescription)
                    }
                }
            }
        } else if let model = playerCheckInModel {
            VStack(alignment: .center) {
                GeometryReader { gr in
                    ScrollView {
                        VStack(alignment: .center) {
                            Text("Check In Player")
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(alignment: .center)
                                .padding([.bottom], 16)
                            Divider()

                            // Player Section
                            PlayerBarcodeView(player: model.player, isCheckout: false, isNPC: model.character == nil)
                            Spacer().frame(height: 48)

                            // Character Section
                            KeyValueView(key: "Character", value: "", showDivider: false)
                            if let character = model.character {
                                CharacterBarcodeView(character: character, relevantSkills: model.relevantSkills)
                            } else {
                                KeyValueView(key: "Name", value: "NPC")
                            }

                            // Skills Section
                            RelevantSkillsView(relevantSkills: model.relevantSkills, primaryWeapon: model.gear)

                            // Event Section
                            Spacer().frame(height: 48)
                            KeyValueView(key: "Event", value: model.event.title)

                            // Approve Section
                            LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 32, buttonText: "Check In") {
                                self.loading = true
                                self.loadingText = "Checking in player"
                                // DO NOT set the char id. The service will do that later
                                let eventAttendee = EventAttendeeCreateModel(playerId: model.player.id, eventId: model.event.id, isCheckedIn: "TRUE", asNpc: model.character == nil ? "TRUE" : "FALSE")

                                AdminService.checkInPlayer(eventAttendee) { eventAttendee in
                                    if let char = model.character {
                                        self.loadingText = "Giving character rewards"
                                        let bullets = self.getBulletAmount(char)
                                        AdminService.giveCharacterCheckInRewards(model.event.id, characterId: char.id, playerId: model.player.id, newBulletAmount: bullets) { updatedCharacter in
                                            self.loadingText = "Checking in character"
                                            AdminService.checkInCharacter(model.event.id, characterId: char.id, playerId: model.player.id) { c in
                                                self.loading = false
                                                self.showSuccessAlertAllowingRescan("\(model.player.fullName) checked in as \(updatedCharacter.fullName)")
                                            } failureCase: { error in
                                                self.loading = false
                                                self.resetScanner()
                                            }
                                        } failureCase: { error in
                                            self.loading = false
                                            self.resetScanner()
                                        }
                                    } else {
                                        self.loading = false
                                        self.showSuccessAlertAllowingRescan("\(model.player.fullName) checked in as NPC")
                                    }
                                } failureCase: { error in
                                    self.loading = false
                                    self.resetScanner()
                                }
                            }.padding(.top, 48)
                        }
                    }
                }
            }.padding(16)
            .background(Color.lightGray)
        } else {
            VStack(alignment: .center) {
                Text("Something Went Wrong")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .frame(alignment: .center)
                    .padding([.bottom], 16)
            }
        }
    }

    func scannerFailed(_ errorMessage: String) {
        runOnMainThread {
            AlertManager.shared.showOkAlert("Scanning Failed", message: errorMessage) {
                runOnMainThread {
                    self.mode.wrappedValue.dismiss()
                }
            }
        }
    }

    func resetScanner() {
        self.isScanning = true
        self.playerCheckInModel = nil
    }

    func showSuccessAlertAllowingRescan(_ message: String) {
        runOnMainThread {
            AlertManager.shared.showAlert("Success", message: message, button1: Alert.Button.default(Text("Keep Scanning"), action: {
                self.resetScanner()
            }), button2: Alert.Button.cancel(Text("Finished"), action: {
                runOnMainThread {
                    self.mode.wrappedValue.dismiss()
                }
            }))
        }
    }

    func getBulletAmount(_ char: CharacterBarcodeModel) -> Int {
        var bullets = char.bullets.intValueDefaultZero + 2
        if let relevantSkills = playerCheckInModel?.relevantSkills {
            if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.bandoliers }) {
                bullets += 2
            }
            if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.parachutePants }) {
                bullets += 2
            }
            if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deeperPockets }) {
                bullets += 2
            }
            if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deepPockets }) {
                bullets += 2
            }
        }
        return bullets
    }

}

struct RelevantSkillsView: View {
    @ObservedObject var _dm = DataManager.shared

    let relevantSkills: [SkillBarcodeModel]
    let primaryWeapon: GearModel?

    var body: some View {
        if hasCheckInRelevantSkills() {
            VStack {
                Spacer().frame(height: 48)
                KeyValueView(key: "Check In Relevant Skills", value: "", showDivider: false)

                // Deep Pockets Type
                if relevantSkills.contains(where: { $0.id.equalsAnyOf(Constants.SpecificSkillIds.deepPocketTypeSkills)  }) {
                    Spacer().frame(height: 22)
                    if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.bandoliers }) {
                        KeyValueView(key: "Ammo Skill", value: "Bandoliers")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.parachutePants }) {
                        KeyValueView(key: "Ammo Skill", value: "Parachute Pants")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deeperPockets }) {
                        KeyValueView(key: "Ammo Skill", value: "Deeper Pockets")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deepPockets }) {
                        KeyValueView(key: "Ammo Skill", value: "Deep Pockets")
                    }
                }

                // Investigator Type
                if relevantSkills.contains(where: { $0.id.equalsAnyOf(Constants.SpecificSkillIds.investigatorTypeSkills) }) {
                    Spacer().frame(height: 22)
                    if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.webOfInformants }) {
                        KeyValueView(key: "Highest Intrigue Skill", value: "Web of Informants")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.interrogator }) {
                        KeyValueView(key: "Highest Intrigue Skill", value: "Interrogator")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.investigator }) {
                        KeyValueView(key: "Highest Intrigue Skill", value: "Investigator")
                    }
                }

                // Tough Skin Type
                if relevantSkills.contains(where: { $0.id.equalsAnyOf(Constants.SpecificSkillIds.toughSkinTypeSkills) }) {
                    Spacer().frame(height: 22)
                    if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.naturalArmor }) {
                        KeyValueView(key: "Armor Skill", value: "Natrual Armor")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.painTolerance }) {
                        KeyValueView(key: "Armor Skill", value: "Pain Tolerance")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.toughSkin }) {
                        KeyValueView(key: "Armor Skill", value: "Tough Skin")
                    }
                    if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.scaledSkin }) {
                        KeyValueView(key: "Armor Skill", value: "Scaled Skin")
                    }
                    if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.plotArmor }) {
                        KeyValueView(key: "Prestige Armor Skill", value: "Plot Armor")
                    }
                    let blueBeadCount = getBlueBeadCount()
                    let redBeadCount = getRedBeadCount()
                    let blackBeadCount = getBlackBeadCount()
                    if blueBeadCount > 0 {
                        KeyValueView(key: "BLUE BEADS NEEDED", value: "\(blueBeadCount)")
                    }
                    if redBeadCount > 0 {
                        KeyValueView(key: "RED BEADS NEEDED", value: "\(redBeadCount)")
                    }
                    if blackBeadCount > 0 {
                        KeyValueView(key: "BlACK BEADS NEEDED", value: "\(blackBeadCount)")
                    }
                }

                // Walk like a zombie type
                if relevantSkills.contains(where: { $0.id.equalsAnyOf(Constants.SpecificSkillIds.walkLikeAZombieTypeSkills) }) {
                    Spacer().frame(height: 22)
                    if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deadManWalking }) {
                        KeyValueView(key: "Disguise Skill", value: "Dead Man Walking")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deadManStanding }) {
                        KeyValueView(key: "Disguise Skill", value: "Dead Man Standing")
                    }
                    let greenBeads = getGreenBeadCount()
                    if greenBeads > 0 {
                        KeyValueView(key: "GREEN BEADS NEEDED", value: "\(greenBeads)")
                    }
                }

                // Gambler type
                if relevantSkills.contains(where: { $0.id.equalsAnyOf(Constants.SpecificSkillIds.deepPocketTypeSkills)  }) {
                    Spacer().frame(height: 22)
                    if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.gamblersHeart }) {
                        KeyValueView(key: "Gambler Skill", value: "Gambler's Heart")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.gamblersEye }) {
                        KeyValueView(key: "Gambler Skill", value: "Gambler's Eye")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.gamblersTalent }) {
                        KeyValueView(key: "Gambler Skill", value: "Gambler's Talent")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.gamblersLuck }) {
                        KeyValueView(key: "Gambler Skill", value: "Gambler's Luck")
                    }
                    let bonusRaffle = getBonusRaffleTicketCount()
                    if bonusRaffle > 0 {
                        KeyValueView(key: "BONUS RAFFLE TICKETS", value: "\(bonusRaffle)")
                    }
                }

                // Fortune type
                if relevantSkills.contains(where: { $0.id.equalsAnyOf(Constants.SpecificSkillIds.fortuneSkills)  }) {
                    Spacer().frame(height: 22)
                    if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.prosperousDiscovery }) {
                        KeyValueView(key: "Fortune Skill", value: "Prosperous Discovery")
                    } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.fortunateFind }) {
                        KeyValueView(key: "Fortune Skill", value: "Fortunate Find")
                    }
                    let bonusMaterialCount = getBonusMaterialCount()
                    if bonusMaterialCount > 0 {
                        KeyValueView(key: "BONUS MATERIALS", value: "\(bonusMaterialCount == 1 ? "Roll Randomly for " : "Choose ") \(bonusMaterialCount)d4 Wood/Cloth/Metal or \(bonusMaterialCount) Tech/Medical")
                    }
                }

                // Fully Loaded
                if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.fullyLoaded}) {
                    // TODO fix
//                    if let weapon = primaryWeapon {
//                        KeyValueView(key: "FULLY LOADED (<=25)", value: "\(weapon.description) - \(weapon.name)")
//                    } else {
//                        KeyValueView(key: "FULLY LOADED", value: "MISSING PRIMARY WEAPON REGISTRATION")
//                    }
                }
            }
        }
    }

    func hasCheckInRelevantSkills() -> Bool {
        for sk in self.relevantSkills {
            guard sk.id.equalsAnyOf(Constants.SpecificSkillIds.checkInRelevantSkillsOnly) else { continue }
            return true
        }
        return false
    }

    func getBlueBeadCount() -> Int {
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.naturalArmor }) {
            return 3
        } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.painTolerance }) {
            return 2
        } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.toughSkin }) {
            return 1
        }
        return 0
    }

    func getRedBeadCount() -> Int {
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.scaledSkin }) {
            return 1
        }
        return 0
    }

    func getBlackBeadCount() -> Int {
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.plotArmor }) {
            return 1
        }
        return 0
    }

    func getGreenBeadCount() -> Int {
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deadManWalking }) {
            return 2
        } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deadManStanding }) {
            return 1
        }
        return 0
    }

    func getBonusRaffleTicketCount() -> Int {
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.gamblersHeart }) {
            return 4
        } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.gamblersEye }) {
            return 3
        } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.gamblersTalent }) {
            return 2
        } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.gamblersLuck }) {
            return 1
        }
        return 0
    }

    func getBonusMaterialCount() -> Int {
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.prosperousDiscovery }) {
            return 2
        } else if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.fortunateFind }) {
            return 1
        }
        return 0
    }

}

struct PlayerBarcodeView: View {
    @ObservedObject var _dm = DataManager.shared

    let player: PlayerBarcodeModel
    let isCheckout: Bool
    let isNPC: Bool

    var body: some View {
        VStack {
            KeyValueView(key: "Player", value: "", showDivider: false)
            KeyValueView(key: "Name", value: player.fullName)
            KeyValueView(key: "Total Events Attended", value: "\(player.numEventsAttended)\(isCheckout ? "+1" : "")")
            KeyValueView(key: "NPC Events Attended", value: "\(player.numNpcEventsAttended)\((isCheckout && isNPC) ? "+1" : "")")
            KeyValueView(key: "Last Event Attended", value: player.lastCheckIn.yyyyMMddToMonthDayYear(), showDivider: true)
        }
    }

}

struct CharacterBarcodeView: View {
    @ObservedObject var _dm = DataManager.shared

    let character: CharacterBarcodeModel
    let relevantSkills: [SkillBarcodeModel]

    var body: some View {
        VStack {
            CharacterBarcodeFirstSubView(character: character, relevantSkills: relevantSkills)
            CharacterBarcodeSecondSubView(character: character)
            if let armor = CharacterModel.ArmorType(rawValue: character.armor) {
                if armor == .metal {
                    KeyValueView(key: "METAL ARMOR - BLUE BEADS NEEDED", value: "\(1)")
                } else if armor == .bulletProof {
                    KeyValueView(key: "BULLET-PROOF ARMOR - RED BEADS NEEDED", value: "\(1)")
                }
            }
        }
    }

}

struct CharacterBarcodeFirstSubView: View {
    @ObservedObject var _dm = DataManager.shared

    let character: CharacterBarcodeModel
    let relevantSkills: [SkillBarcodeModel]

    var body: some View {
        VStack {
            KeyValueView(key: "Name", value: character.fullName)
            KeyValueView(key: "Infection", value: "\(character.infection)%\(character.infection.intValueDefaultZero > 25 ? " *THRESHOLD*" : "")")
            KeyValueView(key: "Bullets", value: "\(character.bullets)+\(getBulletAdditions())")
            KeyValueView(key: "Megas", value: character.megas)
            KeyValueView(key: "Rivals", value: character.rivals)
            KeyValueView(key: "Rockets", value: character.rockets)
        }
    }

    func getBulletAdditions() -> Int {
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.bandoliers }) {
            return 10
        }
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.parachutePants }) {
            return 8
        }
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deeperPockets }) {
            return 6
        }
        if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.deepPockets }) {
            return 4
        }
        return 2
    }

}

struct CharacterBarcodeSecondSubView: View {
    @ObservedObject var _dm = DataManager.shared

    let character: CharacterBarcodeModel

    var body: some View {
        VStack {
            KeyValueView(key: "Bullet Casings", value: character.bulletCasings)
            KeyValueView(key: "Cloth Supplies", value: character.clothSupplies)
            KeyValueView(key: "Wood Supplies", value: character.woodSupplies)
            KeyValueView(key: "Metal Supplies", value: character.metalSupplies)
            KeyValueView(key: "Tech Supplies", value: character.techSupplies)
            KeyValueView(key: "Medical Supplies", value: character.medicalSupplies)
        }
    }

}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    
    return CheckInPlayerView(_dm: dm, isScanning: false, playerCheckInModel: md.playerCheckInBarcodeModel(playerId: 3, characterId: 3, eventId: 2))
}
