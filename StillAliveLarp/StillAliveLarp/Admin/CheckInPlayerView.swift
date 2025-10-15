//
//  CheckInPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/20/23.
//

import SwiftUI
import CodeScanner


struct CheckInPlayerView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State var isScanning: Bool = true
    @State var barcodeModel: CheckInOutBarcodeModel?

    @State var loading: Bool = false
    @State var loadingText = ""

    @State var gearModified = false
    @State var gear: GearModel? = nil
    @State var gearJsonModels: [GearJsonModel] = []
    
    @State var player: FullPlayerModel? = nil
    @State var character: FullCharacterModel? = nil
    @State var event: FullEventModel? = nil
    @State var isNpc = false
    
    @State var npcChoices: [String] = []
    @State var selectedNpc: String = ""
    
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
                            self.scannerFailed("Unable to read data")
                            return
                        }
                        guard let model: CheckInOutBarcodeModel = json.toJsonObject() else {
                            self.scannerFailed("Unable to parse data")
                            return
                        }
                        self.barcodeModel = model
                        recalculateModels()
                        self.isScanning = false
                    case .failure(let error):
                        self.scannerFailed(error.localizedDescription)
                    }
                }
            }
        } else if barcodeModel != nil {
            VStack(alignment: .center) {
                GeometryReader { gr in
                    ScrollView {
                        VStack(alignment: .center) {
                            globalCreateTitleView("Check In Player", DM: DM)
                            LoadingLayoutView {
                                VStack {
                                    if let player = player, let event = event {
                                        Divider().frame(height: 2).overlay(Color.black)
                                        Text("Player")
                                            .font(.system(size: 24, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)

                                        // Player Section
                                        PlayerBarcodeView(player: player, isCheckout: false, isNPC: isNpc)
                                        Spacer().frame(height: 16)

                                        // Character Section
                                        Divider().frame(height: 2).overlay(Color.black)
                                        Text("Character")
                                            .font(.system(size: 24, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)
                                        if let character = character {
                                            CharacterBarcodeView(character: character, relevantSkills: getRelevantSkills(), isNpc: false)
                                        } else if let npc = getSelectedNpc() {
                                            StyledPickerView(title: "NPC", selection: $selectedNpc, options: npcChoices) { _ in }
                                            KeyValueView(key: "Name", value: "NPC")
                                            KeyValueView(key: "BONUS RAFFLE TICKETS", value: "+1", showDivider: false)
                                            CharacterBarcodeView(character: npc, relevantSkills: getRelevantSkills(), isNpc: true)
                                        } else {
                                            StyledPickerView(title: "NPC", selection: $selectedNpc, options: npcChoices) { _ in }
                                        }
                                        
                                        Spacer().frame(height: 16)
                                        Divider().frame(height: 2).overlay(Color.black)
                                        Text("Relevant Skills")
                                            .font(.system(size: 24, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)

                                        // Skills Section
                                        RelevantSkillsView(character: character ?? getSelectedNpc(), relevantSkills: getRelevantSkills(), primaryFirearm: gearJsonModels.first(where: { $0.isPrimaryFirearm() }), isNpc: isNpc)

                                        // Event Section
                                        Spacer().frame(height: 16)
                                        Divider().frame(height: 2).overlay(Color.black)
                                        Text("Event")
                                            .font(.system(size: 24, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)
                                        KeyValueView(key: "Name", value: event.title, showDivider: false)
                                        
                                        Spacer().frame(height: 16)
                                        if let char = character {
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
                                                saveGear() {
                                                    checkInPlayer()
                                                }
                                            } else {
                                                checkInPlayer()
                                            }
                                        }.padding(.top, 48)
                                    }
                                }
                            }
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
    
    private func recalculateModels() {
        DM.load(finished: {
            runOnMainThread {
                if let bar = barcodeModel {
                    player = DM.players.first(where: { $0.id == bar.playerId })
                    if let charId = bar.characterId, let char = DM.getCharacter(charId) {
                        character = char
                        gear = char.gear
                        gearJsonModels = char.gear?.jsonModels ?? []
                        isNpc = false
                    } else {
                        character = nil
                        gear = nil
                        gearJsonModels = []
                        isNpc = true
                    }
                    event = DM.events.first(where: { $0.id == bar.eventId })
                    npcChoices = DM.getAllCharacters(.npc).filter { npc in npc.isAlive && npc.isNpcAndNotAttendingEvent(eventId: bar.eventId) }.map { $0.fullName }.sorted()
                    selectedNpc = npcChoices.first ?? ""
                } else {
                    gearModified = false
                    gear = nil
                    gearJsonModels = []
                    
                    player = nil
                    character = nil
                    event = nil
                    isNpc = false
                }
            }
        })
    }
    
    private func saveGear(onCompletion: @escaping () -> Void) {
        self.loading = true
        self.loadingText = "Organizing Gear..."
        if let gear = gear, let character = character {
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

        } else if let character = character {
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
    
    private func checkInPlayer() {
        self.loadingText = "Checking in player..."
        // DO NOT set the char id. The service will do that later
        let eventAttendee = EventAttendeeCreateModel(playerId: player?.id ?? -1, eventId: event?.id ?? -1, isCheckedIn: "TRUE", asNpc: isNpc ? "TRUE" : "FALSE", npcId: isNpc ? getSelectedNpc()?.id ?? -1 : -1)

        AdminService.checkInPlayer(eventAttendee) { eventAttendee in
            if let char = character {
                self.loadingText = "Adding Bullets..."
                let bullets = self.getBulletCount(char)
                AdminService.giveCharacterCheckInRewards(event?.id ?? -1, characterId: char.id, playerId: player?.id ?? -1, newBulletAmount: bullets) { updatedCharacter in
                    self.loadingText = "Checking In Character..."
                    AdminService.checkInCharacter(event?.id ?? -1, characterId: char.id, playerId: player?.id ?? -1) { c in
                        self.loading = false
                        self.showSuccessAlertAllowingRescan("\(player?.fullName ?? "Unknown") checked in as \(updatedCharacter.fullName)")
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
                self.showSuccessAlertAllowingRescan("\(player?.fullName ?? "Unknown") checked in as \(getSelectedNpc()?.fullName ?? "NPC")")
            }
        } failureCase: { error in
            self.loading = false
            self.resetScanner()
        }
    }

    func scannerFailed(_ errorMessage: String) {
        runOnMainThread {
            alertManager.showOkAlert("Scanning Failed", message: errorMessage) {
                runOnMainThread {
                    self.mode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func getSelectedNpc() -> FullCharacterModel? {
        return DM.getAllCharacters(.npc).first(where: { $0.fullName == selectedNpc })
    }
    
    func getRelevantSkills() -> [FullCharacterModifiedSkillModel] {
        return character?.getRelevantBarcodeSkills() ?? getSelectedNpc()?.getRelevantBarcodeSkills() ?? []
    }

    func resetScanner() {
        self.isScanning = true
    }

    func showSuccessAlertAllowingRescan(_ message: String) {
        runOnMainThread {
            DM.load(finished: {
                runOnMainThread {
                    alertManager.showAlert("Success", message: message, button1: Alert.Button.default(Text("Keep Scanning"), action: {
                        self.resetScanner()
                    }), button2: Alert.Button.cancel(Text("Finished"), action: {
                        runOnMainThread {
                            self.mode.wrappedValue.dismiss()
                        }
                    }))
                }
            })
        }
    }
    
    func getBulletCount(_ char: FullCharacterModel) -> Int {
        var bullets = char.bullets
        char.getRelevantBarcodeSkills().forEach { skill in
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.deepPocketTypeSkills) {
                bullets += 2
            }
        }
        return bullets
    }

}

struct PlayerBarcodeView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let player: FullPlayerModel
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
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel
    let relevantSkills: [FullCharacterModifiedSkillModel]
    let isNpc: Bool

    var body: some View {
        VStack {
            CharacterBarcodeFirstSubView(character: character, relevantSkills: relevantSkills, isNpc: isNpc)
            if !isNpc {
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
}

struct CharacterBarcodeFirstSubView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel
    let relevantSkills: [FullCharacterModifiedSkillModel]
    let isNpc: Bool

    var body: some View {
        VStack {
            KeyValueView(key: "Name", value: character.fullName)
            let inf = character.infection
            KeyValueView(key: "Infection", value: "\(inf)%", showDivider: inf < 25)
            if inf >= 25 {
                let thresh = inf >= 75 ? "THIRD" : (inf >= 50 ? "SECOND" : "FIRST")
                KeyValueView(key: "Infection Threshold", value: thresh).padding(.top, 4)
            }
            KeyValueView(key: "Bullets", value: "\(character.bullets)+\(getAdditionalBulletCount(relevantSkills: relevantSkills))")
            if !isNpc {
                KeyValueView(key: "Megas", value: character.megas.stringValue)
                KeyValueView(key: "Rivals", value: character.rivals.stringValue)
                KeyValueView(key: "Rockets", value: character.rockets.stringValue)
            }
        }
    }

    func getAdditionalBulletCount(relevantSkills: [FullCharacterModifiedSkillModel]) -> Int {
        var bullets = 2
        relevantSkills.forEach { skill in
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.deepPocketTypeSkills) {
                bullets += 2
            }
        }
        return bullets
    }

}

struct CharacterBarcodeSecondSubView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel

    var body: some View {
        VStack {
            KeyValueView(key: "Bullet Casings", value: character.bulletCasings.stringValue)
            KeyValueView(key: "Cloth Supplies", value: character.clothSupplies.stringValue)
            KeyValueView(key: "Wood Supplies", value: character.woodSupplies.stringValue)
            KeyValueView(key: "Metal Supplies", value: character.metalSupplies.stringValue)
            KeyValueView(key: "Tech Supplies", value: character.techSupplies.stringValue)
            KeyValueView(key: "Medical Supplies", value: character.medicalSupplies.stringValue)
        }
    }

}

struct RelevantSkillsView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel?
    let relevantSkills: [FullCharacterModifiedSkillModel]
    let primaryFirearm: GearJsonModel?
    let isNpc: Bool
    
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
                
                // Mysterious Starnger
                if showMysteriousStranger() {
                    KeyValueView(key: "Mysterious Stranger Uses Remaining", value: getMysteriousStrangerText())
                }
                if showUnshakableResolve() {
                    KeyValueView(key: "Unshakable Resolve Uses Remaining", value: getUnshakableResolveText())
                }
            }
        }
        if hasNewSkills() {
            KeyValueView(key: "New Skills Since Last Event", value: getNewSkills().map({ "\($0.name) - \($0.getTypeText())" }).joined(separator: "\n"))
        }
    }
    
    private func showMysteriousStranger() -> Bool {
        return character?.mysteriousStrangerCount() ?? 0 > 0
    }
    
    private func showUnshakableResolve() -> Bool {
        return character?.hasUnshakableResolve() ?? false
    }
    
    private func getMysteriousStrangerText() -> String {
        return "\((character?.mysteriousStrangerCount() ?? 0) - (character?.mysteriousStrangerUses ?? 0)) / \(character?.mysteriousStrangerCount() ?? 0)"
    }
    
    private func getUnshakableResolveText() -> String {
        return "\((character?.hasUnshakableResolve() == true ? 1 : 0) - (character?.unshakableResolveUses ?? 0)) / \(character?.hasUnshakableResolve() == true ? 1 : 0)"
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
    
    func hasNewSkills() -> Bool {
        return getNewSkills().isNotEmpty
    }

    func getNewSkills() -> [FullCharacterModifiedSkillModel] {
        return isNpc ? [] : character?.getSkillsTakenSinceLastEvent() ?? []
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

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    let bm = md.playerCheckInBarcodeModel(playerId: 2, characterId: 2, eventId: 2)
//     CheckInPlayerView(isScanning: false, playerCheckInModel: bm, gearModified: true)
//}
