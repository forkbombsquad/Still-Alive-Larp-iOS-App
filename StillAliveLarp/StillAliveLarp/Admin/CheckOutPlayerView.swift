//
//  CheckOutPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/27/23.
//

import SwiftUI
import CodeScanner

struct CheckOutPlayerView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State var isScanning: Bool = true
    @State var barcodeModel: CheckInOutBarcodeModel?

    @State var loading: Bool = false
    @State var loadingText = ""

    @State var player: FullPlayerModel? = nil
    @State var character: FullCharacterModel? = nil
    @State var npc: FullCharacterModel? = nil
    @State var event: FullEventModel? = nil
    @State var eventAttendee: EventAttendeeModel? = nil
    @State var isNpc: Bool = false

    // Editable character fields
    @State var infection: String = "0"
    @State var bullets: String = "0"
    @State var megas: String = "0"
    @State var rivals: String = "0"
    @State var rockets: String = "0"
    @State var bulletCasings: String = "0"
    @State var clothSupplies: String = "0"
    @State var woodSupplies: String = "0"
    @State var metalSupplies: String = "0"
    @State var techSupplies: String = "0"
    @State var medicalSupplies: String = "0"
    @State var mysteriousStrangerUses: String = "0"
    @State var unshakableResolveUses: String = "0"
    @State var armorType: String = "None"
    @State var isAlive: String = "Alive"

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        if isScanning {
            VStack {
                Text("Scan Check Out Code")
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
                            globalCreateTitleView("Check Out Player", DM: DM)
                            LoadingLayoutView {
                                VStack {
                                    if let player = player, let event = event {
                                        Divider().frame(height: 2).overlay(Color.black)
                                        Text("Player")
                                            .font(.system(size: 24, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)

                                        PlayerCheckoutSection(player: player, isNpc: isNpc)

                                        Spacer().frame(height: 16)
                                        Divider().frame(height: 2).overlay(Color.black)
                                        Text("Character")
                                            .font(.system(size: 24, weight: .bold))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)

                                        CharacterCheckoutSection(
                                            character: character,
                                            npc: npc,
                                            isNpc: isNpc,
                                            infection: $infection,
                                            bullets: $bullets,
                                            megas: $megas,
                                            rivals: $rivals,
                                            rockets: $rockets,
                                            bulletCasings: $bulletCasings,
                                            clothSupplies: $clothSupplies,
                                            woodSupplies: $woodSupplies,
                                            metalSupplies: $metalSupplies,
                                            techSupplies: $techSupplies,
                                            medicalSupplies: $medicalSupplies,
                                            mysteriousStrangerUses: $mysteriousStrangerUses,
                                            unshakableResolveUses: $unshakableResolveUses,
                                            armorType: $armorType,
                                            isAlive: $isAlive
                                        )

                                        LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 32, buttonText: "Check Out") {
                                            let valResult = validateFields()
                                            if !valResult.hasError {
                                                if let char = character ?? npc, isAlive == "Alive" && isPassedThreshold(char: char) {
                                                    showThresholdWarning(char: char)
                                                } else if isAlive == "Dead", let char = character ?? npc {
                                                    showDeathCheck(char: char)
                                                } else {
                                                    checkoutStepOne()
                                                }
                                            } else {
                                                alertManager.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
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
                        npc = nil
                        isNpc = false
                    } else {
                        character = nil
                        isNpc = true
                    }

                    event = DM.events.first(where: { $0.id == bar.eventId })

                    if let evt = event {
                        eventAttendee = evt.attendees.first(where: { $0.playerId == bar.playerId && $0.isCheckedIn.boolValueDefaultFalse == true })
                    }

                    updateFieldsFromCharacter()
                }
            }
        })
    }

    private func updateFieldsFromCharacter() {
        let charOrNpc = character ?? npc
        if let char = charOrNpc {
            infection = char.infection.stringValue
            bullets = char.bullets.stringValue
            megas = char.megas.stringValue
            rivals = char.rivals.stringValue
            rockets = char.rockets.stringValue
            bulletCasings = char.bulletCasings.stringValue
            clothSupplies = char.clothSupplies.stringValue
            woodSupplies = char.woodSupplies.stringValue
            metalSupplies = char.metalSupplies.stringValue
            techSupplies = char.techSupplies.stringValue
            medicalSupplies = char.medicalSupplies.stringValue
            armorType = char.armor
            mysteriousStrangerUses = char.mysteriousStrangerUses.stringValue
            unshakableResolveUses = char.unshakableResolveUses.stringValue
            isAlive = char.isAlive ? "Alive" : "Dead"
        } else {
            infection = "0"
            bullets = "0"
            megas = "0"
            rivals = "0"
            rockets = "0"
            bulletCasings = "0"
            clothSupplies = "0"
            woodSupplies = "0"
            metalSupplies = "0"
            techSupplies = "0"
            medicalSupplies = "0"
            armorType = "None"
            mysteriousStrangerUses = "0"
            unshakableResolveUses = "0"
            isAlive = "Alive"
        }
    }

    private func getRelevantSkills() -> [FullCharacterModifiedSkillModel] {
        return (character ?? npc)?.getRelevantBarcodeSkills() ?? []
    }

    private func hasRegressionOrRemission() -> Bool {
        let skills = getRelevantSkills()
        for skill in skills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.regressionTypeSkills) {
                return true
            }
        }
        return false
    }

    private func hasRegression() -> Bool {
        let skills = getRelevantSkills()
        for skill in skills {
            if skill.id == Constants.SpecificSkillIds.regression {
                return true
            }
        }
        return false
    }

    private func hasRemission() -> Bool {
        let skills = getRelevantSkills()
        for skill in skills {
            if skill.id == Constants.SpecificSkillIds.remission {
                return true
            }
        }
        return false
    }

    private func getReductionAmount() -> String {
        if hasRemission() {
            return "1d4"
        }
        if hasRegression() {
            return "1"
        }
        return ""
    }

    private func hasMysteriousStrangerSkills() -> Bool {
        let skills = getRelevantSkills()
        for skill in skills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) {
                return true
            }
        }
        return false
    }

    private func mysteriousStrangerTotal() -> Int {
        let skills = getRelevantSkills()
        var count = 0
        for skill in skills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) {
                count += 1
            }
        }
        return count
    }

    private func hasUnshakableResolve() -> Bool {
        let skills = getRelevantSkills()
        for skill in skills {
            if skill.id == Constants.SpecificSkillIds.unshakableResolve {
                return true
            }
        }
        return false
    }

    private func isPassedThreshold(char: FullCharacterModel) -> Bool {
        let prev = char.infection
        let cur = infection.intValueDefaultZero
        return (prev < 25 && cur >= 25) || (prev < 50 && cur >= 50) || (cur >= 75)
    }

    private func showThresholdWarning(char: FullCharacterModel) {
        let skills = getRelevantSkills()
        let skillsText = getThresholdCheckSkillsList(skills: skills, char: char)
        alertManager.showAlert(
            "Warning!",
            message: "\(char.fullName) has passed an infection threshold! Make sure to check and see if they're a zombie!\n\n\(skillsText)",
            button1: Alert.Button.default(Text("Check Passed!"), action: {
                self.checkoutStepOne()
            }),
            button2: Alert.Button.destructive(Text("Go Back"), action: {
                self.resetScanner()
            })
        )
    }

    private func showDeathCheck(char: FullCharacterModel) {
        let skills = getRelevantSkills()
        let skillsText = getDeathCheckSkillsList(skills: skills)
        alertManager.showAlert(
            "Warning!",
            message: "\(char.fullName) has seemingly perished, but they still have a chance! Make sure you roll 1d10 to see if they miraculously survive (by rolling a 10)!\n\n\(skillsText)",
            button1: Alert.Button.default(Text("Still Dead!"), action: {
                self.checkoutStepOne()
            }),
            button2: Alert.Button.cancel(Text("They Survived! Go Back"), action: {
                self.resetScanner()
            })
        )
    }

    private func getThresholdCheckSkillsList(skills: [FullCharacterModifiedSkillModel], char: FullCharacterModel) -> String {
        var skillsText = ""
        var gamblerCount = 0
        for skill in skills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.gamblerTypeSkills) {
                gamblerCount += 1
            }
            if skill.id == Constants.SpecificSkillIds.willToLive {
                skillsText += "\nWill To Live skill - They may flip a coin instead of rolling. If heads, the roll was a success."
            }
            if skill.id == Constants.SpecificSkillIds.unshakableResolve && char.unshakableResolveUses == 0 {
                skillsText += "\nUnshakable Resolve skill - if all rolls (or flips) fail, you can choose to survive once per character. Make sure to adjust the value above if you use this skill."
            }
        }
        if gamblerCount > 0 {
            skillsText += "\n\(gamblerCount) level(s) of gambler skills, allowing them to reroll dice or reflip coins and take the best result - once for each level of the skill."
        }
        if !skillsText.isEmpty {
            skillsText = "Relevant Skills:\(skillsText)"
        }
        return skillsText
    }

    private func getDeathCheckSkillsList(skills: [FullCharacterModifiedSkillModel]) -> String {
        var skillsText = ""
        var gamblerCount = 0
        for skill in skills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.gamblerTypeSkills) {
                gamblerCount += 1
            }
        }
        if gamblerCount > 0 {
            skillsText = "\n\(gamblerCount) level(s) of gambler skills, allowing them to reroll dice or reflip coins and take the best result - once for each level of the skill."
        }
        if !skillsText.isEmpty {
            skillsText = "Relevant Skills:\(skillsText)"
        }
        return skillsText
    }

    private func validateFields() -> ValidationResult {
        return Validator.validateMultiple([
            ValidationGroup(text: infection, validationType: .infection),
            ValidationGroup(text: bullets, validationType: .bullets),
            ValidationGroup(text: megas, validationType: .megas),
            ValidationGroup(text: rivals, validationType: .rivals),
            ValidationGroup(text: rockets, validationType: .rockets),
            ValidationGroup(text: bulletCasings, validationType: .bulletCasings),
            ValidationGroup(text: clothSupplies, validationType: .clothSupplies),
            ValidationGroup(text: woodSupplies, validationType: .woodSupplies),
            ValidationGroup(text: metalSupplies, validationType: .metalSupplies),
            ValidationGroup(text: techSupplies, validationType: .techSupplies),
            ValidationGroup(text: medicalSupplies, validationType: .medicalSupplies)
        ])
    }

    private func checkoutStepOne() {
        let charOrNpc = character ?? npc
        if let char = charOrNpc {
            self.loading = true
            self.loadingText = isNpc ? "Updating NPC" : "Updating Character"

            let isAliveBool = isAlive == "Alive"

            let editedChar = CharacterModel(
                id: char.id,
                fullName: char.fullName,
                startDate: char.startDate,
                isAlive: isAliveBool ? "TRUE" : "FALSE",
                deathDate: isAliveBool ? "" : Date().yyyyMMddFormatted,
                infection: infection,
                bio: char.bio,
                approvedBio: char.approvedBio ? "TRUE" : "FALSE",
                bullets: bullets,
                megas: megas,
                rivals: rivals,
                rockets: rockets,
                bulletCasings: bulletCasings,
                clothSupplies: clothSupplies,
                woodSupplies: woodSupplies,
                metalSupplies: metalSupplies,
                techSupplies: techSupplies,
                medicalSupplies: medicalSupplies,
                armor: isNpc ? char.armor : armorType,
                unshakableResolveUses: unshakableResolveUses,
                mysteriousStrangerUses: mysteriousStrangerUses,
                playerId: char.playerId,
                characterTypeId: char.characterTypeId
            )

            AdminService.updateCharacter(editedChar) { updatedChar in
                self.checkoutStepTwo(needExtraXp: !self.isNpc && !isAliveBool)
            } failureCase: { error in
                self.loading = false
                self.resetScanner()
            }
        } else {
            checkoutStepTwo(needExtraXp: false)
        }
    }

    private func checkoutStepTwo(needExtraXp: Bool) {
        guard let player = player else {
            loading = false
            resetScanner()
            return
        }

        self.loadingText = "Updating Player"

        let xpAmount = isNpc ? 2 : 1
        let xp = player.experience + xpAmount
        let events = player.numEventsAttended + 1
        let npcEvents = player.numNpcEventsAttended + (isNpc ? 1 : 0)

        let playerUpdate = PlayerModel(
            id: player.id,
            username: player.username,
            fullName: player.fullName,
            startDate: player.startDate,
            experience: xp.stringValue,
            freeTier1Skills: player.freeTier1Skills.stringValue,
            prestigePoints: player.prestigePoints.stringValue,
            isCheckedIn: "FALSE",
            isCheckedInAsNpc: "FALSE",
            lastCheckIn: Date().yyyyMMddFormatted,
            numEventsAttended: events.stringValue,
            numNpcEventsAttended: npcEvents.stringValue,
            isAdmin: player.isAdmin.stringValue
        )

        AdminService.updatePlayer(playerUpdate) { updatedPlayer in
            self.checkoutStepThree(needExtraXp: needExtraXp)
        } failureCase: { error in
            self.loading = false
            self.resetScanner()
        }
    }

    private func checkoutStepThree(needExtraXp: Bool) {
        guard let attendee = eventAttendee else {
            loading = false
            resetScanner()
            return
        }

        self.loadingText = "Updating Records"

        let attendeeUpdate = EventAttendeeModel(
            id: attendee.id,
            playerId: attendee.playerId,
            characterId: attendee.characterId,
            eventId: attendee.eventId,
            isCheckedIn: "FALSE",
            asNpc: isNpc ? "TRUE" : "FALSE",
            npcId: attendee.npcId
        )

        AdminService.updateEventAttendee(attendeeUpdate) { updatedAttendee in
            if needExtraXp, let char = self.character {
                self.checkoutStepFourAwardDeathXp(character: char)
            } else {
                self.loading = false
                self.showSuccessAlertAllowingRescan("Successfully Checked Out \(self.player?.fullName ?? "Player")!")
            }
        } failureCase: { error in
            self.loading = false
            resetScanner()
        }
    }

    private func checkoutStepFourAwardDeathXp(character: FullCharacterModel) {
        guard let player = player else {
            loading = false
            showSuccessAlertAllowingRescan("Successfully Checked Out \(self.player?.fullName ?? "Player")!")
            return
        }

        self.loadingText = "Calculating Death Xp Bonus"

        let spentXp = character.getAllXpSpent()
        let spentPp = character.getAllSpentPrestigePoints()
        var adjustedXp = spentXp / 2

        var max = player.numEventsAttended
        max += player.numNpcEventsAttended
        adjustedXp = min(max, adjustedXp)

        self.loadingText = "Refunding Xp"

        let award = AwardCreateModel(
            playerId: player.id,
            characterId: nil,
            awardType: "xp",
            reason: "Death of Character: \(character.fullName)",
            date: Date().yyyyMMddFormatted,
            amount: adjustedXp.stringValue
        )

        AdminService.awardPlayer(award) { updatedPlayer in
            if spentPp > 0 {
                self.loadingText = "Refunding Prestige Points"

                let ppAward = AwardCreateModel(
                    playerId: player.id,
                    characterId: nil,
                    awardType: "prestige_points",
                    reason: "Death of Character: \(character.fullName)",
                    date: Date().yyyyMMddFormatted,
                    amount: spentPp.stringValue
                )

                AdminService.awardPlayer(ppAward) { updatedPlayer2 in
                    self.loading = false
                    self.showSuccessAlertAllowingRescan("Successfully Checked Out \(player.fullName)!")
                } failureCase: { error in
                    self.loading = false
                    self.showSuccessAlertAllowingRescan("Successfully Checked Out \(player.fullName)!\nBut unable to award death pp!")
                }
            } else {
                self.loading = false
                self.showSuccessAlertAllowingRescan("Successfully Checked Out \(player.fullName)!")
            }
        } failureCase: { error in
            self.loading = false
            self.showSuccessAlertAllowingRescan("Successfully Checked Out \(player.fullName)!\nBut unable to award death xp!")
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

    func resetScanner() {
        self.isScanning = true
        self.barcodeModel = nil
        self.character = nil
        self.npc = nil
        self.player = nil
        self.event = nil
        self.eventAttendee = nil
    }

    func showSuccessAlertAllowingRescan(_ message: String) {
        runOnMainThread {
            alertManager.showAlert("Success", message: message, button1: Alert.Button.default(Text("Keep Scanning"), action: {
                self.resetScanner()
            }), button2: Alert.Button.cancel(Text("Finished"), action: {
                runOnMainThread {
                    self.mode.wrappedValue.dismiss()
                }
            }))
        }
    }
}

struct PlayerCheckoutSection: View {
    let player: FullPlayerModel
    let isNpc: Bool

    var body: some View {
        VStack {
            KeyValueView(key: "Name", value: player.fullName)
            KeyValueView(key: "Total Events Attended", value: "\(player.numEventsAttended)+1")
            KeyValueView(key: "Total NPC Events Attended", value: "\(player.numNpcEventsAttended)\(isNpc ? "+1" : "")")
            KeyValueView(key: "Last Event Attended", value: player.lastCheckIn.yyyyMMddToMonthDayYear(), showDivider: false)
        }
    }
}

struct CharacterCheckoutSection: View {
    let character: FullCharacterModel?
    let npc: FullCharacterModel?
    let isNpc: Bool

    @Binding var infection: String
    @Binding var bullets: String
    @Binding var megas: String
    @Binding var rivals: String
    @Binding var rockets: String
    @Binding var bulletCasings: String
    @Binding var clothSupplies: String
    @Binding var woodSupplies: String
    @Binding var metalSupplies: String
    @Binding var techSupplies: String
    @Binding var medicalSupplies: String
    @Binding var mysteriousStrangerUses: String
    @Binding var unshakableResolveUses: String
    @Binding var armorType: String
    @Binding var isAlive: String

    private var charOrNpc: FullCharacterModel? {
        character ?? npc
    }

    private var relevantSkills: [FullCharacterModifiedSkillModel] {
        charOrNpc?.getRelevantBarcodeSkills() ?? []
    }

    private func hasRegressionOrRemission() -> Bool {
        for skill in relevantSkills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.regressionTypeSkills) {
                return true
            }
        }
        return false
    }

    private func hasRegression() -> Bool {
        for skill in relevantSkills {
            if skill.id == Constants.SpecificSkillIds.regression {
                return true
            }
        }
        return false
    }

    private func hasRemission() -> Bool {
        for skill in relevantSkills {
            if skill.id == Constants.SpecificSkillIds.remission {
                return true
            }
        }
        return false
    }

    private func getReductionAmount() -> String {
        if hasRemission() {
            return "1d4"
        }
        if hasRegression() {
            return "1"
        }
        return ""
    }

    private func hasMysteriousStrangerSkills() -> Bool {
        for skill in relevantSkills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) {
                return true
            }
        }
        return false
    }

    private func mysteriousStrangerTotal() -> Int {
        var count = 0
        for skill in relevantSkills {
            if skill.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) {
                count += 1
            }
        }
        return count
    }

    private func hasUnshakableResolve() -> Bool {
        for skill in relevantSkills {
            if skill.id == Constants.SpecificSkillIds.unshakableResolve {
                return true
            }
        }
        return false
    }

    var body: some View {
        VStack {
            if let char = charOrNpc {
                KeyValueView(key: "Name", value: isNpc ? "\(char.fullName) - NPC" : char.fullName, showDivider: false)

                if hasRegressionOrRemission() {
                    KeyValueView(key: "REDUCE INFECTION BY", value: getReductionAmount(), showDivider: true)
                }

                TextFieldWithKey(text: $infection, key: "Infection")

                if !isNpc {
                    CharacterAmmoCheckoutView(bullets: $bullets, megas: $megas, rivals: $rivals, rockets: $rockets)
                    CharacterSuppliesCheckoutView(bulletCasings: $bulletCasings, clothSupplies: $clothSupplies, woodSupplies: $woodSupplies, metalSupplies: $metalSupplies, techSupplies: $techSupplies, medicalSupplies: $medicalSupplies)
                } else {
                    TextFieldWithKey(text: $bullets, key: "Bullets")
                }

                if hasMysteriousStrangerSkills() {
                    TextFieldWithKey(text: $mysteriousStrangerUses, key: "Mysterious Stranger Uses (out of \(mysteriousStrangerTotal()))")
                }

                if hasUnshakableResolve() {
                    TextFieldWithKey(text: $unshakableResolveUses, key: "Unshakable Resolve Uses (out of 1)")
                }

                if !isNpc {
                    let armorOptions = ["None", "Metal", "Bullet Proof"]
                    PickerViewWithKey(key: "Armor", selectedOption: $armorType, options: armorOptions)
                }

                let aliveOptions = ["Alive", "Dead"]
                PickerViewWithKey(key: "Is Alive?", selectedOption: $isAlive, options: aliveOptions)
            } else {
                KeyValueView(key: "Name", value: "NPC", showDivider: false)
            }
        }
    }
}

