//
//  AddSkillView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import SwiftUI

struct AddSkillView: View {
    @ObservedObject var _dm = DataManager.shared

    typealias slk = SkillListView

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @State var skills: [CharacterModifiedSkillModel] = []
    @State var searchText: String = ""
    @State var filterType: slk.FilterType = .none
    @State var sortType: slk.SortType = .az

    @State var purchasingSkill = false

    var body: some View {
        VStack {
            if let player = OldDataManager.shared.player, let character = OldDataManager.shared.character, let allSkills = OldDataManager.shared.skills {
                Text("Add Skill")
                    .font(.system(size: 32, weight: .bold))
                    .frame(alignment: .center)
                Text("*Only skills you qualify for are shown below")
                HStack {
                    Text("xp: \(player.experience)")
                    Spacer()
                    Text("pp: \(player.prestigePoints)")
                    Spacer()
                    Text("freeT1: \(player.freeTier1Skills)")
                    Spacer()
                    Text("inf: \(character.infection)%")
                }.padding(16)
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
                        AddSkillCellView(skill: skill, purchasingSkill: $purchasingSkill) { skill in
                            // Purhase Skill
                            self.purchasingSkill = true
                            var xpSpent = skill.modXpCost.intValueDefaultZero
                            var fsSpent = 0
                            var messageString = "\(skill.name) purchased using "
                            if skill.canUseFreeSkill && player.freeTier1Skills.intValueDefaultZero > 0 {
                                fsSpent = 1
                                xpSpent = 0
                                messageString += "1 Free Tier-1 Skill point"
                            } else {
                                messageString += "\(xpSpent) xp"
                            }

                            if skill.usesPrestige {
                                messageString += " and \(skill.prestigeCost.intValueDefaultZero) pp"
                            }

                            let charSkill = CharacterSkillCreateModel(characterId: character.id, skillId: skill.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: skill.prestigeCost.intValueDefaultZero)
                            CharacterSkillService.takeSkill(charSkill, playerId: player.id) { updatedPlayer in
                                CharacterManager.shared.fetchActiveCharacter(overrideLocal: true) { character in
                                    runOnMainThread {
                                        AlertManager.shared.showOkAlert("Skill Purchased", message: messageString, onOkAction: {
                                        })
                                        PlayerManager.shared.updatePlayer(updatedPlayer)
                                        OldDataManager.shared.player = updatedPlayer
                                        OldDataManager.shared.character = character
                                        self.skills = self.getAvailableSkills(allSkills)
                                        self.purchasingSkill = false
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
                .scrollContentBackground(.hidden)
            } else {
                LoadingBlock()
            }

        }
        .background(Color.lightGray)
        .onAppear() {
            self.skills = getAvailableSkills(OldDataManager.shared.skills ?? [])
            OldDataManager.shared.load([.skills, .player, .character, .xpReductions]) {
                self.skills = getAvailableSkills(OldDataManager.shared.skills ?? [])
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
        let charSkills = OldDataManager.shared.character?.skills ?? []
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

        // Filter out pp skills you don't qualify for
        newSkillList = newSkillList.filter({ skillToKeep in
            if skillToKeep.prestigeCost.intValueDefaultZero > (OldDataManager.shared.player?.prestigePoints ?? "").intValueDefaultZero {
                return false
            }
            return true
        })

        // Remove Choose One skills that can't be chosen
        let cskills = OldDataManager.shared.character?.getChooseOneSkills() ?? []
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

        let combatXpMod = OldDataManager.shared.character?.costOfCombatSkills() ?? 0
        let professionXpMod = OldDataManager.shared.character?.costOfProfessionSkills() ?? 0
        let talentXpMod = OldDataManager.shared.character?.costOfTalentSkills() ?? 0
        let inf50Mod = OldDataManager.shared.character?.costOf50InfectSkills() ?? 0
        let inf75Mod = OldDataManager.shared.character?.costOf75InfectSkills() ?? 0

        // Convert to new model type
        var newCharModSkills = [CharacterModifiedSkillModel]()
        for skill in newSkillList {
            newCharModSkills.append(CharacterModifiedSkillModel(skill, modXpCost: skill.getModCost(combatMod: combatXpMod, professionMod: professionXpMod, talentMod: talentXpMod, xpReductions: OldDataManager.shared.xpReductions ?? []), modInfCost: skill.getInfModCost(inf50Mod: inf50Mod, inf75Mod: inf75Mod)))
        }

        // Filter out skills that you don't have enough xp, fs, or inf for
        newCharModSkills = newCharModSkills.filter({ skillToKeep in
            if skillToKeep.modInfCost.intValueDefaultZero > (OldDataManager.shared.character?.infection ?? "").intValueDefaultZero {
                return false
            }
            if skillToKeep.modXpCost.intValueDefaultZero > (OldDataManager.shared.player?.experience ?? "").intValueDefaultZero {
                if skillToKeep.canUseFreeSkill && (OldDataManager.shared.player?.freeTier1Skills ?? "").intValueDefaultZero > 0 {
                    return true
                }
                return false
            }
            return true
        })
        return newCharModSkills

    }
}

struct AddSkillCellView: View {
    @ObservedObject var _dm = DataManager.shared

    let skill: CharacterModifiedSkillModel
    @Binding var purchasingSkill: Bool

    let onTap: (_ skill: CharacterModifiedSkillModel) -> Void
    
    let purchaseText: String
    
    init(_dm: OldDataManager = OldDataManager.shared, skill: CharacterModifiedSkillModel, purchasingSkill: Binding<Bool>, purchaseText: String = "Purchase Skill", onTap: @escaping (_: CharacterModifiedSkillModel) -> Void) {
        self._dm = _dm
        self.skill = skill
        self._purchasingSkill = purchasingSkill
        self.purchaseText = purchaseText
        self.onTap = onTap
    }

    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text(skill.name)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text(skill.getTypeText())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(skill.getTypeColor())
                }
                HStack {
                    Spacer()
                    Text("Cost: ").font(.system(size: 16)).multilineTextAlignment(.trailing)
                    if skill.canUseFreeSkill && (OldDataManager.shared.player?.freeTier1Skills ?? "").intValueDefaultZero > 0 {
                        Text("1 Free Tier-1 Skill")
                            .foregroundColor(Color.darkGreen)
                            .multilineTextAlignment(.leading)
                    } else if skill.hasModCost {
                        Text("\(skill.modXpCost)xp (changed from \(skill.xpCost)xp)")
                            .foregroundColor(skill.colorForCost())
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("\(skill.modXpCost)xp")
                            .foregroundColor(skill.colorForCost())
                            .multilineTextAlignment(.leading)
                    }
                    if skill.usesPrestige {
                        Text(" and \(skill.prestigeCost)pp")
                            .foregroundColor(Color.blue)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                if skill.usesInfection {
                    HStack {
                        Spacer()
                        if skill.hasModInfCost {
                            Text("Your Infection Rating meets the required \(skill.modInfCost)% (changed from \(skill.minInfection)%)")
                                .foregroundColor(skill.colorForInf())
                                .multilineTextAlignment(.leading)
                            Spacer()
                        } else {
                            Text("Your Infection Rating meets the required \(skill.minInfection)%")
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                }

                if skill.prereqs.count > 0 {
                    Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                    Text("Prerequisites").font(.system(size: 14, weight: .bold))
                    Text(skill.getPrereqNames()).padding(.top, 8).multilineTextAlignment(.center)
                    Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                }
                Text(skill.description).padding(.top, 8)
                LoadingButtonView($purchasingSkill, width: 180, height: 44, buttonText: purchaseText) {
                    onTap(skill)
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.lightGray)
    }

}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    var asv = AddSkillView(_dm: dm)
    asv._dm = dm
    return asv
}
