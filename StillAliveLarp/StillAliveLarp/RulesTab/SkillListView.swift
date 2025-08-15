//
//  SkillListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import SwiftUI

// TODO redo view
// TODo rename to SkillsListView

struct SkillListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let character: FullCharacterModel?
    let allowDelete: Bool
    let title: String
    
    let skills: [FullCharacterModifiedSkillModel]
    
    @State var searchText: String = ""
    
    init(character: FullCharacterModel, allowDelete: Bool) {
        self.character = character
        self.allowDelete = allowDelete
        self.title = "\(character.fullName)'s\(character.characterType() == .planner ? " Planned" : "") Skills"
        self.skills = character.allPurchasedSkills()
    }
    
    init(skills: [FullCharacterModifiedSkillModel], allowDelete: Bool, title: String) {
        self.character = nil
        self.allowDelete = allowDelete
        self.title = title
        self.skills = skills
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
                                // TODO add skills
        //                        AddSkillView().onDisappear {
        ////                                    runOnMainThread {
        ////                                        self.loadingSkills = true
        ////                                        CharacterManager.shared.fetchFullCharacter(characterId: character.id) { fcm in
        ////                                            runOnMainThread {
        ////                                                if let fcm = fcm {
        ////                                                    self.character = fcm
        ////                                                    OldDM.character = fcm
        ////                                                }
        ////                                                self.loadingSkills = false
        ////                                            }
        ////                                        }
        ////
        ////                                    }
        //                        }
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
                            if let character = character, allowDelete && character.isAlive && DM.playerIsCurrentPlayer(character.playerId) && !DM.offlineMode {
                                NavigationLink(destination: ContactView()) {
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
                                ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(skills)) { skill in
                                    SkillCellView(skill: skill)
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
        var filteredSkills = [FullCharacterModifiedSkillModel]()

        for skill in skills {
            if skill.includeInFilter(searchText: searchText, filterType: .none) {
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
//                f.xpCost.intValueDefaultZero == s.xpCost.intValueDefaultZero ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.xpCost.intValueDefaultZero < s.xpCost.intValueDefaultZero
//            }
//        case .xpDesc:
//            return skills.sorted { f, s in
//                f.xpCost.intValueDefaultZero == s.xpCost.intValueDefaultZero ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.xpCost.intValueDefaultZero > s.xpCost.intValueDefaultZero
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

struct SkillCellView: View {
    
    enum SetupType {
        case normal, xpReduction, purchase
    }
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State var skill: FullCharacterModifiedSkillModel
    let setupType: SetupType
    let player: FullPlayerModel
    let forPlannedCharacterOrNpc: Bool

    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text(skill.name)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Text(skill.getTypeText())
                        .font(.system(size: 18, weight: .bold))
                    // TODO
//                        .foregroundColor(skill.getTypeColor())
                }
                if setupType == .normal || setupType == .xpReduction {
                    HStack {
                        Text("\(skill.getXpCostText())").font(.system(size: 16))
                        Spacer()
                        if skill.usesPrestige() {
                            Text("and \(skill.getPrestigeCostText())").font(.system(size: 16))
                        }
                        if skill.usesInfection()  {
                            Spacer()
                            Text("\(skill.getInfCostText())").font(.system(size: 16))
                        }
                    }
                } else if setupType == .purchase {
                    HStack {
                        let xpText = skill.getXpCostText(allowFreeSkillUse: player.freeTier1Skills > 0 && !forPlannedCharacterOrNpc)
                        Text(xpText).font(.system(size: 16))
                        // TODO
//                            .foregroundColor(xpText.lowercased().contains("free") ? GREEN : (skill.hasModCost() ? colorForSkill() : BLACK))
                        Spacer()
                        if skill.usesPrestige() {
                            Text("and \(skill.getPrestigeCostText())").font(.system(size: 16))
                        }
                        // TODO
//                        if skill.usesInfection()  {
//                            Spacer()
//                            Text("\(skill.getInfCostText())").font(.system(size: 16))
//                        }
                    }
                }
                // TODO
//                if skill.prereqs().count > 0 {
//                    Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
//                    Text("Prerequisites").font(.system(size: 14, weight: .bold))
//                    Text(skill.getPrereqNames()).padding(.top, 8).multilineTextAlignment(.center)
//                    Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
//                }
//                Text(skill.description).padding(.top, 8)
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.lightGray)
    }

}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return SkillListView(skills: md.fullSkills())
//}
