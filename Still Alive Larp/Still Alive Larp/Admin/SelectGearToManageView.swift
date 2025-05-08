//
//  SelectGearToManageView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/30/23.
//

import SwiftUI

struct SelectGearToManageView: View {
    @ObservedObject var _dm = DataManager.shared

    let character: CharacterModel
    @State private var name: String = ""
    @State private var ammo: String = ""

    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        // TODO fix this view
//                        Text("Manage Gear\nFor \(character.fullName)")
//                            .font(Font.system(size: 36, weight: .bold))
//                            .multilineTextAlignment(.center)
//                            .padding(.trailing, 0)
                        Text("*Note, primary weapons are not shown in this list.")
//                        if DataManager.shared.loadingSelectedCharacterGear {
//                            HStack {
//                                Spacer()
//                                ProgressView()
//                                Spacer()
//                            }
//                        } else {
//                            NavArrowViewGreen(title: "Add New") {
//                                ManageGearView(gear: nil)
//                            }
//                            ForEach(DataManager.shared.selectedCharacterGear?.removingPrimaryWeapon ?? []) { gear in
//                                NavArrowView(title: "\(gear.name) - \(gear.type)") { _ in
//                                    ManageGearView(gear: gear)
//                                }.navigationViewStyle(.stack)
//                            }
//                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            runOnMainThread {
                DataManager.shared.selectedChar = character
                DataManager.shared.load([.selectedCharacterGear], forceDownloadIfApplicable: true) {
                    // Do nothing
                }
            }
        }
    }
}

