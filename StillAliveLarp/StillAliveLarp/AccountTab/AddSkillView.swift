//
//  AddSkillView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import SwiftUI

// TODO redo view

struct AddSkillView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    typealias slk = SkillListView

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @State var skills: [FullCharacterModifiedSkillModel] = []
    @State var searchText: String = ""
    @State var filterType: slk.FilterType = .none
    @State var sortType: slk.SortType = .az

    @State var purchasingSkill = false

    var body: some View {
        VStack {
//            if let player = OldDM.player, let character = OldDM.character, let allSkills = OldDM.skills {
//                Text("Add Skill")
//                    .font(.system(size: 32, weight: .bold))
//                    .frame(alignment: .center)
//                Text("*Only skills you qualify for are shown below")
//                HStack {
//                    Text("xp: \(player.experience)")
//                    Spacer()
//                    Text("pp: \(player.prestigePoints)")
//                    Spacer()
//                    Text("freeT1: \(player.freeTier1Skills)")
//                    Spacer()
//                    Text("inf: \(character.infection)%")
//                }.padding(16)
//                HStack {
//                    Menu("Sort\n(\(sortType.rawValue))") {
//                        ForEach(slk.SortType.allCases, id: \.self) { sortType in
//                            Button(sortType.rawValue) {
//                                self.sortType = sortType
//                            }
//                        }
//                    }.font(.system(size: 16, weight: .bold))
//                    Spacer()
//                    TextField("Search", text: $searchText)
//                        .padding([.leading, .trailing], 16)
//                        .textFieldStyle(.roundedBorder)
//                        .textInputAutocapitalization(.never)
//                    Spacer()
//                    Menu("Filter\n(\(filterType.rawValue))") {
//                        ForEach(slk.FilterType.allCases, id: \.self) { filterType in
//                            Button(filterType.rawValue) {
//                                self.filterType = filterType
//                            }
//                        }
//                    }.font(.system(size: 16, weight: .bold))
//                }.padding([.leading, .trailing, .top], 16)
//                List() {
//                    ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(skills)) { skill in
//                        AddSkillCellView(skill: skill, purchasingSkill: $purchasingSkill) { skill in
//                            // Purhase Skill
//                            self.purchasingSkill = true
//                            var xpSpent = skill.modXpCost.intValueDefaultZero
//                            var fsSpent = 0
//                            var messageString = "\(skill.name) purchased using "
//                            if skill.canUseFreeSkill && player.freeTier1Skills.intValueDefaultZero > 0 {
//                                fsSpent = 1
//                                xpSpent = 0
//                                messageString += "1 Free Tier-1 Skill point"
//                            } else {
//                                messageString += "\(xpSpent) xp"
//                            }
//
//                            if skill.usesPrestige {
//                                messageString += " and \(skill.prestigeCost.intValueDefaultZero) pp"
//                            }
//
//                            let charSkill = CharacterSkillCreateModel(characterId: character.id, skillId: skill.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: skill.prestigeCost.intValueDefaultZero)
//                            CharacterSkillService.takeSkill(charSkill, playerId: player.id) { updatedPlayer in
//                                CharacterManager.shared.fetchActiveCharacter(overrideLocal: true) { character in
//                                    runOnMainThread {
//                                        AlertManager.shared.showOkAlert("Skill Purchased", message: messageString, onOkAction: {
//                                        })
//                                        PlayerManager.shared.updatePlayer(updatedPlayer)
//                                        OldDM.player = updatedPlayer
//                                        OldDM.character = character
//                                        self.skills = self.getAvailableSkills(allSkills)
//                                        self.purchasingSkill = false
//                                    }
//                                }
//
//                            } failureCase: { error in
//                                runOnMainThread {
//                                    self.purchasingSkill = false
//                                }
//                            }
//                        }
//                    }
//                }
//                .scrollContentBackground(.hidden)
//            } else {
                LoadingBlock()
//            }

        }
        .background(Color.lightGray)
        .onAppear() {
//            self.skills = getAvailableSkills(OldDM.skills ?? [])
//            OldDM.load([.skills, .player, .character, .xpReductions]) {
//                self.skills = getAvailableSkills(OldDM.skills ?? [])
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

}

struct AddSkillCellView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let skill: FullCharacterModifiedSkillModel
    @Binding var purchasingSkill: Bool

    let onTap: (_ skill: FullCharacterModifiedSkillModel) -> Void
    
    let purchaseText: String
    
    // TODO redo view

    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text(skill.name)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text(skill.getTypeText())
                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(skill.getTypeColor())
                }
//                HStack {
//                    Spacer()
//                    Text("Cost: ").font(.system(size: 16)).multilineTextAlignment(.trailing)
//                    if skill.canUseFreeSkill() && (OldDM.player?.freeTier1Skills ?? "").intValueDefaultZero > 0 {
//                        Text("1 Free Tier-1 Skill")
//                            .foregroundColor(Color.darkGreen)
//                            .multilineTextAlignment(.leading)
//                    } else if skill.hasModCost {
//                        Text("\(skill.modXpCost)xp (changed from \(skill.xpCost)xp)")
//                            .foregroundColor(skill.colorForCost())
//                            .multilineTextAlignment(.leading)
//                    } else {
//                        Text("\(skill.modXpCost)xp")
//                            .foregroundColor(skill.colorForCost())
//                            .multilineTextAlignment(.leading)
//                    }
//                    if skill.usesPrestige {
//                        Text(" and \(skill.prestigeCost)pp")
//                            .foregroundColor(Color.blue)
//                            .multilineTextAlignment(.leading)
//                    }
//                    Spacer()
//                }
                if skill.usesInfection() {
                    HStack {
                        Spacer()
                        if skill.hasModInfCost() {
                            Text("Your Infection Rating meets the required \(skill.modInfectionCost())% (changed from \(skill.baseInfectionCost())%)")
//                                .foregroundColor(skill.colorForInf())
                                .multilineTextAlignment(.leading)
                            Spacer()
                        } else {
                            Text("Your Infection Rating meets the required \(skill.modInfectionCost())%")
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                }

                if skill.prereqs().count > 0 {
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
    DataManager.shared.setDebugMode(true)
    return AddSkillView()
}
