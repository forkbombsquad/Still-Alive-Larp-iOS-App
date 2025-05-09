//
//  ManageAccountView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct ManageAccountView: View {
    @ObservedObject var _dm = DataManager.shared

    @State var loading = false
    @State var loadingText = ""

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Manage Account")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        NavArrowView(title: "Change Password") { _ in
                            ChangePasswordView()
                        }
                        Spacer()
                        LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 16, buttonText: "Delete Account") {
                            AlertManager.shared.showCustomNegativeOrCancelAlert("Are You Sure?", message: "Once your account is deleted it will be gone forever and CAN NOT be recovered.", customButtonText: "Delete Account") {
                                self.loading = true
                                self.loadingText = ""
                                self.deleteCharSkills()
                            }
                        }
                    }
                }
            }
        }.padding(16)
            .background(Color.lightGray)
    }

    private func deleteCharSkills() {
        if let charId = DataManager.shared.character?.id {
            self.loadingText = "Deleting Skills"
            CharacterSkillService.deleteSkills(characterId: charId) { _ in
                self.deleteCharGear()
            } failureCase: { error in
                self.deleteCharGear()
            }
        } else {
            deleteEventAttendees()
        }
    }

    private func deleteCharGear() {
        if let charId = DataManager.shared.character?.id {
            self.loadingText = "Deleting Gear"
            GearService.deleteGear(characterId: charId) { _ in
                self.deleteSpecialClassXpReductions()
            } failureCase: { error in
                self.deleteSpecialClassXpReductions()
            }
        } else {
            deleteEventAttendees()
        }
    }

    private func deleteSpecialClassXpReductions() {
        self.loadingText = "Deleting Xp Reductions"
        if let charId = DataManager.shared.character?.id {
            SpecialClassXpReductionService.deleteXpReductions(characterId: charId) { _ in
                self.deleteEventAttendees()
            } failureCase: { error in
                self.deleteEventAttendees()
            }
        } else {
            deleteEventAttendees()
        }
    }

    private func deleteEventAttendees() {
        self.loadingText = "Deleting Events Attended"
        EventAttendeeService.deleteAttendees { _ in
            self.deleteAwards()
        } failureCase: { error in
            self.deleteAwards()
        }
    }

    private func deleteAwards() {
        self.loadingText = "Deleting Awards"
        AwardService.deleteAwards { _ in
            self.deletePreregs()
        } failureCase: { error in
            self.deletePreregs()
        }
    }

    private func deletePreregs() {
        self.loadingText = "Deleting Preregistrations"
        EventPreregService.deletePreregs { _ in
            self.deleteCharacters()
        } failureCase: { error in
            self.deleteCharacters()
        }
    }

    private func deleteCharacters() {
        self.loadingText = "Deleting Characters"
        CharacterService.deleteCharacters { _ in
            self.deleteProfileImages()
        } failureCase: { error in
            self.deleteProfileImages()
        }
    }

    private func deleteProfileImages() {
        self.loadingText = "Deleting Profile Images"
        ProfileImageService.deleteProfileImage(DataManager.shared.player?.id ?? -1) { profileImage in
            self.deletePlayer()
        } failureCase: { error in
            self.deletePlayer()
        }

    }

    private func deletePlayer() {
        self.loadingText = "Deleting Player"
        PlayerService.deletePlayer { _ in
            self.successDeleting()
        } failureCase: { error in
            self.loading = false
        }
    }

    private func successDeleting() {
        self.loadingText = ""
        AlertManager.shared.showSuccessAlert("Your account and all associated data has been deleted!") {
            forceResetAllPlayerData()
            runOnMainThread {
                DataManager.shared.popToRoot()
            }
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return ManageAccountView(_dm: dm, loading: false)
}
