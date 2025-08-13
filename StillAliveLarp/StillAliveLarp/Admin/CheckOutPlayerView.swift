//
//  CheckOutPlayerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/27/23.
//

import SwiftUI
import CodeScanner

// TODO redo this view

struct CheckOutPlayerView: View {
//    @EnvironmentObject var alertManager: AlertManager
//    @EnvironmentObject var DM: DataManager
//
//    @State var loadingText = ""
//
//    @State var isScanning: Bool = true
//    @State var playerCheckOutModel: PlayerCheckOutBarcodeModel?
//
//    @State var loading: Bool = false
//
//    @State var infection: String = "0"
//    @State var bullets: String = "0"
//    @State var megas: String = "0"
//    @State var rivals: String = "0"
//    @State var rockets: String = "0"
//    @State var bulletCasings: String = "0"
//    @State var clothSupplies: String = "0"
//    @State var woodSupplies: String = "0"
//    @State var metalSupplies: String = "0"
//    @State var techSupplies: String = "0"
//    @State var medicalSupplies: String = "0"
//    @State var unshakableResolveUses: String = "0"
//    @State var mysteriousStrangerUses: String = "0"
//
//    @State private var isAlive: String = "Alive"
//    @State private var aliveOptions = ["Alive", "Dead"]
//
//    @State var armorType: String = CharacterModel.ArmorType.none.rawValue
//    @State private var armorOptions = [CharacterModel.ArmorType.none.rawValue, CharacterModel.ArmorType.metal.rawValue, CharacterModel.ArmorType.bulletProof.rawValue]
//
//    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        EmptyView()
//        if isScanning {
//            VStack {
//                Text("Scan Check Out Code")
//                    .font(.system(size: 32, weight: .bold))
//                    .multilineTextAlignment(.center)
//                    .frame(alignment: .center)
//                    .padding([.bottom], 16)
//                CodeScannerView(codeTypes: [.qr]) { result in
//                    self.isScanning = false
//                    switch result {
//                    case .success(let data):
//                        guard let json = data.string.decompress() else {
//                            self.scannerFailed("Unable to parse data")
//                            return
//                        }
//                        guard let model: PlayerCheckOutBarcodeModel = json.toJsonObject() else {
//                            self.scannerFailed("Unable to parse data")
//                            return
//                        }
//                        self.playerCheckOutModel = model
//                        self.updateFields()
//                        self.isScanning = false
//                    case .failure(let error):
//                        self.scannerFailed(error.localizedDescription)
//                    }
//                }
//            }
//        } else if let model = playerCheckOutModel {
//            VStack(alignment: .center) {
//                GeometryReader { gr in
//                    ScrollView {
//                        VStack(alignment: .center) {
//                            Text("Check Out Player")
//                                .font(.system(size: 32, weight: .bold))
//                                .multilineTextAlignment(.center)
//                                .frame(alignment: .center)
//                                .padding([.bottom], 16)
//                            Divider()
//
//                            //  Player Section
//                            PlayerBarcodeView(player: model.player, isCheckout: true, isNPC: model.character == nil)
//                            Spacer().frame(height: 48)
//
//                            // Character/NPC Section
//                            KeyValueView(key: "Character", value: "", showDivider: false)
//                            if let character = model.character {
//                                CharacterCheckoutBarcodeView(character: character, relevantSkills: model.relevantSkills, infection: $infection, bullets: $bullets, megas: $megas, rivals: $rivals, rockets: $rockets, bulletCasings: $bulletCasings, clothSupplies: $clothSupplies, woodSupplies: $woodSupplies, metalSupplies: $metalSupplies, techSupplies: $techSupplies, medicalSupplies: $medicalSupplies, armorType: $armorType, armorOptions: $armorOptions, isAlive: $isAlive, aliveOptions: $aliveOptions, unshakableResolveUses: $unshakableResolveUses, mysteriousStrangerUses: $mysteriousStrangerUses)
//                            } else {
//                                KeyValueView(key: "Name", value: "NPC")
//                            }
//
//                            // Approve Section
//                            LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 32, buttonText: "Check Out") {
//                                let valResult = validateFields()
//                                if !valResult.hasError {
//                                    if let char = model.character, isPassedThreshold(char), self.isAlive.lowercased() == "alive" {
//                                        runOnMainThread {
//                                            alertManager.showAlert("Warning!", message: "\(char.fullName) has passed an infection threshold! Make sure to check and see if they're a zombie!\n\n\(getThresholdCheckSkills(model.relevantSkills, char: char))", button1: Alert.Button.default(Text("Check Passed!"), action: {
//                                                self.checkoutStepOne(model)
//                                            }), button2: Alert.Button.destructive(Text("Go Back"), action: { }))
//                                        }
//                                    } else {
//                                        self.checkoutStepOne(model)
//                                    }
//                                } else {
//                                    alertManager.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
//                                }
//
//                            }.padding(.top, 48)
//                        }
//                    }
//                }
//            }
//            .padding(16)
//            .background(Color.lightGray)
//            .onAppear {
//                self.updateFields()
//            }
//        } else {
//            VStack(alignment: .center) {
//                Text("Something Went Wrong")
//                    .font(.system(size: 32, weight: .bold))
//                    .multilineTextAlignment(.center)
//                    .frame(alignment: .center)
//                    .padding([.bottom], 16)
//            }
//        }
    }

