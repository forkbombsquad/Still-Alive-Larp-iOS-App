//
//  AccountTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import SwiftUI

struct AccountTabView: View {

    @ObservedObject var _dm = OldDataManager.shared

    @State private var loading: Bool = false
    @State private var loadingProfileImage: Bool = false
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "blank-profile")
    @State private var player: PlayerModel? = nil
    @State private var character: FullCharacterModel? = nil
    @State private var skills: [FullSkillModel] = []
    @State private var skillCategories: [SkillCategoryModel] = []
    @State private var xpReductions: [SpecialClassXpReductionModel] = []
    @State private var loadingXpReductions = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { gr in
                    let imgWidth = gr.size.width * 0.75
                    ScrollView {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh_AccountTab", spinnerOffsetY: -100, pullDownDistance: 150) {
                            self.reload(true)
                        }
                        VStack {
                            Text("My Account")
                                .font(.system(size: 32, weight: .bold))
                                .frame(alignment: .center)
                            NavigationLink(destination: EditProfileImageView()) {
                                ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: imgWidth, height: imgWidth)
                                    if loadingProfileImage {
                                        ProgressView()
                                        .tint(.red)
                                        .controlSize(.large)
                                        .padding(.top, 80)
                                    }
                                    FakeLoadingButtonView($loadingProfileImage, width: 44, height: 44, buttonText: "Edit")
                                    
                                }
                            }.disabled(loadingProfileImage)
                            Text(self.player?.fullName ?? "")
                                .font(.system(size: 20))
                                .underline()
                                .frame(alignment: .center)
                            Text("Character")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                            if let player = player {
                                if let character = character {
                                    NavArrowView(title: "Character Stats", loading: $loading) { _ in
                                        CharacterStatusView()
                                    }
                                    NavArrowView(title: "Skill Management", loading: $loading) { _ in
                                        SkillManagementView(character: character, allowEdit: true)
                                    }
                                    NavArrowView(title: "Personal Skill Tree Diagram", loading: $loadingXpReductions) { _ in
                                        NativeSkillTree(skillGrid: SkillGrid(skills: skills, skillCategories: skillCategories, personal: true, allowPurchase: true), player: player, character: character, xpReductions: xpReductions)
                                    }
                                    NavArrowView(title: "Bio", loading: $loading) { _ in
                                        BioView(allowEdit: true)
                                    }
                                    NavArrowView(title: "Gear", loading: $loading) { _ in
                                        GearView(character: character.baseModel, allowEdit: false)
                                    }
                                    NavArrowView(title: "Special Class Xp Reductions", loading: $loading) { _ in
                                        SpecialClassXpReductionsView()
                                    }
                                }
                                NavArrowViewBlue(title: "Character Planner") {
                                    CharacterPlannerListView(player: player)
                                }
                            }
                            
                            Text("Account")
                                .font(.system(size: 24, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            NavArrowView(title: "Player Stats", loading: $loading) { _ in
                                PlayerStatsView(player: self.player)
                            }
                            
                            NavArrowView(title: "Manage Account", loading: $loading) { _ in
                                ManageAccountView()
                            }
                            if self.player?.isAdmin.boolValue ?? false {
                                NavArrowViewRed(title: "Admin Tools", loading: $loading) {
                                    AdminView()
                                }
                            }
                            if Constants.Logging.showDebugButtonInAccountView {
                                NavArrowViewRed(title: "Debug Button", loading: $loading) {
                                    // TODO ALWAYS - remove all code here before launch
                                }
                            }
                            LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Sign Out") {
                                runOnMainThread {
                                    OldDataManager.forceReset()
                                    OldDataManager.shared.popToRoot()
                                }
                            }
                        }
                    }
                }
            }.padding(16)
            .background(Color.lightGray)
            .onAppear {
                self.reload(false)
            }
        }.navigationViewStyle(.stack)
    }
    
    private func reload(_ force: Bool) {
        runOnMainThread {
            self.loading = true
            self.loadingProfileImage = true
            self.loadingXpReductions = true
            OldDataManager.shared.load([.player, .character, .skills, .skillCategories], forceDownloadIfApplicable: force) {
                OldDataManager.shared.setSelectedPlayerAndCharFromPlayerAndChar()
                runOnMainThread {
                    self.player = OldDataManager.shared.player
                    self.character = OldDataManager.shared.character
                    self.skills = OldDataManager.shared.skills ?? []
                    self.skillCategories = OldDataManager.shared.skillCategories
                    self.loading = false
                    OldDataManager.shared.load([.xpReductions]) {
                        runOnMainThread {
                            self.xpReductions = OldDataManager.shared.xpReductions ?? []
                            self.loadingXpReductions = false
                        }
                    }
                    OldDataManager.shared.profileImage = nil
                    OldDataManager.shared.load([.profileImage], forceDownloadIfApplicable: force) {
                        runOnMainThread {
                            self.image = OldDataManager.shared.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                            self.loadingProfileImage = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return AccountTabView(_dm: dm)
}
