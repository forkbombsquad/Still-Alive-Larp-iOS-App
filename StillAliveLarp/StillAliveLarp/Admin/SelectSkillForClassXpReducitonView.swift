//
//  SelectSkillForClassXpReducitonView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import SwiftUI

struct SelectSkillForClassXpReducitonView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel
    @State var loading: Bool = true
    @State var loadingText: String = ""

    @State var searchText: String = ""

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            globalCreateTitleView("Select Skill For\nXP Reduction For\n\(character.fullName)", DM: DM)
            Text("Select Skill For\nXP Reduction For\n\(character.fullName)")
            TextField("Search", text: $searchText)
                .padding([.leading, .trailing], 16)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
            List() {
                ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(character.allNonPurchasedSkills())) { skill in
                    SkillCell.initForXpReduction(player: DM.getPlayerForCharacter(character), character: character, skill: skill, loading: $loading, loadingText: $loadingText) { skill in
                        runOnMainThread {
                            self.loading = true
                            self.loadingText = "Adding XP Reduction..."
                            AdminService.giveXpReduction(character.id, skillId: skill.id) { xpReduction in
                                runOnMainThread {
                                    DM.load()
                                    alertManager.showOkAlert("Successfully Added Skill Xp Reduction", message: "\(skill.name) now costs \(max(1, skill.modXpCost() - 1))xp for \(character.fullName)") {
                                        runOnMainThread {
                                            self.loading = false
                                            self.loadingText = ""
                                            self.mode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            } failureCase: { error in
                                runOnMainThread {
                                    self.loading = false
                                    self.loadingText = ""
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.lightGray)
    }

    func shouldDoFiltering() -> Bool {
        return searchText.trimmed != ""
    }

    func getFilteredSkills() -> [FullCharacterModifiedSkillModel] {
        return getSortedSkills(character.allNonPurchasedSkills().filter({ $0.includeInFilter(searchText: searchText, filterType: .none) }))
    }

    func getSortedSkills(_ skills: [FullCharacterModifiedSkillModel]) -> [FullCharacterModifiedSkillModel] {
        return skills.sorted { f, s in
            f.name.caseInsensitiveCompare(s.name) == .orderedAscending
        }
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return SelectSkillForClassXpReducitonView(character: md.character())
//}

