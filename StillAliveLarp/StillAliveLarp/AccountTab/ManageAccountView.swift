//
//  ManageAccountView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct ManageAccountView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

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
                            ChangePasswordView(player: DM.getCurrentPlayer()!)
                        }
                        Spacer()
                        LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 16, buttonText: "Force Download Data") {
                            self.loading = true
                            DM.load(loadType: .forceDownload, finished:  {
                                DM.popToRoot()
                            })
                        }
                        LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 16, buttonText: "Delete Local Data") {
                            alertManager.showCustomNegativeOrCancelAlert("Are You Sure?", message: "Once deleted, all local data will be wiped and will need to be re-downloaded and reconfigured.", customButtonText: "Delete Local Data") {
                                self.loading = true
                                self.loadingText = ""
                                self.deleteLocalData()
                            }
                        }
                        LoadingButtonView($loading, loadingText: $loadingText, width: gr.size.width - 16, buttonText: "Delete Account") {
                            alertManager.showCustomNegativeOrCancelAlert("Are You Sure?", message: "Once your account is deleted it will be gone forever and CAN NOT be recovered.", customButtonText: "Delete Account") {
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
    
    private func deleteLocalData() {
        runOnMainThread {
            LocalDataManager.clearAllLocalData()
            alertManager.showOkAlert("Success", message: "All local data has been deleted! To see changes take effect, please completely close the app!") {}
        }
    }

    private func deleteCharSkills() {
        runOnMainThread {
            self.loading = true
        }
        guard let player = DM.getCurrentPlayer(), let character = player.getActiveCharacter() else {
            self.deleteEventAttendees()
            return
        }
        runOnMainThread {
            self.loadingText = "Deleting Skills"
        }
        CharacterSkillService.deleteSkills(characterId: character.id) { _ in
            self.deleteCharGear(charId: character.id)
        } failureCase: { error in
            self.deleteCharGear(charId: character.id)
        }
    }

    private func deleteCharGear(charId: Int) {
        runOnMainThread {
            self.loadingText = "Deleting Gear"
        }
        GearService.deleteGear(characterId: charId) { _ in
            self.deleteSpecialClassXpReductions(charId: charId)
        } failureCase: { error in
            self.deleteSpecialClassXpReductions(charId: charId)
        }
    }

    private func deleteSpecialClassXpReductions(charId: Int) {
        runOnMainThread {
            self.loadingText = "Deleting Xp Reductions"
        }
        SpecialClassXpReductionService.deleteXpReductions(characterId: charId) { _ in
            self.deleteEventAttendees()
        } failureCase: { error in
            self.deleteEventAttendees()
        }
    }

    private func deleteEventAttendees() {
        runOnMainThread {
            self.loading = true
            self.loadingText = "Deleting Events Attended"
        }
        
        EventAttendeeService.deleteAttendees { _ in
            self.deleteAwards()
        } failureCase: { error in
            self.deleteAwards()
        }
    }

    private func deleteAwards() {
        runOnMainThread {
            self.loadingText = "Deleting Awards"
        }
        AwardService.deleteAwards { _ in
            self.deletePreregs()
        } failureCase: { error in
            self.deletePreregs()
        }
    }

    private func deletePreregs() {
        runOnMainThread {
            self.loadingText = "Deleting Preregistrations"
        }
        EventPreregService.deletePreregs { _ in
            self.deleteCharacters()
        } failureCase: { error in
            self.deleteCharacters()
        }
    }

    private func deleteCharacters() {
        runOnMainThread {
            self.loadingText = "Deleting Characters"
        }
        
        CharacterService.deleteCharacters { _ in
            self.deleteProfileImages()
        } failureCase: { error in
            self.deleteProfileImages()
        }
    }

    private func deleteProfileImages() {
        runOnMainThread {
            self.loadingText = "Deleting Profile Image"
        }
        ProfileImageService.deleteProfileImage(DM.currentPlayerId) { profileImage in
            self.deletePlayer()
        } failureCase: { error in
            self.deletePlayer()
        }

    }

    private func deletePlayer() {
        runOnMainThread {
            self.loadingText = "Deleting Player"
        }
        PlayerService.deletePlayer { _ in
            self.successDeleting()
        } failureCase: { error in
            self.loading = false
        }
    }

    private func successDeleting() {
        runOnMainThread {
            self.loadingText = ""
            self.loading = false
            forceResetAllPlayerData()
            alertManager.showSuccessAlert("Your account and all associated data has been deleted, please restart the app!") {
                runOnMainThread {
                    DM.popToRoot()
                }
            }
        }
    }
}
