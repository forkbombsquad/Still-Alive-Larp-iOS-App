//
//  SkillManagementView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import SwiftUI

struct SkillManagementView: View {
    @ObservedObject var _dm = DataManager.shared
    
    static func Offline(character: FullCharacterModel) -> SkillManagementView {
        return SkillManagementView(offline: true, allowEdit: false, character: character)
    }

    let offline: Bool
    let allowEdit: Bool
    @State var character: FullCharacterModel? = nil
    let skills: [FullSkillModel]
    @State var loadingSkills: Bool = false
    @State var searchText: String = ""
    
    // Online
    init(_dm: DataManager = DataManager.shared, character: FullCharacterModel, allowEdit: Bool) {
        self._dm = _dm
        self.offline = false
        self.allowEdit = allowEdit
        self._character = globalState(character)
        self.skills = character.skills
    }
    
    private init (offline: Bool, allowEdit: Bool, character: FullCharacterModel) {
        self.offline = offline
        self.allowEdit = allowEdit
        self._character = globalState(character)
        self.skills = character.skills
        
    }

    var body: some View {
        VStack {
            if let character = character {
                Text("\(character.fullName)'s\nSkills\(offline ? " (Offline)" : "")")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                HStack {
                    TextField("Search", text: $searchText)
                        .padding([.leading, .trailing], 16)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                    if allowEdit {
                        Spacer()
                        if !loadingSkills {
                            NavigationLink {
                                AddSkillView().onDisappear {
                                    runOnMainThread {
                                        self.loadingSkills = true
                                        CharacterManager.shared.fetchFullCharacter(characterId: character.id) { fcm in
                                            runOnMainThread {
                                                if let fcm = fcm {
                                                    self.character = fcm
                                                    DataManager.shared.character = fcm
                                                }
                                                self.loadingSkills = false
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
                        } else {
                            ProgressView()
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20).strokeBorder(Color.brightRed, lineWidth: 2)
                                )
                        }
                    }
                }.padding([.leading, .trailing, .top], 16)
                if loadingSkills {
                    VStack {
                        ScrollView {
                            VStack {
                                LoadingBlock()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.lightGray)
                } else {
                    List() {
                        ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(skills)) { skill in
                            SkillCellView(skill: skill)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .background(Color.lightGray)
    }

    func shouldDoFiltering() -> Bool {
        return searchText.trimmed != ""
    }

    func getFilteredSkills() -> [FullSkillModel] {
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
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return SkillManagementView(_dm: dm, character: md.fullCharacters().first!, allowEdit: true)
}
