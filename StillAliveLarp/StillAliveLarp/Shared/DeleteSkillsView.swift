//
//  DeleteSkillsView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct DeleteSkillsView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    enum DeleteSkillsViewMode {
        case refund, justDelete
    }

    @Binding var character: FullCharacterModel?
    let mode: DeleteSkillsViewMode
    
    @State var loading: Bool = false

    var body: some View {
        VStack {
            if let character = character {
                globalCreateTitleView("\(mode == .refund ? "Refund" : "Delete") Skills For\n\(character.fullName)", DM: DM)
                LoadingLayoutView {
                    VStack {
                        List() {
                            ForEach(character.allPurchasedSkills().filter({ $0.baseXpCost() > 0 }).alphabetized) { skill in
                                ArrowViewButton(title: skill.name, loading: $loading) {
                                    runOnMainThread {
                                        self.loading = true
                                        CharacterSkillService.deleteSkills(playerId: character.playerId, charId: character.id, skillId: skill.id) { charSkills in
                                            runOnMainThread {
                                                switch mode {
                                                case .refund:
                                                    let player = DM.getPlayerForCharacter(character)
                                                    var xp = 0
                                                    var fs = 0
                                                    var pp = 0
                                                    for skl in charSkills.charSkills {
                                                        xp += skl.xpSpent
                                                        fs += skl.fsSpent
                                                        pp += skl.ppSpent
                                                    }
                                                    let modPlayer = player.baseModelWithModifications(xpChange: xp, ft1sChange: fs, ppChange: pp)
                                                    AdminService.updatePlayer(modPlayer, onSuccess: { _ in
                                                        runOnMainThread {
                                                            DM.load(finished: {
                                                                runOnMainThread {
                                                                    self.character = character
                                                                    self.loading = false
                                                                    AlertManager.shared.showSuccessAlert("Refunded \(xp)xp, \(fs)fs, and \(pp)pp to \(character.fullName) (\(player.fullName) for the removed skill: \(skill.name)", onOkAction: {})
                                                                }
                                                            })
                                                        }
                                                    }, failureCase: { error in
                                                        runOnMainThread {
                                                            self.loading = false
                                                        }
                                                    })
                                                case .justDelete:
                                                    DM.load(finished: {
                                                        runOnMainThread {
                                                            self.character = character
                                                            self.loading = false
                                                            AlertManager.shared.showSuccessAlert("\(skill.name) removed from \(character.fullName)", onOkAction: {})
                                                        }
                                                    })
                                                }
                                            }
                                        } failureCase: { error in
                                            runOnMainThread {
                                                self.loading = false
                                            }
                                        }

                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}
