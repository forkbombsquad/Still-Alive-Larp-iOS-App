//
//  BioView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct BioView: View {
    @ObservedObject var _dm = DataManager.shared

    init(allowEdit: Bool, offline: Bool = false) {
        self.allowEdit = allowEdit
        self.offline = offline
    }

    let allowEdit: Bool
    let offline: Bool

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack {
                    Text("\(DataManager.shared.charForSelectedPlayer?.fullName ?? "")'s\nBio\(offline ? " (Offline)" : "")")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                        .padding([.bottom], 16)
                    Divider()
                    Text(DataManager.shared.charForSelectedPlayer?.bio ?? "")
                    if allowEdit && !offline {
                        NavArrowViewRed(title: "Edit Bio") {
                            EditBioView()
                        }
                    }
                }
            }
            HStack {
                Spacer()
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.charForSelectedPlayer = md.fullCharacters()[1]
    var bv = BioView(allowEdit: true, offline: false)
    bv._dm = dm
    return bv
}
