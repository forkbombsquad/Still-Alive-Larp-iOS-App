//
//  SkillManagementView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import SwiftUI

struct SkillManagementView: View {
    @ObservedObject var _dm = DataManager.shared

    init(offline: Bool = false) {
        self.offline = offline
    }

    let offline: Bool

    @State var searchText: String = ""

    var body: some View {
        VStack {
            if let character = DataManager.shared.charForSelectedPlayer {
                Text("\(character.fullName)'s\nSkills\(offline ? " (Offline)" : "")")
                    .font(.system(size: 32, weight: .bold))
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)
                HStack {
                    TextField("Search", text: $searchText)
                        .padding([.leading, .trailing], 16)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                    if !offline {
                        Spacer()
                        if !DataManager.shared.loadingSkills {
                            if DataManager.shared.character?.id == DataManager.shared.charForSelectedPlayer?.id {
                                NavigationLink {
                                    AddSkillView()
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
                if DataManager.shared.loadingCharForSelectedPlayer || DataManager.shared.loadingSkills {

                    VStack {
                        ScrollView {
                            VStack {
                                ProgressView()
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.lightGray)

                } else {
                    List() {
                        ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(DataManager.shared.charForSelectedPlayer?.skills ?? [])) { skill in
                            SkillCellView(skill: skill)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .background(Color.lightGray)
        .onAppear {
            if !offline {
                DataManager.shared.load([.skills, .charForSelectedPlayer])
            }
        }
    }

    func shouldDoFiltering() -> Bool {
        return searchText.trimmed != ""
    }

    func getFilteredSkills() -> [FullSkillModel] {
        var filteredSkills = [FullSkillModel]()

        for skill in DataManager.shared.charForSelectedPlayer?.skills ?? [] {
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
