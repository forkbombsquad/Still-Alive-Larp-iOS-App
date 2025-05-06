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
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "blank-profile")

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { gr in
                    let imgWidth = gr.size.width * 0.75
                    ScrollView {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh_AccountTab", spinnerOffsetY: -100, pullDownDistance: 60) {
                            DataManager.shared.load([.player, .character], forceDownloadIfApplicable: true) {
                                DataManager.shared.setSelectedPlayerAndCharFromPlayerAndChar()
                            }
                        }
                            VStack {
                                Text("My Account")
                                    .font(.system(size: 32, weight: .bold))
                                    .frame(alignment: .center)
                                ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: imgWidth, height: imgWidth)
                                    if DataManager.shared.loadingProfileImage {
                                        ProgressView()
                                        .tint(.red)
                                        .controlSize(.large)
                                        .padding(.top, 80)
                                    }
                                    LoadingButtonView($loading, width: 44, height: 44, buttonText: "Edit") {
                                        // TODO EDIT profile image
                                    }
                                }
                                Text(DataManager.shared.player?.fullName ?? "")
                                    .font(.system(size: 20))
                                    .underline()
                                    .frame(alignment: .center)
                                Text("Character")
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8)
                                if DataManager.shared.character != nil {
                                    NavArrowView(title: "Character Stats") { _ in
                                        CharacterStatusAndGearView()
                                    }
                                    NavArrowView(title: "Skill Management") { _ in
                                        SkillManagementView()
                                    }
                                    NavArrowView(title: "Personal Skill Tree Diagram") { _ in
                                        // TODO
                                    }
                                    NavArrowView(title: "Bio") { _ in
                                        BioView(allowEdit: true)
                                    }
                                    NavArrowView(title: "Gear") { _ in
                                        GearView()
                                    }
                                    NavArrowView(title: "Special Class Xp Reductions") { _ in
                                        SpecialClassXpReductionsView()
                                    }
                                }
                                NavArrowViewBlue(title: "Character Planner") {
                                    // TODO
                                }
                                
                                Text("Account")
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                NavArrowView(title: "Player Stats") { _ in
                                    PlayerStatsView(player: DataManager.shared.player)
                                }
                                
                                NavArrowView(title: "Manage Account") { _ in
                                    ManageAccountView()
                                }
                                if DataManager.shared.player?.isAdmin.boolValue ?? false {
                                    NavArrowViewRed(title: "Admin Tools") {
                                        AdminView()
                                    }
                                }
                                if Constants.Logging.showDebugButtonInAccountView {
                                    NavArrowViewRed(title: "Debug Button") {
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
                DataManager.shared.loadingProfileImage = true
                DataManager.shared.load([.player, .character]) {
                    DataManager.shared.setSelectedPlayerAndCharFromPlayerAndChar()
                    runOnMainThread {
                        DataManager.shared.profileImage = nil
                        DataManager.shared.load([.profileImage]) {
                            runOnMainThread {
                                self.image = DataManager.shared.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AccountTabView_Previews: PreviewProvider {
    static var previews: some View {
        let dm = DataManager.shared
        dm.debugMode = true
        dm.loadMockData()
        return AccountTabView(_dm: dm)
    }
}
