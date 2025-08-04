//
//  AddPlannedSkillView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/20/25.
//

import SwiftUI

struct AddPlannedSkillView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    typealias slk = SkillListView

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @State var character: OldFullCharacterModel
    @State var charSkills: [CharacterSkillModel] = []
    @State var skills: [CharacterModifiedSkillModel] = []
    @State var loading: Bool = false
    
    @State var searchText: String = ""
    @State var filterType: slk.FilterType = .none
    @State var sortType: slk.SortType = .az

    @State var purchasingSkill = false

    var body: some View {
        VStack {
            if !loading {
                Text("Plan Skill")
                    .font(.system(size: 32, weight: .bold))
                    .frame(alignment: .center)
                Text("*Only skills you qualify for are shown below")
                HStack {
                    Text("Spent Experience:\n\(getSpentXp())")
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                    Spacer()
                    Text("Spent Prestige:\n\(getSpendPP())")
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                    Spacer()
                    Text("Spent Free T1 Skils:\n\(getSpentFs())")
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    Menu("Sort\n(\(sortType.rawValue))") {
                        ForEach(slk.SortType.allCases, id: \.self) { sortType in
                            Button(sortType.rawValue) {
                                self.sortType = sortType
                            }
                        }
                    }.font(.system(size: 16, weight: .bold))
                    Spacer()
                    TextField("Search", text: $searchText)
                        .padding([.leading, .trailing], 16)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                    Spacer()
                    Menu("Filter\n(\(filterType.rawValue))") {
                        ForEach(slk.FilterType.allCases, id: \.self) { filterType in
                            Button(filterType.rawValue) {
                                self.filterType = filterType
                            }
                        }
                    }.font(.system(size: 16, weight: .bold))
                }.padding([.leading, .trailing, .top], 16)
                List() {
                    ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(skills)) { skill in
                        AddSkillCellView(skill: skill, purchasingSkill: $purchasingSkill, purchaseText: "Plan Skill") { skill in
                            // Purhase Skill
                            self.purchasingSkill = true
                            var xpSpent = skill.modXpCost.intValueDefaultZero
                            var fsSpent = 0
                            var messageString = "\(skill.name) planned using "

                            if skill.canUseFreeSkill {
                                AlertManager.shared.showAlert("Use Free Tier-1 Skill?", button1: Alert.Button.default(Text("Use xp"), action: {
                                    runOnMainThread {
                                        messageString += "\(xpSpent) xp"
                                        if skill.usesPrestige {
                                            messageString += " and \(skill.prestigeCost.intValueDefaultZero) pp"
                                        }
                                        let charSkill = CharacterSkillCreateModel(characterId: character.id, skillId: skill.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: skill.prestigeCost.intValueDefaultZero)
                                        CharacterSkillService.takePlannedCharacterSkill(charSkill) { _ in
                                            CharacterManager.shared.fetchFullCharacter(characterId: character.id) { char in
                                                runOnMainThread {
                                                    AlertManager.shared.showOkAlert("Skill Successfully Planned!", message: messageString, onOkAction: {
                                                    })
                                                    self.character = char!
                                                    CharacterSkillService.getAllSkillsForChar(self.character.id) { charSkills in
                                                        runOnMainThread {
                                                            self.charSkills = charSkills.charSkills
                                                            self.skills = getAvailableSkills(OldDM.skills ?? [])
                                                            self.loading = false
                                                            self.purchasingSkill = false
                                                        }
                                                    } failureCase: { error in
                                                        runOnMainThread {
                                                            self.skills = getAvailableSkills(OldDM.skills ?? [])
                                                            self.loading = false
                                                            self.purchasingSkill = false
                                                        }
                                                    }
                                                }
                                            }

                                        } failureCase: { error in
                                            runOnMainThread {
                                                self.purchasingSkill = false
                                            }
                                        }
                                    }
                                }), button2: Alert.Button.default(Text("Use FT1S"), action: {
                                    runOnMainThread {
                                        fsSpent = 1
                                        xpSpent = 0
                                        messageString += "1 Free Tier-1 Skill point"
                                        if skill.usesPrestige {
                                            messageString += " and \(skill.prestigeCost.intValueDefaultZero) pp"
                                        }
                                        let charSkill = CharacterSkillCreateModel(characterId: character.id, skillId: skill.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: skill.prestigeCost.intValueDefaultZero)
                                        CharacterSkillService.takePlannedCharacterSkill(charSkill) { _ in
                                            CharacterManager.shared.fetchFullCharacter(characterId: character.id) { char in
                                                runOnMainThread {
                                                    AlertManager.shared.showOkAlert("Skill Successfully Planned!", message: messageString, onOkAction: {
                                                    })
                                                    self.character = char!
                                                    CharacterSkillService.getAllSkillsForChar(self.character.id) { charSkills in
                                                        runOnMainThread {
                                                            self.charSkills = charSkills.charSkills
                                                            self.skills = getAvailableSkills(OldDM.skills ?? [])
                                                            self.loading = false
                                                            self.purchasingSkill = false
                                                        }
                                                    } failureCase: { error in
                                                        runOnMainThread {
                                                            self.skills = getAvailableSkills(OldDM.skills ?? [])
                                                            self.loading = false
                                                            self.purchasingSkill = false
                                                        }
                                                    }
                                                }
                                            }

                                        } failureCase: { error in
                                            runOnMainThread {
                                                self.purchasingSkill = false
                                            }
                                        }
                                    }
                                }))
                                
                            } else {
                                messageString += "\(xpSpent) xp"
                                if skill.usesPrestige {
                                    messageString += " and \(skill.prestigeCost.intValueDefaultZero) pp"
                                }
                                let charSkill = CharacterSkillCreateModel(characterId: character.id, skillId: skill.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: skill.prestigeCost.intValueDefaultZero)
                                CharacterSkillService.takePlannedCharacterSkill(charSkill) { _ in
                                    CharacterManager.shared.fetchFullCharacter(characterId: character.id) { char in
                                        runOnMainThread {
                                            AlertManager.shared.showOkAlert("Skill Successfully Planned!", message: messageString, onOkAction: {
                                            })
                                            self.character = char!
                                            CharacterSkillService.getAllSkillsForChar(self.character.id) { charSkills in
                                                runOnMainThread {
                                                    self.charSkills = charSkills.charSkills
                                                    self.skills = getAvailableSkills(OldDM.skills ?? [])
                                                    self.loading = false
                                                    self.purchasingSkill = false
                                                }
                                            } failureCase: { error in
                                                runOnMainThread {
                                                    self.skills = getAvailableSkills(OldDM.skills ?? [])
                                                    self.loading = false
                                                    self.purchasingSkill = false
                                                }
                                            }
                                        }
                                    }

                                } failureCase: { error in
                                    runOnMainThread {
                                        self.purchasingSkill = false
                                    }
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                LoadingBlock()
            }

        }
        .background(Color.lightGray)
        .onAppear() {
            self.loading = true
            OldDM.load([.skills]) {
                runOnMainThread {
                    CharacterSkillService.getAllSkillsForChar(self.character.id) { charSkills in
                        runOnMainThread {
                            self.charSkills = charSkills.charSkills
                            self.skills = getAvailableSkills(OldDM.skills ?? [])
                            self.loading = false
                        }
                    } failureCase: { error in
                        runOnMainThread {
                            self.skills = getAvailableSkills(OldDM.skills ?? [])
                            self.loading = false
                        }
                    }
                }
            }
        }
    }

    func shouldDoFiltering() -> Bool {
        return searchText.trimmed != "" || filterType != .none
    }

    func getFilteredSkills() -> [CharacterModifiedSkillModel] {
        var filteredSkills = [CharacterModifiedSkillModel]()

        for skill in skills {
            if skill.includeModInFilter(searchText: searchText, filterType: filterType) {
                filteredSkills.append(skill)
            }
        }
        return getSortedSkills(filteredSkills)
    }

    func getSortedSkills(_ skills: [CharacterModifiedSkillModel]) -> [CharacterModifiedSkillModel] {
        switch sortType {
        case .az:
            return skills.sorted { f, s in
                f.name.caseInsensitiveCompare(s.name) == .orderedAscending
            }
        case .za:
            return skills.sorted { f, s in
                f.name.caseInsensitiveCompare(s.name) == .orderedDescending
            }
        case .xpAsc:
            return skills.sorted { f, s in
                f.modXpCost.intValueDefaultZero == s.modXpCost.intValueDefaultZero ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.modXpCost.intValueDefaultZero < s.modXpCost.intValueDefaultZero
            }
        case .xpDesc:
            return skills.sorted { f, s in
                f.modXpCost.intValueDefaultZero == s.modXpCost.intValueDefaultZero ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.modXpCost.intValueDefaultZero > s.modXpCost.intValueDefaultZero
            }
        case .typeAsc:
            return skills.sorted { f, s in
                f.getTypeText() == s.getTypeText() ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.getTypeText().caseInsensitiveCompare(s.getTypeText()) == .orderedAscending
            }
        case .typeDesc:
            return skills.sorted { f, s in
                f.getTypeText() == s.getTypeText() ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.getTypeText().caseInsensitiveCompare(s.getTypeText()) == .orderedDescending
            }
        }
    }

    func getAvailableSkills(_ allSkills: [OldFullSkillModel]) -> [CharacterModifiedSkillModel] {
        let charSkills = character.skills
        // Remove all skills the character already has
        var newSkillList = allSkills.filter { skillToKeep in
            return !charSkills.contains(where: { charSkill in
                charSkill.id == skillToKeep.id
            })
        }

        // Remove all skills you don't have prereqs for
        newSkillList = newSkillList.filter { skillToKeep in
            if skillToKeep.prereqs.isEmpty {
                return true
            }
            for prereq in skillToKeep.prereqs {
                guard !charSkills.contains(where: { charSkill in
                    charSkill.id == prereq.id
                }) else { continue }
                return false
            }
            return true
        }

        // Remove Choose One skills that can't be chosen
        let cskills = character.getChooseOneSkills()
        if cskills.isEmpty {
            // Remove all level 2 cskills
            newSkillList = newSkillList.filter({ skillToKeep in
                return !skillToKeep.id.equalsAnyOf(Constants.SpecificSkillIds.allLevel2SpecialistSkills)
            })
        } else if cskills.count == 2 {
            // Remove all cskills
            newSkillList = newSkillList.filter({ skillToKeep in
                return !skillToKeep.id.equalsAnyOf(Constants.SpecificSkillIds.allSpecalistSkills)
            })
        } else if let cskill = cskills.first {
            var idsToRemove = [Int]()
            switch cskill.id {
                case Constants.SpecificSkillIds.expertCombat:
                    idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertCombat
                case Constants.SpecificSkillIds.expertProfession:
                    idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertProfession
                case Constants.SpecificSkillIds.expertTalent:
                    idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertTalent
                default:
                    break
            }
            // Remove all cskills not under your expert skill
            newSkillList = newSkillList.filter({ skillToKeep in
                return !skillToKeep.id.equalsAnyOf(idsToRemove)
            })
        }

        let combatXpMod = character.costOfCombatSkills()
        let professionXpMod = character.costOfProfessionSkills()
        let talentXpMod = character.costOfTalentSkills()
        let inf50Mod = character.costOf50InfectSkills()
        let inf75Mod = character.costOf75InfectSkills()

        // Convert to new model type
        var newCharModSkills = [CharacterModifiedSkillModel]()
        for skill in newSkillList {
            newCharModSkills.append(CharacterModifiedSkillModel(skill, modXpCost: skill.getModCost(combatMod: combatXpMod, professionMod: professionXpMod, talentMod: talentXpMod, xpReductions: []), modInfCost: skill.getInfModCost(inf50Mod: inf50Mod, inf75Mod: inf75Mod)))
        }

        return newCharModSkills

    }
    
    private func getSpentXp() -> Int {
        var total = 0
        for skl in self.charSkills {
            total += skl.xpSpent
        }
        return total
    }
    
    private func getSpentFs() -> Int {
        var total = 0
        for skl in self.charSkills {
            total += skl.fsSpent
        }
        return total
    }
    
    private func getSpendPP() -> Int {
        var total = 0
        for skl in self.charSkills {
            total += skl.ppSpent
        }
        return total
    }
}


#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return AddPlannedSkillView(_dm: dm, character: md.fullCharacters().first!)
}