//    fileprivate func updateFields() {
//        if let c = self.playerCheckOutModel?.character {
//            self.infection = c.infection
//            self.bullets = c.bullets
//            self.megas = c.megas
//            self.rivals = c.rivals
//            self.rockets = c.rockets
//            self.bulletCasings = c.bulletCasings
//            self.clothSupplies = c.clothSupplies
//            self.woodSupplies = c.woodSupplies
//            self.metalSupplies = c.metalSupplies
//            self.techSupplies = c.techSupplies
//            self.medicalSupplies = c.medicalSupplies
//            if let a = CharacterModel.ArmorType(rawValue: c.armor) {
//                self.armorType = a.rawValue
//            }
//            self.isAlive = "Alive"
//            self.unshakableResolveUses = c.unshakableResolveUses
//            self.mysteriousStrangerUses = c.mysteriousStrangerUses
//        }
//    }
    
//    private func checkoutStepOne(_ model: PlayerCheckOutBarcodeModel) {
//        if let char = model.character, isAlive.lowercased() == "dead" {
//            runOnMainThread {
//                alertManager.showAlert("Warning!", message: "\(char.fullName) has seeming perished, but they still have a chance! Make sure you roll 1d10 to see if they miraculously survive!\n\n\(getDeathCheckSkills(model.relevantSkills, char: char))", button1: Alert.Button.default(Text("Still Dead!"), action: {
//                    self.checkoutStepTwo(model)
//                }), button2: Alert.Button.cancel(Text("They Survived! Go Back"), action: { }))
//            }
//        } else {
//            checkoutStepTwo(model)
//        }
//    }

//    private func checkoutStepTwo(_ model: PlayerCheckOutBarcodeModel) {
//        self.loading = true
//        if let char = model.character {
//            self.loadingText = "Loading Character"
//            CharacterService.getCharacter(char.id) { cm in
//                let editedChar = CharacterModel(id: cm.id, fullName: cm.fullName, startDate: cm.startDate, isAlive: self.isAlive.lowercased() == "alive" ? "TRUE" : "FALSE", deathDate: self.isAlive.lowercased() == "alive" ? "" : Date().yyyyMMddFormatted, infection: self.infection, bio: cm.bio, approvedBio: cm.approvedBio, bullets: self.bullets, megas: self.megas, rivals: self.rivals, rockets: self.rockets, bulletCasings: self.bulletCasings, clothSupplies: self.clothSupplies, woodSupplies: self.woodSupplies, metalSupplies: self.metalSupplies, techSupplies: self.techSupplies, medicalSupplies: self.medicalSupplies, armor: self.armorType, unshakableResolveUses: self.unshakableResolveUses, mysteriousStrangerUses: self.mysteriousStrangerUses, playerId: cm.playerId, characterTypeId: cm.characterTypeId)
//                self.loadingText = "Updating Character"
//                AdminService.updateCharacter(editedChar) { _ in
//                    self.checkoutStepThree(model)
//                } failureCase: { error in
//                    self.loading = false
//                    resetScanner()
//                }
//            } failureCase: { error in
//                self.loading = false
//                resetScanner()
//            }
//
//        } else {
//            checkoutStepThree(model)
//        }
//    }

