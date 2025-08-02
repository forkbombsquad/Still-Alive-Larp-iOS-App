//
//  SpecialClassXpReductionsView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/29/23.
//

import SwiftUI

struct SpecialClassXpReductionsView: View {
    @ObservedObject var _dm = DataManager.shared

    @State var loading: Bool = true

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .center) {
                    Text("Special Class Xp Reductions For\n\(OldDataManager.shared.charForSelectedPlayer?.fullName ?? "")")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                        .padding([.bottom], 16)
                    Divider()
                    if loading {
                        ProgressView().padding(.bottom, 8)
                        Text("Loading...")
                    } else {
                        if !(OldDataManager.shared.xpReductions ?? []).isEmpty {
                            ForEach(OldDataManager.shared.xpReductions ?? []) { xpRed in
                                if let skill = getSkill(xpRed: xpRed) {
                                    KeyValueView(key: skill.name, value: "-\(xpRed.xpReduction) (new cost: \(skill.getModCost(combatMod: 0, professionMod: 0, talentMod: 0, xpReduction: xpRed)))")
                                }
                            }
                        } else {
                            Text("You have no Xp Reductions from classes you've taken. Try taking a Special class with someone who has the Professor skill to reduce the xp cost of specific skills! Don't forget to pay them!")
                        }
                    }
                }
            }
            HStack {
                Spacer()
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            self.loading = true
            OldDataManager.shared.load([.xpReductions], forceDownloadIfApplicable: true) {
                OldDataManager.shared.load([.skills]) {
                    self.loading = false
                }
            }
        }
    }

    func getSkill(xpRed: SpecialClassXpReductionModel) -> OldFullSkillModel? {
        return OldDataManager.shared.skills?.first(where: { $0.id == xpRed.skillId })
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.charForSelectedPlayer = md.fullCharacters()[0]
    return SpecialClassXpReductionsView(_dm: dm, loading: false)
}
