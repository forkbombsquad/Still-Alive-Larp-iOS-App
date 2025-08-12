//
//  BioView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

// TODO redo view

struct BioView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let allowEdit: Bool
    let offline: Bool
    @State var character: FullCharacterModel? = nil

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack {
                    Text("\(character?.fullName ?? "")'s\nBio\(offline ? " (Offline)" : "")")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(alignment: .center)
                        .padding([.bottom], 16)
                    Divider()
                    Text(character?.bio ?? "")
                    if allowEdit && !offline {
                        NavArrowViewRed(title: "Edit Bio") {
//                            EditBioView()
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

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return BioView(allowEdit: true)
//}
