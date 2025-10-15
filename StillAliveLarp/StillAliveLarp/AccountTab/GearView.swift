//
//  GearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/20/23.
//

import SwiftUI

struct GearView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    @Environment(\.presentationMode) var presentationMode

    @State var character: FullCharacterModel
    
    @State var loading: Bool = false
    @State var gearModified: Bool = false
    @State var gear: GearModel? = nil
    @State var gearJsonModels: [GearJsonModel] = []
    
    @State var firstLoad = true
    
    var body: some View {
        VStack(alignment: .center) {
            GeometryReader { gr in
                VStack {
                    ScrollView {
                        globalCreateTitleView("\(allowEdit() ? "Manage" : "\n")\(character.fullName)'s\nGear\(gearModified ? "*" : "")", DM: DM)
                        LoadingLayoutView {
                            GearViewModular(allowEdit: allowEdit(), characterName: character.fullName, loading: $loading, gearModified: $gearModified, gearJsonModels: $gearJsonModels)
                        }
                    }
                    if gearModified && !DM.isLoadingMirror {
                        LoadingButtonView($loading, width: gr.size.width - 16, buttonText: "Apply Changes") {
                            self.loading = true
                            if let gear = gear {
                                // Edit
                                let gearUpdateModel = GearModel(id: gear.id, characterId: character.id, gearJson: GearJsonListModel(gearJson: gearJsonModels).toJsonString() ?? "")
                                AdminService.updateGear(gearModel: gearUpdateModel) { gearModel in
                                    runOnMainThread {
                                        loading = false
                                        gearModified = false
                                        alertManager.showSuccessAlert("Gear Updated Successfully!") {}
                                        DM.load(finished: {
                                            runOnMainThread {
                                                self.reloadModels()
                                            }
                                        })
                                    }
                                } failureCase: { error in
                                    runOnMainThread {
                                        loading = false
                                    }
                                }
                            } else {
                                // Add New
                                let gearCreateModel = GearCreateModel(characterId: character.id, gearJson: GearJsonListModel(gearJson: gearJsonModels).toJsonString() ?? "")
                                AdminService.createGear(gearCreateModel) { gearModel in
                                    runOnMainThread {
                                        loading = false
                                        gearModified = false
                                        alertManager.showSuccessAlert("Gear Created Successfully!") {}
                                        DM.load(finished: {
                                            runOnMainThread {
                                                self.reloadModels()
                                            }
                                        })
                                    }
                                } failureCase: { error in
                                    runOnMainThread {
                                        loading = false
                                    }
                                }

                            }
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
        .onAppear() {
            if firstLoad {
                firstLoad = false
                reloadModels()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { // Custom back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if gearModified || DM.isLoadingMirror {
                        alertManager.showOkAlert("Unsaved Changes!", message: "You have not saved your changes. Please hit Apply Changes before navigating away.") { }
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
    
    func allowEdit() -> Bool {
        return DM.getPlayerForCharacter(character).isAdmin && !DM.offlineMode
    }
    
    func reloadModels() {
        self.character = DM.getCharacter(character.id) ?? character
        self.gear = character.gear
        self.gearJsonModels = character.gear?.jsonModels ?? []
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
