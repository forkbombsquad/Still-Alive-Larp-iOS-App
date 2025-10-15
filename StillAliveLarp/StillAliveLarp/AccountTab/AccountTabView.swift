//
//  AccountTabView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import SwiftUI

struct AccountTabView: View {

    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { gr in
                    let imgWidth = gr.size.width * 0.75
                    ScrollView {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh_AccountTab", spinnerOffsetY: -100, pullDownDistance: 150) {
                            DM.load()
                        }
                        VStack {
                            globalCreateTitleView("My Account", DM: DM)
                            LoadingLayoutView {
                                VStack {
                                    let player = DM.getCurrentPlayer()!
                                    if DM.offlineMode {
                                        Image(uiImage: player.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile"))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                            .padding(.bottom, 8)
                                    } else {
                                        NavigationLink(destination: EditProfileImageView()) {
                                            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                                Image(uiImage: player.profileImage?.uiImage ?? UIImage(imageLiteralResourceName: "blank-profile"))
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: imgWidth, height: imgWidth)
                                                
                                                FakeLoadingButtonView(.constant(false), width: 44, height: 44, buttonText: "Edit")
                                            }
                                        }
                                    }
                                    Text(player.fullName)
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(alignment: .leading)
                                        .padding(.top, 24)
                                    NavArrowView(title: "View Player Stats") { _ in
                                        ViewPlayerStatsView(player: player)
                                    }
                                    NavArrowView(title: "View Player Awards") { _ in
                                        ViewAwardsView(player: player, awards: player.getAwardsSorted())
                                    }
                                    CharacterPanel(fromAccount: true, player: player, character: DM.getActiveCharacter())
                                    Text("Account")
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    NavArrowView(title: "Manage Account") { _ in
                                        ManageAccountView()
                                    }
                                    if DM.getCurrentPlayer()?.isAdmin ?? false {
                                        NavArrowViewRed(title: "Admin Tools") {
                                            AdminView()
                                        }
                                    }
                                    if Constants.Logging.showDebugButtonInAccountView {
                                        NavArrowViewRed(title: "Debug Button") {
                                            // TODO ALWAYS - remove all code here before launch
                                        }
                                    }
                                    LoadingButtonView(.constant(false), width: gr.size.width - 32, buttonText: "\(DM.offlineMode ? "Exit Offline Mode" : "Sign Out")") {
                                        runOnMainThread {
                                            if DM.offlineMode {
                                                DM.setCurrentPlayerId(-1)
                                            }
                                            DM.popToRoot()
                                        }
                                    }
                                }
                            }
                        }
                    }.coordinateSpace(name: "pullToRefresh_AccountTab")
                }
            }
            .padding(16)
            .background(Color.lightGray)
        }.navigationViewStyle(.stack)
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    return AccountTabView()
//}
