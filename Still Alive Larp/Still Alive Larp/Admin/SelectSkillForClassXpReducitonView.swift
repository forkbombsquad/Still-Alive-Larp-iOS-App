//
//  SelectSkillForClassXpReducitonView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import SwiftUI

struct SelectSkillForClassXpReducitonView: View {
    @ObservedObject var _dm = DataManager.shared

    let character: CharacterModel
    @State var loadingSkills: Bool = true
    @State var skills: [FullSkillModel] = []
    @State var loadingXpReduction: Bool = false

    @State var searchText: String = ""

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            Text("Select Skill For\nXP Reduction For\n\(character.fullName)")
                .font(.system(size: 32, weight: .bold))
                .frame(alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.leading, 16)

            if !loadingSkills {
                TextField("Search", text: $searchText)
                    .padding([.leading, .trailing], 16)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                List() {
                    ForEach(shouldDoFiltering() ? getFilteredSkills() : getSortedSkills(skills)) { skill in
                        XpReductionSkillCellView(skill: skill, loadingXpReduction: $loadingXpReduction) { skill in
                            self.loadingXpReduction = true
                            AdminService.giveXpReduction(character.id, skillId: skill.id) { xpReduction in
                                runOnMainThread {
                                    AlertManager.shared.showOkAlert("Successfully Added Skill Xp Reduction", message: "\(skill.name) now costs \(max(1, (skill.xpCost.intValueDefaultZero - xpReduction.xpReduction.intValueDefaultZero)))xp for \(character.fullName)") {
                                        runOnMainThread {
                                            self.mode.wrappedValue.dismiss()
                                            self.loadingXpReduction = false
                                        }
                                    }
                                }
                            } failureCase: { error in
                                self.loadingXpReduction = false
                            }

                        }
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                ProgressView().padding(.bottom, 8)
                Text("Loading...")
            }
        }
        .background(Color.lightGray)
        .onAppear {
            self.loadingSkills = true
            SkillManager.shared.getSkills() { skills in
                self.skills = skills
                self.loadingSkills = false
            }
        }
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
        return skills.filter({ $0.xpCost.intValueDefaultZero > 0 }).sorted { f, s in
            f.name.caseInsensitiveCompare(s.name) == .orderedAscending
        }
    }
}

struct XpReductionSkillCellView: View {
    @ObservedObject var _dm = DataManager.shared

    let skill: FullSkillModel
    @Binding var loadingXpReduction: Bool
    let onTap: (_ skill: FullSkillModel) -> Void

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
                LoadingButtonView($loadingXpReduction, width: 180, height: 44, buttonText: "Give Xp Reduction") {
                    onTap(skill)
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.lightGray)
    }

}