struct CharacterAmmoCheckoutView: View {
    @Binding var bullets: String
    @Binding var megas: String
    @Binding var rivals: String
    @Binding var rockets: String

    var body: some View {
        VStack {
            TextFieldWithKey(text: $bullets, key: "Bullets")
            TextFieldWithKey(text: $megas, key: "Megas")
            TextFieldWithKey(text: $rivals, key: "Rivals")
            TextFieldWithKey(text: $rockets, key: "Rockets")
        }
    }
}

struct CharacterSuppliesCheckoutView: View {
    @Binding var bulletCasings: String
    @Binding var clothSupplies: String
    @Binding var woodSupplies: String
    @Binding var metalSupplies: String
    @Binding var techSupplies: String
    @Binding var medicalSupplies: String

    var body: some View {
        VStack {
            TextFieldWithKey(text: $bulletCasings, key: "Bullet Casings")
            TextFieldWithKey(text: $clothSupplies, key: "Cloth Supplies")
            TextFieldWithKey(text: $woodSupplies, key: "Wood Supplies")
            TextFieldWithKey(text: $metalSupplies, key: "Metal Supplies")
            TextFieldWithKey(text: $techSupplies, key: "Tech Supplies")
            TextFieldWithKey(text: $medicalSupplies, key: "Medical Supplies")
        }
    }
}

struct TextFieldWithKey: View {
    @Binding var text: String
    let key: String

    var body: some View {
        VStack {
            KeyValueView(key: key, value: "", showDivider: false)
            TextField("", text: $text)
                .padding(.trailing, 0)
                .textFieldStyle(.roundedBorder)
                .placeholder(when: text.isEmpty) {
                    Text(key).foregroundColor(.gray).padding().padding(.top, 4)
                }
            Divider()
        }
    }
}

struct PickerViewWithKey: View {
    let key: String
    @Binding var selectedOption: String
    let options: [String]

    var body: some View {
        VStack {
            KeyValueView(key: key, value: "", showDivider: false)
            Picker(selection: $selectedOption, label: Text("Choose \(key)")) {
                ForEach(options, id: \.self) { type in
                    Text(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.trailing, 0)
            Divider()
        }
    }
}
