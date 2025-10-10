//
//  AddPlannedSkillView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/20/25.
//

import SwiftUI

// TODO get rid of view

struct AddPlannedSkillView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @State var character: FullCharacterModel
    @State var charSkills: [CharacterSkillModel] = []
    @State var skills: [FullCharacterModifiedSkillModel] = []
    @State var loading: Bool = false
    
    @State var searchText: String = ""
    @State var filterType: SkillFilterType = .none
    @State var sortType: SkillSortType = .az

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
                        ForEach(SkillSortType.allCases, id: \.self) { sortType in
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
                        ForEach(SkillFilterType.allCases, id: \.self) { filterType in
                            Button(filterType.rawValue) {
                                self.filterType = filterType
                            }
                        }
                    }.font(.system(size: 16, weight: .bold))
                }.padding([.leading, .trailing, .top], 16)
                List() {
//                    ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(skills)) { skill in
//                        // TODO
////                        AddSkillCellView(skill: skill, purchasingSkill: $purchasingSkill, purchaseText: "") { skill in
//////                            // Purhase Skill
//////                            self.purchasingSkill = true
//////                            var xpSpent = skill.modXpCost()
//////                            var fsSpent = 0
//////                            var messageString = "\(skill.name) planned using "
//////
//////                            if skill.canUseFreeSkill {
//////                                alertManager.showAlert("Use Free Tier-1 Skill?", button1: Alert.Button.default(Text("Use xp"), action: {
//////                                    runOnMainThread {
//////                                        messageString += "\(xpSpent) xp"
//////                                        if skill.usesPrestige {
//////                                            messageString += " and \(skill.prestigeCost.intValueDefaultZero) pp"
//////                                        }
//////                                        let charSkill = CharacterSkillCreateModel(characterId: character.id, skillId: skill.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: skill.prestigeCost.intValueDefaultZero)
//////                                        CharacterSkillService.takePlannedCharacterSkill(charSkill) { _ in
//////                                            CharacterManager.shared.fetchFullCharacter(characterId: character.id) { char in
//////                                                runOnMainThread {
//////                                                    alertManager.showOkAlert("Skill Successfully Planned!", message: messageString, onOkAction: {
//////                                                    })
//////                                                    self.character = char!
//////                                                    CharacterSkillService.getAllSkillsForChar(self.character.id) { charSkills in
//////                                                        runOnMainThread {
//////                                                            self.charSkills = charSkills.charSkills
//////                                                            self.skills = getAvailableSkills(OldDM.skills ?? [])
//////                                                            self.loading = false
//////                                                            self.purchasingSkill = false
//////                                                        }
//////                                                    } failureCase: { error in
//////                                                        runOnMainThread {
//////                                                            self.skills = getAvailableSkills(OldDM.skills ?? [])
//////                                                            self.loading = false
//////                                                            self.purchasingSkill = false
//////                                                        }
//////                                                    }
//////                                                }
//////                                            }
//////
//////                                        } failureCase: { error in
//////                                            runOnMainThread {
//////                                                self.purchasingSkill = false
//////                                            }
//////                                        }
//////                                    }
//////                                }), button2: Alert.Button.default(Text("Use FT1S"), action: {
//////                                    runOnMainThread {
//////                                        fsSpent = 1
//////                                        xpSpent = 0
//////                                        messageString += "1 Free Tier-1 Skill point"
//////                                        if skill.usesPrestige {
//////                                            messageString += " and \(skill.prestigeCost.intValueDefaultZero) pp"
//////                                        }
//////                                        let charSkill = CharacterSkillCreateModel(characterId: character.id, skillId: skill.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: skill.prestigeCost.intValueDefaultZero)
//////                                        CharacterSkillService.takePlannedCharacterSkill(charSkill) { _ in
//////                                            CharacterManager.shared.fetchFullCharacter(characterId: character.id) { char in
//////                                                runOnMainThread {
//////                                                    alertManager.showOkAlert("Skill Successfully Planned!", message: messageString, onOkAction: {
//////                                                    })
//////                                                    self.character = char!
//////                                                    CharacterSkillService.getAllSkillsForChar(self.character.id) { charSkills in
//////                                                        runOnMainThread {
//////                                                            self.charSkills = charSkills.charSkills
//////                                                            self.skills = getAvailableSkills(OldDM.skills ?? [])
//////                                                            self.loading = false
//////                                                            self.purchasingSkill = false
//////                                                        }
//////                                                    } failureCase: { error in
//////                                                        runOnMainThread {
//////                                                            self.skills = getAvailableSkills(OldDM.skills ?? [])
//////                                                            self.loading = false
//////                                                            self.purchasingSkill = false
//////                                                        }
//////                                                    }
//////                                                }
//////                                            }
//////
//////                                        } failureCase: { error in
//////                                            runOnMainThread {
//////                                                self.purchasingSkill = false
//////                                            }
//////                                        }
//////                                    }
//////                                }))
//////                                
//////                            } else {
//////                                messageString += "\(xpSpent) xp"
//////                                if skill.usesPrestige {
//////                                    messageString += " and \(skill.prestigeCost.intValueDefaultZero) pp"
//////                                }
//////                                let charSkill = CharacterSkillCreateModel(characterId: character.id, skillId: skill.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: skill.prestigeCost.intValueDefaultZero)
//////                                CharacterSkillService.takePlannedCharacterSkill(charSkill) { _ in
//////                                    CharacterManager.shared.fetchFullCharacter(characterId: character.id) { char in
//////                                        runOnMainThread {
//////                                            alertManager.showOkAlert("Skill Successfully Planned!", message: messageString, onOkAction: {
//////                                            })
//////                                            self.character = char!
//////                                            CharacterSkillService.getAllSkillsForChar(self.character.id) { charSkills in
//////                                                runOnMainThread {
//////                                                    self.charSkills = charSkills.charSkills
//////                                                    self.skills = getAvailableSkills(OldDM.skills ?? [])
//////                                                    self.loading = false
//////                                                    self.purchasingSkill = false
//////                                                }
//////                                            } failureCase: { error in
//////                                                runOnMainThread {
//////                                                    self.skills = getAvailableSkills(OldDM.skills ?? [])
//////                                                    self.loading = false
//////                                                    self.purchasingSkill = false
//////                                                }
//////                                            }
//////                                        }
//////                                    }
//////
//////                                } failureCase: { error in
//////                                    runOnMainThread {
//////                                        self.purchasingSkill = false
//////                                    }
//////                                }
//////                            }
////                        }
//                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                LoadingBlock()
            }

        }
        .background(Color.lightGray)
        .onAppear() {
//            self.loading = true
//            OldDM.load([.skills]) {
//                runOnMainThread {
//                    CharacterSkillService.getAllSkillsForChar(self.character.id) { charSkills in
//                        runOnMainThread {
//                            self.charSkills = charSkills.charSkills
//                            self.skills = getAvailableSkills(OldDM.skills ?? [])
//                            self.loading = false
//                        }
//                    } failureCase: { error in
//                        runOnMainThread {
//                            self.skills = getAvailableSkills(OldDM.skills ?? [])
//                            self.loading = false
//                        }
//                    }
//                }
//            }
        }
    }

    func shouldDoFiltering() -> Bool {
        return searchText.trimmed != "" || filterType != .none
    }

    func getFilteredSkills() -> [FullCharacterModifiedSkillModel] {
        var filteredSkills = [FullCharacterModifiedSkillModel]()

        for skill in skills {
            if skill.includeInFilter(searchText: searchText, filterType: filterType) {
                filteredSkills.append(skill)
            }
        }
        return getSortedSkills(filteredSkills)
    }

    func getSortedSkills(_ skills: [FullCharacterModifiedSkillModel]) -> [FullCharacterModifiedSkillModel] {
//        switch sortType {
//        case .az:
//            return skills.sorted { f, s in
//                f.name.caseInsensitiveCompare(s.name) == .orderedAscending
//            }
//        case .za:
//            return skills.sorted { f, s in
//                f.name.caseInsensitiveCompare(s.name) == .orderedDescending
//            }
//        case .xpAsc:
//            return skills.sorted { f, s in
//                f.modXpCost.intValueDefaultZero == s.modXpCost.intValueDefaultZero ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.modXpCost.intValueDefaultZero < s.modXpCost.intValueDefaultZero
//            }
//        case .xpDesc:
//            return skills.sorted { f, s in
//                f.modXpCost.intValueDefaultZero == s.modXpCost.intValueDefaultZero ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.modXpCost.intValueDefaultZero > s.modXpCost.intValueDefaultZero
//            }
//        case .typeAsc:
//            return skills.sorted { f, s in
//                f.getTypeText() == s.getTypeText() ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.getTypeText().caseInsensitiveCompare(s.getTypeText()) == .orderedAscending
//            }
//        case .typeDesc:
//            return skills.sorted { f, s in
//                f.getTypeText() == s.getTypeText() ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.getTypeText().caseInsensitiveCompare(s.getTypeText()) == .orderedDescending
//            }
//        }
        return []
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


//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return AddPlannedSkillView(character: md.fullCharacters().first!)
//}