//    private func checkoutStepThree(_ model: PlayerCheckOutBarcodeModel) {
//        var needToAwardExtraXp = false
//        var xpAmount = 0
//        if model.character != nil {
//            xpAmount = 1
//            if self.isAlive.lowercased() == "dead" {
//                needToAwardExtraXp = true
//            }
//        } else {
//            xpAmount = 2
//        }
//
//        self.loadingText = "Loading Player"
//        PlayerService.getPlayer(model.player.id) { player in
//            let xp = player.experience.intValueDefaultZero + xpAmount
//            let events = player.numEventsAttended.intValueDefaultZero + 1
//            let npcEvents = player.numNpcEventsAttended.intValueDefaultZero + (model.character == nil ? 1 : 0)
//
//            let playerUpdate = PlayerModel(id: player.id, username: player.username, fullName: player.fullName, startDate: player.startDate, experience: "\(xp)", freeTier1Skills: player.freeTier1Skills, prestigePoints: player.prestigePoints, isCheckedIn: "FALSE", isCheckedInAsNpc: "FALSE", lastCheckIn: Date().yyyyMMddFormatted, numEventsAttended: "\(events)", numNpcEventsAttended: "\(npcEvents)", isAdmin: player.isAdmin)
//            self.loadingText = "Updating Player"
//            AdminService.updatePlayer(playerUpdate) { _ in
//                self.checkoutStepFour(model, awardExtraXp: needToAwardExtraXp)
//            } failureCase: { error in
//                self.loading = false
//                resetScanner()
//            }
//
//        } failureCase: { error in
//            self.loading = false
//            resetScanner()
//        }
//    }

//    private func checkoutStepFour(_ model: PlayerCheckOutBarcodeModel, awardExtraXp: Bool) {
//        let ea = EventAttendeeModel(id: model.eventAttendeeId, playerId: model.player.id, characterId: model.character?.id, eventId: model.eventId, isCheckedIn: "FALSE", asNpc: model.character == nil ? "TRUE" : "FALSE")
//        self.loadingText = "Updating Records"
//        AdminService.updateEventAttendee(ea) { eventAttendee in
//            if awardExtraXp, let char = model.character {
//                self.loadingText = "Loading Character For\nDeath XP Bonus"
//                CharacterService.getCharacter(char.id) { characterModel in
//                    self.loadingText = "Loading Skills For\nDeath XP Bonus"
//                    characterModel.getAllXpSpent { xp in
//
//                        var adjustedXp = xp / 2
//
//                        var max = model.player.numEventsAttended.intValueDefaultZero
//                        max += model.player.numNpcEventsAttended.intValueDefaultZero
//
//                        adjustedXp = min(max, adjustedXp)
//
//                        self.loadingText = "Refunding Death Xp"
//                        let award = AwardCreateModel(playerId: model.player.id, characterId: nil, awardType: AdminService.PlayerAwardType.xp.rawValue, reason: "Death of character: \(model.character?.fullName ?? "")", date: Date().yyyyMMddFormatted, amount: "\(adjustedXp)")
//
//                        AdminService.awardPlayer(award) { _ in
//
//                            characterModel.getAllSpentPrestige { pp in
//
//                                if pp > 0 {
//                                    self.loadingText = "Refunding Death Pp"
//                                    let awd = AwardCreateModel(playerId: model.player.id, characterId: nil, awardType: AdminService.PlayerAwardType.prestigePoints.rawValue, reason: "Death of character: \(model.character?.fullName ?? "")", date: Date().yyyyMMddFormatted, amount: "\(pp)")
//
//                                    AdminService.awardPlayer(awd) { updatedPlayer in
//                                        self.loading = false
//                                        showSuccessAlertAllowingRescan("Successfully Checked Out!")
//                                    } failureCase: { error in
//                                        self.loading = false
//                                        showSuccessAlertAllowingRescan("Successfully Checked Out but unable to award death pp!")
//                                    }
//
//                                } else {
//                                    self.loading = false
//                                    showSuccessAlertAllowingRescan("Successfully Checked Out!")
//                                }
//
//
//                            } failureCase: { error in
//                                self.loading = false
//                                showSuccessAlertAllowingRescan("Successfully Checked Out but unable to award death xp!")
//                            }
//
//                            self.loading = false
//                            showSuccessAlertAllowingRescan("Successfully Checked Out!")
//                        } failureCase: { error in
//                            self.loading = false
//                            showSuccessAlertAllowingRescan("Successfully Checked Out but unable to award death xp!")
//                        }
//
//                    } failureCase: { error in
//                        self.loading = false
//                        showSuccessAlertAllowingRescan("Successfully Checked Out but unable to award death xp!")
//                    }
//                } failureCase: { error in
//                    self.loading = false
//                    showSuccessAlertAllowingRescan("Successfully Checked Out but unable to award death xp!")
//                }
//
//            } else {
//                self.loading = false
//                showSuccessAlertAllowingRescan("Successfully Checked Out!")
//            }
//        } failureCase: { error in
//            self.loading = false
//            resetScanner()
//        }
//    }

