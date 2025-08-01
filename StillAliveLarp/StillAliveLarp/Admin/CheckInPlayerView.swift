//
//  CheckInPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/20/23.
//

import SwiftUI
import CodeScanner

struct CheckInPlayerView: View {
    @ObservedObject var _dm = OldDataManager.shared

    @State var isScanning: Bool = true
    @State var playerCheckInModel: CheckInOutBarcodeModel?

    @State var loading: Bool = false
    @State var loadingText = ""
    
    @State var gearModified = false
    @State var gearJsonModels: [GearJsonModel] = []

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
                        guard let json = data.string.decompress() else {
                            self.scannerFailed("Unable to read data")
                            return
                        }
                        globalTestPrint("BARCODE DATA: \(String(data: json, encoding: .utf8) ?? "")")
                        guard let model: CheckInOutBarcodeModel = json.toJsonObject() else {
                            self.scannerFailed("Unable to parse data")
                            return
                        }
                        self.playerCheckInModel = model
                        self.isScanning = false
                        
                        self.gearModified = false
                        self.gearJsonModels = model.gear?.jsonModels ?? []
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
                            Divider().frame(height: 2).overlay(Color.black)
                            Text("Player")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)

                            // Player Section
                            PlayerBarcodeView(player: model.player, isCheckout: false, isNPC: model.character == nil)
                            Spacer().frame(height: 16)

                            // Character Section
                            Divider().frame(height: 2).overlay(Color.black)
                            Text("Character")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                            if let character = model.character {
                                CharacterBarcodeView(character: character, relevantSkills: model.relevantSkills)
                            } else {
                                KeyValueView(key: "Name", value: "NPC")
                                KeyValueView(key: "BONUS RAFFLE TICKETS", value: "+1", showDivider: false)
                            }
                            
                            Spacer().frame(height: 16)
                            Divider().frame(height: 2).overlay(Color.black)
                            Text("Relevant Skills")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)

                            // Skills Section
                            RelevantSkillsView(relevantSkills: model.relevantSkills, primaryFirearm: gearJsonModels.first(where: { $0.isPrimaryFirearm() }))

                            // Event Section
                            Spacer().frame(height: 16)
                            Divider().frame(height: 2).overlay(Color.black)
                            Text("Event")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                            KeyValueView(key: "Name", value: model.event.title, showDivider: false)
                            
                            Spacer().frame(height: 16)
                            if let char = model.character {
                                Divider().frame(height: 2).overlay(Color.black)
                                Text("Gear (Editable)")
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 8)
                                GearViewModular(allowEdit: true, characterName: char.fullName, loading: $loading, gearModified: $gearModified, gearJsonModels: $gearJsonModels)
                            }

                            LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 32, buttonText: "\(gearModified ? "Save Gear Modifications\nAnd\n" : "")Check In") {
                                self.loading = true
                                if gearModified {
                                    saveGear(model) {
                                        checkInPlayer(model)
                                    }
                                } else {
                                    checkInPlayer(model)
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
    
    private func saveGear(_ model: CheckInOutBarcodeModel, onCompletion: @escaping () -> Void) {
        self.loading = true
        self.loadingText = "Organizing Gear..."
        let character = model.character!
        if let gear = model.gear {
            // Edit
            loadingText = "Updating Gear..."
            let gearUpdateModel = GearModel(id: gear.id, characterId: character.id, gearJson: GearJsonListModel(gearJson: gearJsonModels).toJsonString() ?? "")
            AdminService.updateGear(gearModel: gearUpdateModel) { gearModel in
                runOnMainThread {
                    self.loadingText = "Gear Updated!"
                    self.gearModified = false
                    onCompletion()
                }
            } failureCase: { error in
                runOnMainThread {
                    loading = false
                }
            }

        } else {
            // Add New
            loadingText = "Creating Gear Listing..."
            let gearCreateModel = GearCreateModel(characterId: character.id, gearJson: GearJsonListModel(gearJson: gearJsonModels).toJsonString() ?? "")
            AdminService.createGear(gearCreateModel) { gearModel in
                runOnMainThread {
                    loadingText = "Gear Added!"
                    gearModified = false
                    onCompletion()
                }
            } failureCase: { error in
                runOnMainThread {
                    loading = false
                }
            }

        }
    }
    
    private func checkInPlayer(_ model: CheckInOutBarcodeModel) {
        self.loadingText = "Checking in player..."
        // DO NOT set the char id. The service will do that later
        let eventAttendee = EventAttendeeCreateModel(playerId: model.player.id, eventId: model.event.id, isCheckedIn: "TRUE", asNpc: model.character == nil ? "TRUE" : "FALSE")

        AdminService.checkInPlayer(eventAttendee) { eventAttendee in
            if let char = model.character {
                self.loadingText = "Adding Bullets..."
                let bullets = self.getBulletAmount(char)
                AdminService.giveCharacterCheckInRewards(model.event.id, characterId: char.id, playerId: model.player.id, newBulletAmount: bullets) { updatedCharacter in
                    self.loadingText = "Checking In Character..."
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
    @ObservedObject var _dm = OldDataManager.shared

    let relevantSkills: [SkillBarcodeModel]
    let primaryFirearm: GearJsonModel?
    
    typealias ssid = Constants.SpecificSkillIds

    var body: some View {
        if hasCheckInRelevantSkills() {
            VStack {
                // Deep Pockets Type
                let ammoSkills = getSkillNames(skillIds: ssid.deepPocketTypeSkills)
                if ammoSkills.isNotEmpty {
                    KeyValueView(key: "Ammo Skills", value: ammoSkills)
                }
                
                // Investigator Type
                let investSkills = getSkillNames(skillIds: ssid.investigatorTypeSkills)
                if investSkills.isNotEmpty {
                    KeyValueView(key: "Intrigue Skills", value: investSkills)
                }

                // Tough Skin Type
                let regularArmorSkills = getSkillNames(skillIds: ssid.regularArmorSkills)
                if regularArmorSkills.isNotEmpty {
                    KeyValueView(key: "Regular Armor Skills", value: regularArmorSkills, showDivider: false)
                    KeyValueView(key: "BLUE BEADS NEEDED", value: (regularArmorSkills.countOccurances(",") + 1).stringValue).padding(.top, 4)
                }
                // Scaled Skin Type
                let bpArmorSkills = getSkillNames(skillIds: ssid.bulletProofArmorSkills)
                if bpArmorSkills.isNotEmpty {
                    KeyValueView(key: "Bullet Proof Armor Skills", value: bpArmorSkills, showDivider: false)
                    KeyValueView(key: "RED BEADS NEEDED", value: (bpArmorSkills.countOccurances(",") + 1).stringValue).padding(.top, 4)
                }
                // Plot Armor Type
                let pArmorSkills = getSkillNames(skillIds: ssid.plotArmorSkills)
                if pArmorSkills.isNotEmpty {
                    KeyValueView(key: "Plot Armor Skills", value: pArmorSkills, showDivider: false)
                    KeyValueView(key: "BLACK BEADS NEEDED", value: (pArmorSkills.countOccurances(",") + 1).stringValue).padding(.top, 4)
                }

                // Walk like a zombie type
                let zombieSkills = getSkillNames(skillIds: ssid.walkLikeAZombieTypeSkills)
                if zombieSkills.isNotEmpty {
                    KeyValueView(key: "Disguise Skills", value: zombieSkills, showDivider: false)
                    KeyValueView(key: "GREEN BEADS NEEDED", value: "1").padding(.top, 4)
                }

                // Gambler type
                let gamblerSkills = getSkillNames(skillIds: ssid.gamblerTypeSkills)
                if gamblerSkills.isNotEmpty {
                    KeyValueView(key: "Gambler Skills", value: gamblerSkills, showDivider: false)
                    KeyValueView(key: "BONUS RAFFLE TICKETS", value: "+\((gamblerSkills.countOccurances(",") + 1).stringValue)").padding(.top, 4)
                }

                // Fortune type
                if relevantSkills.contains(where: { $0.id == ssid.prosperousDiscovery }) {
                    KeyValueView(key: "Fortune Skill", value: "Prosperous Discovery", showDivider: false)
                    KeyValueView(key: "BONUS MATERIALS", value: "Choose:\n2d4 Wood, Cloth or Metal\nor\n2 Tech or Medical").padding(.top, 4)
                } else if relevantSkills.contains(where: { $0.id == ssid.fortunateFind }) {
                    KeyValueView(key: "Fortune Skill", value: "Fortunate Find", showDivider: false)
                    KeyValueView(key: "BONUS MATERIALS", value: "Choose:\n1d4 Wood, Cloth or Metal\nor\n1 Tech or Medical").padding(.top, 4)
                }

                // Fully Loaded
                if relevantSkills.contains(where: { $0.id == Constants.SpecificSkillIds.fullyLoaded}) {
                    if let primaryFirearm = primaryFirearm {
                        KeyValueView(key: "Fully Loaded", value: "\(primaryFirearm.name)\n\(primaryFirearm.desc)", showDivider: false)
                        KeyValueView(key: "BONUS AMMO", value: "Bullets: <= 25\nMegas: <= 8\nMilitaries: <= 5\nRockets: <= 2", showDivider: false).padding(.top, 4)
                    } else {
                        KeyValueView(key: "Fully Loaded", value: "!! No Primary Firearm Registered !!", showDivider: false)
                    }
                }
            }
        }
    }
    
    func getSkillNames(skillIds: [Int]) -> String {
        var names = ""
        for sk in relevantSkills.filter({ $0.id.equalsAnyOf(skillIds) }) {
            if !names.isEmpty {
                names += ",\n"
            }
            names += sk.name
        }
        return names
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
    @ObservedObject var _dm = OldDataManager.shared

    let player: PlayerBarcodeModel
    let isCheckout: Bool
    let isNPC: Bool

    var body: some View {
        VStack {
            KeyValueView(key: "Name", value: player.fullName)
            KeyValueView(key: "Total Events Attended", value: "\(player.numEventsAttended)+1")
            KeyValueView(key: "NPC Events Attended", value: "\(player.numNpcEventsAttended)\(isNPC ? "+1" : "")")
            KeyValueView(key: "Last Event Attended", value: player.lastCheckIn.yyyyMMddToMonthDayYear(), showDivider: false)
        }
    }

}

struct CharacterBarcodeView: View {
    @ObservedObject var _dm = OldDataManager.shared

    let character: CharacterBarcodeModel
    let relevantSkills: [SkillBarcodeModel]

    var body: some View {
        VStack {
            CharacterBarcodeFirstSubView(character: character, relevantSkills: relevantSkills)
            CharacterBarcodeSecondSubView(character: character)
            if let armor = CharacterModel.ArmorType(rawValue: character.armor) {
                KeyValueView(key: "Armor", value: armor.rawValue, showDivider: armor == .none)
                if armor == .metal {
                    KeyValueView(key: "BLUE BEADS NEEDED", value: "1", showDivider: false).padding(.top, 4)
                } else if armor == .bulletProof {
                    KeyValueView(key: "RED BEADS NEEDED", value: "1", showDivider: false).padding(.top, 4)
                }
            }
        }
    }

}

struct CharacterBarcodeFirstSubView: View {
    @ObservedObject var _dm = OldDataManager.shared

    let character: CharacterBarcodeModel
    let relevantSkills: [SkillBarcodeModel]

    var body: some View {
        VStack {
            KeyValueView(key: "Name", value: character.fullName)
            let inf = character.infection.intValueDefaultZero
            KeyValueView(key: "Infection", value: "\(inf)%", showDivider: inf < 25)
            if inf >= 25 {
                let thresh = inf >= 75 ? "THIRD" : (inf >= 50 ? "SECOND" : "FIRST")
                KeyValueView(key: "Infection Threshold", value: thresh).padding(.top, 4)
            }
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
    @ObservedObject var _dm = OldDataManager.shared

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
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    let bm = md.playerCheckInBarcodeModel(playerId: 2, characterId: 2, eventId: 2)
    return CheckInPlayerView(_dm: dm, isScanning: false, playerCheckInModel: bm, gearModified: true, gearJsonModels: bm.gear?.jsonModels ?? [])
}
