//
//  GearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/20/23.
//

import SwiftUI

// TODO redo
struct GearView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    @Environment(\.presentationMode) var presentationMode

    let character: CharacterModel
    private let offline: Bool
    let allowEdit: Bool
    
    @State var loading: Bool = false
    @State var gearModified: Bool = false
    @State var gear: GearModel? = nil
    @State var gearJsonModels: [GearJsonModel] = []
    
    @State var firstLoad: Bool = true
    
    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { gr in
                VStack {
                    ScrollView {
                        Text("\(allowEdit ? "Manage\n" : "")\(character.fullName)'s\nGear\(gearModified ? "*" : "")\(offline ? " (Offline)" : "")")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                            .padding([.bottom], 16)
                        if (loading) {
                            Text("Loading Character Gear...")
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(alignment: .center)
                                .padding([.bottom], 16)
                            LoadingBlock()
                        } else {
                            GearViewModular(allowEdit: allowEdit, characterName: character.fullName, loading: $loading, gearModified: $gearModified, gearJsonModels: $gearJsonModels)
                        }
                    }
                    if gearModified {
                        LoadingButtonView($loading, width: gr.size.width - 16, buttonText: "Apply Changes") {
                            self.loading = true
                            if let gear = gear {
                                // Edit
                                let gearUpdateModel = GearModel(id: gear.id, characterId: character.id, gearJson: GearJsonListModel(gearJson: gearJsonModels).toJsonString() ?? "")
                                AdminService.updateGear(gearModel: gearUpdateModel) { gearModel in
                                    loading = false
                                    gearModified = false
                                    AlertManager.shared.showSuccessAlert("Gear Updated Successfully!") {}
                                } failureCase: { error in
                                    loading = false
                                }

                            } else {
                                // Add New
                                let gearCreateModel = GearCreateModel(characterId: character.id, gearJson: GearJsonListModel(gearJson: gearJsonModels).toJsonString() ?? "")
                                AdminService.createGear(gearCreateModel) { gearModel in
                                    loading = false
                                    gearModified = false
                                    AlertManager.shared.showSuccessAlert("Gear Created Successfully!") {}
                                } failureCase: { error in
                                    loading = false
                                }

                            }
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
//        .onAppear {
//            if !offline {
//                if firstLoad {
//                    runOnMainThread {
//                        firstLoad = false
//                        loading = true
//                        OldDM.selectedChar = character
//                        OldDM.load([.selectedCharacterGear], forceDownloadIfApplicable: true) {
//                            runOnMainThread {
//                                self.loading = false
//                                self.gear = OldDM.selectedCharacterGear?.first ?? GearModel(id: -1, characterId: -1, gearJson: "")
//                                self.gearJsonModels = self.gear?.jsonModels ?? []
//                            }
//                        }
//                    }
//                }
//            }
//        }
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

struct GearViewModular: View {
    
    let allowEdit: Bool
    let characterName: String
    
    @Binding var loading: Bool
    @Binding var gearModified: Bool
    @Binding var gearJsonModels: [GearJsonModel]

    var body: some View {
        VStack {
            if allowEdit {
                NavArrowViewGreen(title: "Add New", loading: $loading) {
                    return AddEditGearView(gearToEdit: nil, characterName: characterName) { newGearJsonIn in
                        if let ngj = newGearJsonIn {
                            runOnMainThread {
                                if ngj.isPrimaryFirearm() {
                                    self.removeExistingPrimaryFirearms()
                                }
                                self.gearJsonModels.append(ngj)
                                self.loading = false
                                self.gearModified = true
                            }
                        }
                    }
                }
            }
            GearSubview(title: "Firearms", key: Constants.GearTypes.firearm, allowEdit: allowEdit, gearJsonModels: $gearJsonModels, loading: $loading, gearModified: $gearModified, characterName: characterName)
            GearSubview(title: "Melee Weapons", key: Constants.GearTypes.meleeWeapon, allowEdit: allowEdit, gearJsonModels: $gearJsonModels, loading: $loading, gearModified: $gearModified, characterName: characterName)
            GearSubview(title: "Clothing", key: Constants.GearTypes.clothing, allowEdit: allowEdit, gearJsonModels: $gearJsonModels, loading: $loading, gearModified: $gearModified, characterName: characterName)
            GearSubview(title: "Accessories", key: Constants.GearTypes.accessory, allowEdit: allowEdit, gearJsonModels: $gearJsonModels, loading: $loading, gearModified: $gearModified, characterName: characterName)
            GearSubview(title: "Bags", key: Constants.GearTypes.bag, allowEdit: allowEdit, gearJsonModels: $gearJsonModels, loading: $loading, gearModified: $gearModified, characterName: characterName)
            GearSubview(title: "Other", key: Constants.GearTypes.other, allowEdit: allowEdit, gearJsonModels: $gearJsonModels, loading: $loading, gearModified: $gearModified, characterName: characterName)
        }
    }
    
    private func removeExistingPrimaryFirearms() {
        if var prevPrim = self.gearJsonModels.first(where: { $0.isPrimaryFirearm() })?.clone() {
            self.gearJsonModels.removeAll(where: { $0.isPrimaryFirearm() })
            prevPrim.secondarySubtype = Constants.GearSecondarySubtype.none
            self.gearJsonModels.append(prevPrim)
        }
    }
    
}

struct GearSubview: View {
    
    let title: String
    let key: String
    let allowEdit: Bool
    
    @Binding var gearJsonModels: [GearJsonModel]
    @Binding var loading: Bool
    @Binding var gearModified: Bool
    
    let characterName: String
    
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
                            return AddEditGearView(gearToEdit: gear, characterName: characterName) { editedJsonGear in
                                runOnMainThread {
                                    self.gearJsonModels.removeAll(where: { $0.isEqualTo(other: gear) })
                                    if let ejg = editedJsonGear {
                                        if ejg.isPrimaryFirearm() {
                                            self.removeExistingPrimaryFirearms()
                                        }
                                        self.gearJsonModels.append(ejg)
                                    }
                                    self.loading = false
                                    self.gearModified = true
                                }
                            }
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
        models = gearJsonModels.filter({ $0.gearType == key })
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
    
    private func removeExistingPrimaryFirearms() {
        if var prevPrim = self.gearJsonModels.first(where: { $0.isPrimaryFirearm() })?.clone() {
            self.gearJsonModels.removeAll(where: { $0.isPrimaryFirearm() })
            prevPrim.secondarySubtype = Constants.GearSecondarySubtype.none
            self.gearJsonModels.append(prevPrim)
        }
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return GearView(character: md.character(id: 2), allowEdit: true)
//}
