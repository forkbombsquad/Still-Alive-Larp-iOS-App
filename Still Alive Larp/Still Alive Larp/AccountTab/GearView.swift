//
//  GearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/20/23.
//

import SwiftUI

struct GearView: View {
    @ObservedObject var _dm = DataManager.shared

    init(offline: Bool = false) {
        self.offline = offline
    }

    let offline: Bool

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack {
                    if (DataManager.shared.loadingSelectedCharacterGear || DataManager.shared.loadingCharForSelectedPlayer) {
                        Text("Loading Character Gear...")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                            .padding([.bottom], 16)
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if let char = DataManager.shared.charForSelectedPlayer, let gear = DataManager.shared.selectedCharacterGear {
                        Text("\(char.fullName)'s\nGear\(offline ? " (Offline)" : "")")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                            .padding([.bottom], 16)
                        Divider().background(Color.darkGray)
                        // TODO fix
//                        if let primaryWeapon = gear.primaryWeapon {
//                            KeyValueView(key: "Primary Weapon", value: primaryWeapon.name, showDivider: false)
//                            Text(primaryWeapon.description).padding([.top], 4)
//                            Divider().background(Color.darkGray)
//                        } else {
//                            KeyValueView(key: "Primary Weapon", value: "None", showDivider: true)
//                        }
//                        let modGearList = gear.removingPrimaryWeapon
//                        ForEach(modGearList) { gear in
//                            KeyValueView(key: gear.type, value: gear.name, showDivider: false)
//                            Text(gear.description).padding([.top], 4)
//                            Divider().background(Color.darkGray)
//                        }
                    } else {
                        Text("Something went wrong!")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                            .padding([.bottom], 16)
                    }
                }
            }
            HStack {
                Spacer()
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            if !offline {
                DataManager.shared.load([.charForSelectedPlayer]) {
                    runOnMainThread {
                        DataManager.shared.selectedChar = DataManager.shared.charForSelectedPlayer?.baseModel
                        DataManager.shared.load([.selectedCharacterGear], forceDownloadIfApplicable: true)
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
    let md = getMockData()
    dm.loadingSelectedCharacterGear = false
    dm.loadingCharForSelectedPlayer = false
    dm.charForSelectedPlayer = md.fullCharacters()[1]
    var gv = GearView(offline: false)
    gv._dm = dm
    return gv
}
