//
//  ViewPlayerStuffView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct ViewPlayerStuffView: View {
    @ObservedObject private var _dm = DataManager.shared

    private let playerModel: PlayerModel
    @State private var image: UIImage = UIImage(imageLiteralResourceName: "blank-profile")

    init(player: PlayerModel) {
        self.playerModel = player
    }

    var body: some View {
        VStack {
            ScrollView {
                GeometryReader { gr in
                    VStack {
                        Text(DataManager.shared.selectedPlayer?.fullName ?? playerModel.fullName)
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .padding(.bottom, 8)
                            if DataManager.shared.loadingProfileImage {
                                ProgressView()
                                .tint(.red)
                                .controlSize(.large)
                                .padding(.top, 80)
                            }
                        }
                        NavArrowView(title: "Player Stats") { _ in
                            PlayerStatsView(player: DataManager.shared.selectedPlayer ?? playerModel)
                        }
                        if DataManager.shared.loadingCharForSelectedPlayer {
                            NavArrowView(title: "Character Stats", loading: DataManager.$shared.loadingCharForSelectedPlayer) { _ in }
                            NavArrowView(title: "Skills", loading: DataManager.$shared.loadingCharForSelectedPlayer) { _ in }
                            NavArrowView(title: "Bio", loading: DataManager.$shared.loadingCharForSelectedPlayer) { _ in }
                        } else if DataManager.shared.charForSelectedPlayer != nil {
                            NavArrowView(title: "Character Stats") { _ in
                                CharacterStatusAndGearView()
                            }
                            NavArrowView(title: "Skills") { _ in
                                SkillManagementView()
                            }
                            NavArrowView(title: "Bio") { _ in
                                BioView(allowEdit: false)
                            }
                            NavArrowView(title: "Gear") { _ in
                                GearView()
                            }
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            runOnMainThread {
                DataManager.shared.selectedPlayer = self.playerModel
                runOnMainThread {
                    DataManager.shared.profileImage = nil
                    DataManager.shared.load([.charForSelectedPlayer])
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
