//
//  AccountTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import SwiftUI

struct AccountTabView: View {

    @ObservedObject private var _dm = DataManager.shared

    @State private var loading: Bool = false
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "blank-profile")

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { gr in
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
                                        .frame(width: 200, height: 200)
                                    if DataManager.shared.loadingProfileImage {
                                        ProgressView()
                                        .tint(.red)
                                        .controlSize(.large)
                                        .padding(.top, 80)
                                    }
                                    Text("EDIT")
                                        .bold()
                                        .font(.system(size: 24))
                                        .underline(color: .blue)
                                        .foregroundStyle(.blue)
                                        .shadow(color: .black, radius: 1)
                                        .padding(.top, 8)
                                }
                                Text(DataManager.shared.player?.fullName ?? "")
                                    .font(.system(size: 20))
                                    .underline()
                                    .frame(alignment: .center)
                                NavArrowView(title: "Player Stats") { _ in
                                    PlayerStatsView(player: DataManager.shared.player)
                                }
                                if DataManager.shared.character != nil {
                                    NavArrowView(title: "Character Stats") { _ in
                                        CharacterStatusAndGearView()
                                    }
                                    NavArrowView(title: "Skill Management") { _ in
                                        SkillManagementView()
                                    }
                                    NavArrowView(title: "Special Class Xp Reductions") { _ in
                                        SpecialClassXpReductionsView()
                                    }
                                    NavArrowView(title: "Bio") { _ in
                                        BioView(allowEdit: true)
                                    }
                                    NavArrowView(title: "Gear") { _ in
                                        GearView()
                                    }
                                }
                                NavArrowView(title: "Manage Account") { _ in
                                    ManageAccountView()
                                }
                                if DataManager.shared.player?.isAdmin.boolValue ?? false {
                                    NavArrowView(title: "Admin Tools") { _ in
                                        AdminView()
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
        AccountTabView()
    }
}
