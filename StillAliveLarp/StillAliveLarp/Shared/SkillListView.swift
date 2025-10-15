//
//  SkillsListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import SwiftUI

struct SkillsListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Binding var character: FullCharacterModel?
    let allowDelete: Bool
    let title: String
    
    let passedSkills: [FullCharacterModifiedSkillModel]?
    
    @State var searchText: String = ""
    
    init(character: Binding<FullCharacterModel?>, allowDelete: Bool) {
        self._character = character
        self.allowDelete = allowDelete
        self.title = "\(character.wrappedValue?.fullName ?? "")'s\(character.wrappedValue?.characterType() == .planner ? " Planned" : "") Skills"
        self.passedSkills = nil
    }
    
    init(skills: [FullCharacterModifiedSkillModel], allowDelete: Bool, title: String) {
        self._character = .constant(nil)
        self.allowDelete = allowDelete
        self.title = title
        self.passedSkills = skills
    }

    var body: some View {
        VStack {
            GeometryReader { gr in
                VStack {
                    globalCreateTitleView(title, DM: DM)
                    HStack {
                        TextField("Search", text: $searchText)
                            .padding([.leading, .trailing], 16)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                        if let character = character, character.isAlive && DM.playerIsCurrentPlayer(character.playerId) && !DM.offlineMode {
                            Spacer()
                            NavigationLink {
                                AddSkillView(character: _character)
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
                        Spacer()
                    }.padding([.leading, .trailing, .top], 16)
                    LoadingLayoutView {
                        VStack {
                            if let character = character, allowDelete && character.isAlive && DM.playerIsCurrentPlayer(character.playerId) && !DM.offlineMode && character.characterType() == .planner {
                                NavigationLink(destination: DeleteSkillsView(character: $character, mode: .justDelete)) {
                                    Text("Remove Skills")
                                        .font(.system(size: 20, weight: .bold))
                                        .frame(width: gr.size.width - 8, height: 90)
                                        .background(Color.midRed)
                                        .cornerRadius(15)
                                        .foregroundColor(.white)
                                        .tint(.midRed)
                                        .controlSize(.large)
                                }
                            }
                            List() {
                                ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(getSkills())) { skill in
                                    SkillCell.initAsBase(skill: skill)
                                }
                            }
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
            }
        }
        .background(Color.lightGray)
    }

    func shouldDoFiltering() -> Bool {
        return searchText.trimmed != ""
    }

    func getFilteredSkills() -> [FullCharacterModifiedSkillModel] {
        return getSortedSkills(getSkills().filter({ $0.includeInFilter(searchText: searchText, filterType: .none) }))
    }

    func getSortedSkills(_ skills: [FullCharacterModifiedSkillModel]) -> [FullCharacterModifiedSkillModel] {
        return skills.sorted { f, s in
            f.name.caseInsensitiveCompare(s.name) == .orderedAscending
        }
    }
    
    func getSkills() -> [FullCharacterModifiedSkillModel] {
        if let character = character {
            return character.allPurchasedSkills()
        } else {
            return passedSkills ?? []
        }
    }

}

