//
//  SkillListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/11/23.
//

import SwiftUI

struct SkillListView: View {
    @ObservedObject var _dm = DataManager.shared

    enum FilterType: String, CaseIterable {
        case none = "No Filter"
        case combat = "Combat"
        case profession = "Profession"
        case talent = "Talent"
        case xp0 = "0xp"
        case xp1 = "1xp"
        case xp2 = "2xp"
        case xp3 = "3xp"
        case xp4 = "4xp"
        case pp = "Prestige Points"
        case inf = "Infection Threshold"
    }

    enum SortType: String, CaseIterable {
        case az = "A-Z"
        case za = "Z-A"
        case xpAsc = "XP Asc"
        case xpDesc = "XP Desc"
        case typeAsc = "Type Asc"
        case typeDesc = "Type Desc"
    }

    @State var skills: [FullSkillModel]
    @State var searchText: String = ""
    @State var filterType: FilterType = .none
    @State var sortType: SortType = .az

    var body: some View {
        VStack {
            Text("Skill List")
                .font(.system(size: 32, weight: .bold))
                .frame(alignment: .center)
            HStack {
                Menu("Sort\n(\(sortType.rawValue))") {
                    ForEach(SortType.allCases, id: \.self) { sortType in
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
                    ForEach(FilterType.allCases, id: \.self) { filterType in
                        Button(filterType.rawValue) {
                            self.filterType = filterType
                        }
                    }
                }.font(.system(size: 16, weight: .bold))
            }.padding([.leading, .trailing, .top], 16)
            List() {
                ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(skills)) { skill in
                    SkillCellView(skill: skill)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.lightGray)
    }

    func shouldDoFiltering() -> Bool {
        return searchText.trimmed != "" || filterType != .none
    }

    func getFilteredSkills() -> [FullSkillModel] {
        var filteredSkills = [FullSkillModel]()

        for skill in skills {
            if skill.includeInFilter(searchText: searchText, filterType: filterType) {
                filteredSkills.append(skill)
            }
        }
        return getSortedSkills(filteredSkills)
    }

    func getSortedSkills(_ skills: [FullSkillModel]) -> [FullSkillModel] {
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
                f.xpCost.intValueDefaultZero == s.xpCost.intValueDefaultZero ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.xpCost.intValueDefaultZero < s.xpCost.intValueDefaultZero
            }
        case .xpDesc:
            return skills.sorted { f, s in
                f.xpCost.intValueDefaultZero == s.xpCost.intValueDefaultZero ? f.name.caseInsensitiveCompare(s.name) == .orderedAscending : f.xpCost.intValueDefaultZero > s.xpCost.intValueDefaultZero
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

struct SkillCellView: View {
    @ObservedObject var _dm = DataManager.shared

    @State var skill: FullSkillModel

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
                    Text("\(skill.xpCost)xp").font(.system(size: 16))
                    Spacer()
                    if skill.prestigeCost.intValueDefaultZero > 0 {
                        Text("\(skill.prestigeCost)pp").font(.system(size: 16))
                    }
                    if skill.minInfection.intValueDefaultZero > 0  {
                        Spacer()
                        Text("\(skill.minInfection)% Inf Threshold").font(.system(size: 16))
                    }
                }
                if skill.prereqs.count > 0 {
                    Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                    Text("Prerequisites").font(.system(size: 14, weight: .bold))
                    Text(skill.getPrereqNames()).padding(.top, 8).multilineTextAlignment(.center)
                    Divider().background(Color.darkGray).padding([.leading, .trailing], 8)
                }
                Text(skill.description).padding(.top, 8)
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.lightGray)
    }

}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return SkillListView(_dm: dm, skills: md.fullSkills())
}
