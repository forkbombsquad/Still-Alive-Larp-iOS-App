//
//  CharacterPlannerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/20/25.
//

import SwiftUI

struct CharacterPlannerView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var player: FullPlayerModel
    
    @State var loading: Bool = false
    @State var loadingText: String = ""
    @State var newName: String = ""
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        globalCreateTitleView("\(player.fullName)'s\nPlanned Characters", DM: DM)
                        LoadingLayoutView {
                            VStack {
                                if loading {
                                    LoadingBlockWithText(loadingText: $loadingText)
                                } else {
                                    // TODO add swipe to delete one day
//                                    Text("*Swipe away a Planned Character to delete it*")
                                    LazyVStack(spacing: 8) {
                                        ForEach(player.getPlannedCharacters()) { plannedChar in
                                            NavArrowViewBlue(title: plannedChar.fullName, loading: $loading) {
                                                ViewCharacterView(character: plannedChar)
                                            }
                                        }
                                    }
                                    ArrowViewButtonGreen(title: "Start A New Plan", loading: $loading) {
                                        alertManager.showDynamicAlert(model: CustomAlertModel(
                                            title: "Create a new plan or base one off of an existing Character?",
                                            textFields: [],
                                            checkboxes: [],
                                            verticalButtons:
                                                [AlertButton(title: "New Plan", onPress: {
                                                    runOnMainThread {
                                                        self.createCharacter(nil)
                                                    }
                                                })] + self.getCharacterChoices()
                                            , buttons: [
                                                AlertButton.cancel {}
                                            ]))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
    
    private func getCharacterChoices() -> [AlertButton] {
        var choices: [AlertButton] = []
        if let ac = player.getActiveCharacter() {
            choices.append(AlertButton(title: ac.fullName, onPress: {
                runOnMainThread {
                    self.createCharacter(ac)
                }
            }))
        }
        for char in player.getInactiveCharacters() {
            choices.append(AlertButton(title: char.fullName, onPress: {
                runOnMainThread {
                    self.createCharacter(char)
                }
            }))
        }
        for char in player.getPlannedCharacters() {
            choices.append(AlertButton(title: char.fullName, onPress: {
                runOnMainThread {
                    self.createCharacter(char)
                }
            }))
        }
        return choices
    }
    
    private func createCharacter(_ existing: FullCharacterModel?) {
        self.newName = ""
        alertManager.showDynamicAlert(model: CustomAlertModel(
            title: "Creating Plan", textFields: [
                AlertTextField(placeholder: "Name your planned character", value: $newName)
            ], checkboxes: [], verticalButtons: [], buttons: [
                AlertButton(title: "Continue", onPress: {
                    runOnMainThread {
                        
                        var name = self.newName
                        if let existing = existing {
                            name += " (\(existing.fullName))"
                        }
                        
                        self.loadingText = "Creating Base Model..."
                        self.loading = true
                        
                        let createModel = CreateCharacterModel(
                            fullName: name,
                            startDate: Date().yyyyMMddFormatted,
                            isAlive: "TRUE",
                            deathDate: "",
                            infection: "0",
                            bio: "",
                            approvedBio: "FALSE",
                            bullets: "20", megas: "0", rivals: "0", rockets: "0", bulletCasings: "0", clothSupplies: "0", woodSupplies: "0", metalSupplies: "0", techSupplies: "0", medicalSupplies: "0", armor: CharacterModel.ArmorType.none.rawValue, unshakableResolveUses: "0", mysteriousStrangerUses: "0", playerId: player.id, characterTypeId: Constants.CharacterTypes.planner)
                        
                        CharacterService.createPlannedCharacter(createModel) { newChar in
                            runOnMainThread {
                                if let existing = existing {
                                    self.addSkillsForExisting(newChar: newChar, existingChar: existing)
                                } else {
                                    self.reload()
                                }
                            }
                        } failureCase: { error in
                            runOnMainThread {
                                self.loading = false
                            }
                        }
                        
                    }

                })
            ]))
    }
    
    private func addSkillsForExisting(newChar: CharacterModel, existingChar: FullCharacterModel) {
        self.loadingText = "Fetching Skills..."
        CharacterSkillService.getAllSkillsForChar(existingChar.id) { charSkills in
            runOnMainThread {
                var count = 0
                let skls = charSkills.charSkills.filter({ $0.xpSpent > 0 || $0.fsSpent > 0 })
                self.loadingText = "Populating Skills (0 / \(skls.count))..."
                for skl in skls {
                    let charSkill = CharacterSkillCreateModel(characterId: newChar.id, skillId: skl.skillId, xpSpent: skl.xpSpent, fsSpent: skl.fsSpent, ppSpent: skl.ppSpent)
                    CharacterSkillService.takePlannedCharacterSkill(charSkill) { charSkill in
                        runOnMainThread {
                            count += 1
                            self.loadingText = "Populating Skills (\(count) / \(skls.count))..."
                            if count >= skls.count {
                                self.reload()
                            }
                        }
                    } failureCase: { error in
                        runOnMainThread {
                            count += 1
                            self.loadingText = "Populating Skills (\(count) / \(skls.count))..."
                            if count >= skls.count {
                                self.reload()
                            }
                        }
                    }

                }
            }
        } failureCase: { error in
            runOnMainThread {
                self.loading = false
            }
        }

    }
    
    private func reload() {
        runOnMainThread {
            DM.load(finished: {
                runOnMainThread {
                    self.player = DM.players.first(where: { $0.id == player.id }) ?? player
                }
            })
            self.loading = false
        }
    }
}
