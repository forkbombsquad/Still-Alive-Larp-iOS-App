//
//  AccountTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import SwiftUI

struct AccountTabView: View {

    @ObservedObject var _dm = DataManager.shared

    @State private var loading: Bool = false
    @State private var loadingProfileImage: Bool = false
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "blank-profile")
    @State private var player: PlayerModel? = nil
    @State private var character: FullCharacterModel? = nil

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { gr in
                    let imgWidth = gr.size.width * 0.75
                    ScrollView {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh_AccountTab", spinnerOffsetY: -100, pullDownDistance: 60) {
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
                            if let character = character {
                                NavArrowView(title: "Character Stats", loading: $loading) { _ in
                                    CharacterStatusView()
                                }
                                NavArrowView(title: "Skill Management", loading: $loading) { _ in
                                    SkillManagementView(character: character, allowEdit: true)
                                }
                                NavArrowView(title: "Personal Skill Tree Diagram", loading: $loading) { _ in
                                    // TODO
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
                                // TODO
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
                                    DataManager.forceReset()
                                    DataManager.shared.popToRoot()
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
        }
    }
    
    private func reload(_ force: Bool) {
        runOnMainThread {
            self.loading = true
            self.loadingProfileImage = true
            DataManager.shared.load([.player, .character], forceDownloadIfApplicable: force) {
                DataManager.shared.setSelectedPlayerAndCharFromPlayerAndChar()
                runOnMainThread {
                    self.player = DataManager.shared.player
                    self.character = DataManager.shared.character
                    self.loading = false
                    DataManager.shared.profileImage = nil
                    DataManager.shared.load([.profileImage], forceDownloadIfApplicable: force) {
                        runOnMainThread {
                            self.image = DataManager.shared.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                            self.loadingProfileImage = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return AccountTabView(_dm: dm)
}
