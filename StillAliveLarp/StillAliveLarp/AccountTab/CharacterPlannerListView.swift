//
//  CharacterPlannerListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/20/25.
//

import SwiftUI

struct CharacterPlannerListView: View {
    
    @ObservedObject var _dm = DataManager.shared
    
    let player: PlayerModel
    
    @State var loading: Bool = false
    @State var loadingText: String = ""
    @State var allRegularCharacters: [CharacterModel] = []
    @State var allPlannedCharacters: [CharacterModel] = []
    
    @State var loadingFullCharacter: Bool = false
    
    @State var newName: String = ""
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Planned Characters")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        if loading {
                            LoadingBlockWithText(loadingText: $loadingText)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(allPlannedCharacters) { plannedChar in
                                    NavArrowViewBlue(title: plannedChar.fullName, loading: $loadingFullCharacter) {
                                        SkillManagementPlannerView(character: plannedChar)
                                    }
                                }
                            }
                            ArrowViewButtonGreen(title: "Start A New Plan", loading: $loadingFullCharacter) {
                                AlertManager.shared.showDynamicAlert(model: CustomAlertModel(
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
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            self.loadingText = "Loading Planned Characters..."
            self.loading = true
            OldDataManager.shared.player = player
            OldDataManager.shared.load([.allCharacters, .plannedCharacters]) {
                runOnMainThread {
                    self.allRegularCharacters = OldDataManager.shared.allCharacters?.filter({ $0.playerId == self.player.id }) ?? []
                    self.allPlannedCharacters = OldDataManager.shared.allPlannedCharacters
                    self.loading = false
                }
            }
        }
    }
    
    private func getCharacterChoices() -> [AlertButton] {
        var choices: [AlertButton] = []
        for char in self.allRegularCharacters {
            choices.append(AlertButton(title: char.fullName, onPress: {
                runOnMainThread {
                    self.createCharacter(char)
                }
            }))
        }
        for char in self.allPlannedCharacters {
            choices.append(AlertButton(title: char.fullName, onPress: {
                runOnMainThread {
                    self.createCharacter(char)
                }
            }))
        }
        return choices
    }
    
    private func createCharacter(_ existing: CharacterModel?) {
        self.newName = ""
        AlertManager.shared.showDynamicAlert(model: CustomAlertModel(
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
    
    private func addSkillsForExisting(newChar: CharacterModel, existingChar: CharacterModel) {
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
        self.loadingText = "Loading New Planned Character..."
        OldDataManager.shared.player = player
        OldDataManager.shared.load([.plannedCharacters], forceDownloadIfApplicable: true) {
            runOnMainThread {
                self.allPlannedCharacters = OldDataManager.shared.allPlannedCharacters
                self.loading = false
            }
        }
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return CharacterPlannerListView(_dm: dm, player: md.player())
}
