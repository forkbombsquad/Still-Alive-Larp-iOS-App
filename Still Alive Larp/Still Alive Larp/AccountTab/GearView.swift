//
//  GearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/20/23.
//

import SwiftUI

struct GearView: View {
    @ObservedObject var _dm = DataManager.shared
    @Environment(\.presentationMode) var presentationMode

    init(character: CharacterModel, offline: Bool = false, allowEdit: Bool = false) {
        self.character = character
        self.offline = offline
        self.allowEdit = allowEdit
    }

    let character: CharacterModel
    let offline: Bool
    let allowEdit: Bool
    
    @State var loading: Bool = false
    @State var gearModified: Bool = false
    
    // TODO add the "Add New Gear" button if this is on the manage gear page
    // Also adjust hte title based on if this is managing or not
    // TODO override back button because of unsaved changes

    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { gr in
                VStack {
                    ScrollView {
                        VStack {
                            if (DataManager.shared.loadingSelectedCharacterGear) {
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
                            } else if let char = DataManager.shared.selectedChar {
                                let gearJson = DataManager.shared.selectedCharacterGear?.first?.jsonModels ?? []
                                Text("\(allowEdit ? "Manage\n" : "")\(char.fullName)'s\nGear\(gearModified ? "*" : "")\(offline ? " (Offline)" : "")")
                                    .font(.system(size: 32, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .frame(alignment: .center)
                                    .padding([.bottom], 16)
                                if allowEdit {
                                    NavArrowViewGreen(title: "Add New", loading: $loading) {
                                        // TODO add new
                                    }
                                }
                                GearSubview(title: "Firearms", key: Constants.GearTypes.firearm, gearJson: gearJson, allowEdit: allowEdit)
                                GearSubview(title: "Melee Weapons", key: Constants.GearTypes.meleeWeapon, gearJson: gearJson, allowEdit: allowEdit)
                                GearSubview(title: "Clothing", key: Constants.GearTypes.clothing, gearJson: gearJson, allowEdit: allowEdit)
                                GearSubview(title: "Accessories", key: Constants.GearTypes.accessory, gearJson: gearJson, allowEdit: allowEdit)
                                GearSubview(title: "Bags", key: Constants.GearTypes.bag, gearJson: gearJson, allowEdit: allowEdit)
                                GearSubview(title: "Other", key: Constants.GearTypes.other, gearJson: gearJson, allowEdit: allowEdit)
                            } else {
                                Text("Something went wrong!")
                                    .font(.system(size: 32, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .frame(alignment: .center)
                                    .padding([.bottom], 16)
                            }
                        }
                    }
                    if gearModified {
                        LoadingButtonView($loading, width: gr.size.width - 16, buttonText: "Apply Changes") {
                            // TODO apply changes
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear {
            DataManager.shared.selectedChar = character
            DataManager.shared.load([.selectedCharacterGear], forceDownloadIfApplicable: true)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { // Custom back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if gearModified {
                        AlertManager.shared.showOkAlert("Unsaved Changes!", message: "You have not saved your changes. Please hit Apply Changes before navigating away.") { }
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
}

struct GearSubview: View {
    
    let title: String
    let key: String
    let gearJson: [GearJsonModel]
    let allowEdit: Bool
    
    @State var loading: Bool = false
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
            LazyVStack(spacing: 8) {
                ForEach(sortAndFilterGear()) { gear in
                    if allowEdit {
                        GearCell(gearJsonModel: gear, loading: loading) {
                            // TODO edit gear
                        }
                    } else {
                        GearCell(gearJsonModel: gear, loading: loading)
                    }
                }
            }
        }
    }
    
    func sortAndFilterGear() -> [GearJsonModel] {
        var models = [GearJsonModel]()
        // filter
        models = gearJson.filter({ $0.gearType == key })
        // sort
        
        models.sort { first, second in
            if key == Constants.GearTypes.firearm {
                if first.isPrimaryFirearm() { return true }
            }
            let fssp = subtypeSortPriority(subtype: first.primarySubtype)
            let sssp = subtypeSortPriority(subtype: second.primarySubtype)
            
            if fssp == sssp {
                return first.name.compare(second.name).rawValue < 0 ? true : false
            } else {
                return fssp < sssp
            }
        }
        
        return models
    }
    
    private func subtypeSortPriority(subtype: String) -> Int {
        typealias st = Constants.GearPrimarySubtype
        switch subtype {
        case st.lightFirearm, st.superLightMeleeWeapon, st.flashlight, st.smallBag:
            return 1
        case st.mediumFirearm, st.lightMeleeWeapon, st.blacklightFlashlight, st.mediumBag:
            return 2
        case st.heavyFirearm, st.mediumMeleeWeapon, st.largeBag:
            return 3
        case st.advancedFirearm, st.heavyMeleeWeapon, st.extraLargeBag:
            return 4
        case st.militaryGradeFirearm:
            return 5
        case st.other:
            return 6
        default:
            return 0
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.loadingSelectedCharacterGear = false
    dm.selectedCharacterGear = [md.gear(characterId: 2)]
    var gv = GearView(character: md.character(id: 2), offline: false, allowEdit: true)
    gv._dm = dm
    return gv
}
