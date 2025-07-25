//
//  BioView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/25/23.
//

import SwiftUI

struct BioView: View {
    @ObservedObject var _dm = OldDataManager.shared
    
    static func Offline(character: FullCharacterModel) -> BioView {
        return BioView(character: character, allowEdit: false, offline: true)
    }

    init(allowEdit: Bool) {
        self.allowEdit = allowEdit
        self.offline = false
        self._character = globalState(OldDataManager.shared.charForSelectedPlayer)
    }
    
    private init(character: FullCharacterModel, allowEdit: Bool, offline: Bool) {
        self.allowEdit = allowEdit
        self.offline = offline
        self._character = globalState(character)
    }

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
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.charForSelectedPlayer = md.fullCharacters()[1]
    var bv = BioView(allowEdit: true)
    bv._dm = dm
    return bv
}