//    private func getDeathCheckSkills(_ skills: [SkillBarcodeModel], char: CharacterBarcodeModel) -> String {
//        typealias skl = Constants.SpecificSkillIds
//        var string = ""
//        var gamblerAmount = 0
//        for skill in skills {
//            if skill.id.equalsAnyOf(skl.gamblerTypeSkills) {
//                gamblerAmount += 1
//                continue
//            }
//        }
//        if gamblerAmount > 0 {
//            string = "\n\(gamblerAmount) level(s) of gambler skills, allowing them to reroll dice or reflip coins and take the better result, once for each level."
//        }
//        if !string.isEmpty {
//            string = "Relevant Skills:\(string)"
//        }
//        return string
//    }

//    private func getThresholdCheckSkills(_ skills: [SkillBarcodeModel], char: CharacterBarcodeModel) -> String {
//        typealias skl = Constants.SpecificSkillIds
//        var string = ""
//        var gamblerAmount = 0
//        for skill in skills {
//            if skill.id.equalsAnyOf(skl.gamblerTypeSkills) {
//                gamblerAmount += 1
//                continue
//            }
//            if skill.id == skl.willToLive {
//                string  = "\(string)\nWill To Live skill - They may flip a coin instead of rolling. If heads, the roll was a success."
//            }
//            if skill.id == skl.unshakableResolve && char.unshakableResolveUses.intValueDefaultZero == 0 {
//                string  = "\(string)\nUnshakable Resolve skill - If all rolls an flips fail, you can choose to survive once per character. Make sure to adjust the value above if you use this skill."
//            }
//        }
//        if gamblerAmount > 0 {
//            string = "\(string)\n\(gamblerAmount) level(s) of gambler skills, allowing them to reroll dice or reflip coins and take the better result, once for each level."
//        }
//        if !string.isEmpty {
//            string = "Relevant Skills:\(string)"
//        }
//        return string
//    }

//    private func validateFields() -> ValidationResult {
//        return Validator.validateMultiple([
//            ValidationGroup(text: infection, validationType: .infection),
//            ValidationGroup(text: bullets, validationType: .bullets),
//            ValidationGroup(text: megas, validationType: .megas),
//            ValidationGroup(text: rivals, validationType: .rivals),
//            ValidationGroup(text: rockets, validationType: .rockets),
//            ValidationGroup(text: bulletCasings, validationType: .bulletCasings),
//            ValidationGroup(text: clothSupplies, validationType: .clothSupplies),
//            ValidationGroup(text: woodSupplies, validationType: .woodSupplies),
//            ValidationGroup(text: metalSupplies, validationType: .metalSupplies),
//            ValidationGroup(text: techSupplies, validationType: .techSupplies),
//            ValidationGroup(text: medicalSupplies, validationType: .medicalSupplies)
//        ])
//    }

//    func scannerFailed(_ errorMessage: String) {
//        runOnMainThread {
//            alertManager.showOkAlert("Scanning Failed", message: errorMessage) {
//                runOnMainThread {
//                    self.mode.wrappedValue.dismiss()
//                }
//            }
//        }
//    }

//    func resetScanner() {
//        self.isScanning = true
//        self.playerCheckOutModel = nil
//    }

//    func showSuccessAlertAllowingRescan(_ message: String) {
//        runOnMainThread {
//            alertManager.showAlert("Success", message: message, button1: Alert.Button.default(Text("Keep Scanning"), action: {
//                self.resetScanner()
//            }), button2: Alert.Button.cancel(Text("Finished"), action: {
//                runOnMainThread {
//                    self.mode.wrappedValue.dismiss()
//                }
//            }))
//        }
//    }

//    func isPassedThreshold(_ char: CharacterBarcodeModel) -> Bool {
//        let prev = char.infection.intValueDefaultZero
//        let cur = self.infection.intValueDefaultZero
//
//        if prev < 25 && cur >= 25 {
//            return true
//        } else if prev < 50 && cur >= 50 {
//            return true
//        } else if cur >= 75 {
//            return true
//        } else {
//            return false
//        }
//
//    }

}

