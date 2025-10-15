//
//  AddSkillView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import SwiftUI

struct AddSkillView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Binding var character: FullCharacterModel?
    @State var searchText: String = ""
    @State var filterType: SkillFilterType = .none
    @State var sortType: SkillSortType = .az

    @State var purchasingSkill = false
    @State var loadingText: String = ""

    var body: some View {
        VStack {
            if let character = character {
                let player = DM.getPlayerForCharacter(character)
                globalCreateTitleView("Add Skill", DM: DM)
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
                    ForEach(getSortedSkills(character.allPurchaseableSkills(searchText: searchText, filter: filterType))) { skill in
                        SkillCell.initForPurchase(skill: skill, player: player, character: character, loading: $purchasingSkill, loadingText: $loadingText) { skill in
                            self.purchasingSkill = true
                            self.loadingText = "Purchasing \(skill.name)..."
                            character.attemptToPurchaseSkill(skill: skill) { success in
                                runOnMainThread {
                                    if success {
                                        self.loadingText = "Reloading Character Data..."
                                        DM.load(finished:  {
                                            runOnMainThread {
                                                self.loadingText = ""
                                                self.purchasingSkill = false
                                                self.character = DM.getCharacter(character.id) ?? character
                                            }
                                        })
                                    } else {
                                        self.loadingText = ""
                                        self.purchasingSkill = false
                                    }
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.lightGray)
    }

    func getSortedSkills(_ skills: [FullCharacterModifiedSkillModel]) -> [FullCharacterModifiedSkillModel] {
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
                f.modXpCost() == s.modXpCost() ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.modXpCost() < s.modXpCost()
            }
        case .xpDesc:
            return skills.sorted { f, s in
                f.modXpCost() == s.modXpCost() ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.modXpCost() > s.modXpCost()
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

}
