//
//  SkillManagementPlannerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/20/25.
//

import SwiftUI

struct SkillManagementPlannerView: View {
    @ObservedObject var _dm = OldDataManager.shared

    let character: CharacterModel
    @State var fullCharacterModel: FullCharacterModel? = nil
    @State var loading: Bool = false
    @State var searchText: String = ""
    
    @State var firstLoad = true
    
    // Online
    init(_dm: OldDataManager = OldDataManager.shared, character: CharacterModel) {
        self._dm = _dm
        self.character = character
    }

    var body: some View {
        VStack {
            if loading {
                LoadingBlock()
            } else if let character = self.fullCharacterModel {
                Text("\(character.fullName)'s\nPlanned Skills")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                HStack {
                    TextField("Search", text: $searchText)
                        .padding([.leading, .trailing], 16)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                    Spacer()
                    NavigationLink {
                        AddPlannedSkillView(character: character).onDisappear {
                            runOnMainThread {
                                self.loading = true
                                CharacterManager.shared.fetchFullCharacter(characterId: character.id) { fcm in
                                    runOnMainThread {
                                        self.fullCharacterModel = fcm
                                        self.loading = false
                                    }
                                }
                            }
                        }
                    } label: {
                        VStack {
                            Image(systemName: "plus.app.fill").resizable().frame(width: 22, height: 22)
                            Text("Add New").font(.system(size: 16, weight: .bold))
                        }
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20).strokeBorder(Color.brightRed, lineWidth: 2)
                        )
                    }
                }.padding([.leading, .trailing, .top], 16)
                List() {
                    ForEach(shouldDoFiltering() ? getFilteredSkills(character.skills) : getSortedSkills(character.skills)) { skill in
                        SkillCellView(skill: skill)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.lightGray)
        .onAppear {
            if firstLoad {
                self.firstLoad = false
                self.loading = true
                CharacterManager.shared.fetchFullCharacter(characterId: character.id) { fcm in
                    runOnMainThread {
                        self.fullCharacterModel = fcm
                        self.loading = false
                    }
                }
            }
        }
    }

    func shouldDoFiltering() -> Bool {
        return searchText.trimmed != ""
    }

    func getFilteredSkills(_ skills: [FullSkillModel]) -> [FullSkillModel] {
        var filteredSkills = [FullSkillModel]()

        for skill in skills {
            if skill.includeInFilter(searchText: searchText, filterType: .none) {
                filteredSkills.append(skill)
            }
        }
        return getSortedSkills(filteredSkills)
    }

    func getSortedSkills(_ skills: [FullSkillModel]) -> [FullSkillModel] {
        return skills.sorted { f, s in
            f.name.caseInsensitiveCompare(s.name) == .orderedAscending
        }
    }

}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return SkillManagementView(_dm: dm, character: md.fullCharacters().first!, allowEdit: true)
}