struct CharacterCheckoutBarcodeView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel
    let relevantSkills: [FullCharacterModifiedSkillModel]

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
    @Binding var armorType: String
    @Binding var armorOptions: [String]
    @Binding var isAlive: String
    @Binding var aliveOptions: [String]
    @Binding var unshakableResolveUses: String
    @Binding var mysteriousStrangerUses: String

    var body: some View {
        VStack {
            KeyValueView(key: "Name", value: character.fullName)
            if hasRegressionOrRemission() {
                KeyValueView(key: "REDUCE INFECTION BY", value: getReductionAmount(), showDivider: false)
            }
            TextFieldWithKey(text: $infection, key: "Infection")
            CharacterAmmoCheckoutView(bullets: $bullets, megas: $megas, rivals: $rivals, rockets: $rockets)
            CharacterSuppliesCheckoutView(bulletCasings: $bulletCasings, clothSupplies: $clothSupplies, woodSupplies: $woodSupplies, metalSupplies: $metalSupplies, techSupplies: $techSupplies, medicalSupplies: $medicalSupplies)
            if hasMysteriousStrangerSkills() {
                TextFieldWithKey(text: $mysteriousStrangerUses, key: "Mysterious Stranger Uses (out of \(mysteriousStrangerTotal()))")
            }
            if hasUnshakableResolve() {
                TextFieldWithKey(text: $unshakableResolveUses, key: "Unshakable Resolve Uses (out of 1)")
            }
            PickerViewWithKey(key: "Armor", selectedOption: $armorType, options: $armorOptions)
            PickerViewWithKey(key: "Is Alive?", selectedOption: $isAlive, options: $aliveOptions)
        }
    }

    func hasUnshakableResolve() -> Bool {
        for skill in relevantSkills {
            guard  skill.id == Constants.SpecificSkillIds.unshakableResolve else { continue }
            return true
        }
        return false
    }

    func hasMysteriousStrangerSkills() -> Bool {
        for skill in relevantSkills {
            guard  skill.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) else { continue }
            return true
        }
        return false
    }

    func mysteriousStrangerTotal() -> String {
        var count = 0
        for skill in relevantSkills {
            guard  skill.id.equalsAnyOf(Constants.SpecificSkillIds.mysteriousStrangerTypeSkills) else { continue }
            count += 1
        }
        return "\(count)"
    }

    func hasRegressionOrRemission() -> Bool {
        for sk in relevantSkills {
            guard sk.id.equalsAnyOf(Constants.SpecificSkillIds.regressionTypeSkills) else { continue }
            return true
        }
        return false
    }

    func hasRegressionSkill() -> Bool {
        for sk in relevantSkills {
            guard sk.id == Constants.SpecificSkillIds.regression else { continue }
            return true
        }
        return false
    }

    func hasRemissionSkill() -> Bool {
        for sk in relevantSkills {
            guard sk.id == Constants.SpecificSkillIds.remission else { continue }
            return true
        }
        return false
    }

    func getReductionAmount() -> String {
        if hasRemissionSkill() {
            return "1d4"
        }
        if hasRegressionSkill() {
            return "1"
        }
        return ""
    }

}

struct CharacterAmmoCheckoutView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

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
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

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
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Binding var text: String
    let key: String

    var body: some View {
        VStack {
            KeyValueView(key: key, value: "", showDivider: false)
            CustomTextField(text: $text, placeholder: key)
            Divider()
        }


    }

}

struct CustomTextField: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextField("", text: $text)
            .padding(.trailing, 0)
            .textFieldStyle(.roundedBorder)
            .placeholder(when: text.isEmpty) {
                Text(placeholder).foregroundColor(.gray).padding().padding(.top, 4)
            }
    }

}

fileprivate struct PickerViewWithKey: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let key: String
    @Binding var selectedOption: String
    @Binding var options: [String]

    var body: some View {
        KeyValueView(key: key, value: "", showDivider: false)
        Picker(selection: $selectedOption, label: Text("Choose Armor")) {
            ForEach(options, id: \.self) { type in
                Text(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.trailing, 0)
        Divider()
    }

}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return CheckOutPlayerView(isScanning: false, playerCheckOutModel: md.playerCheckOutBarcodeModel(playerId: 3, characterId: 3, eventAttendeeId: 3, eventId: 1))
//}
