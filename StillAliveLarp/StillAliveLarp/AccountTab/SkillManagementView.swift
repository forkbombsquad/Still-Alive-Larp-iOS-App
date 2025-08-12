//
//  SkillManagementView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import SwiftUI

// TODO redo view

struct SkillManagementView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let offline: Bool
    let allowEdit: Bool
    @State var character: FullCharacterModel? = nil
    let skills: [FullCharacterModifiedSkillModel]
    @State var loadingSkills: Bool = false
    @State var searchText: String = ""

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
//                                    runOnMainThread {
//                                        self.loadingSkills = true
//                                        CharacterManager.shared.fetchFullCharacter(characterId: character.id) { fcm in
//                                            runOnMainThread {
//                                                if let fcm = fcm {
//                                                    self.character = fcm
//                                                    OldDM.character = fcm
//                                                }
//                                                self.loadingSkills = false
//                                            }
//                                        }
//                                        
//                                    }
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

    func getFilteredSkills() -> [FullCharacterModifiedSkillModel] {
        var filteredSkills = [FullCharacterModifiedSkillModel]()

        for skill in skills {
            if skill.includeInFilter(searchText: searchText, filterType: .none) {
                filteredSkills.append(skill)
            }
        }
        return getSortedSkills(filteredSkills)
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
//    return SkillManagementView(character: md.fullCharacters().first!, allowEdit: true)
//}
