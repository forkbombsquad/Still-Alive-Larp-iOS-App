//
//  AddEditGearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/11/25.
//

import SwiftUI

struct AddEditGearView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @ObservedObject var _dm = DataManager.shared
    
    let gearToEdit: GearJsonModel?
    let characterName: String
    
    @State var gearName = ""
    @State var type = Constants.GearTypes.firearm
    @State var primarySubtype = Constants.GearPrimarySubtype.lightFirearm
    @State var secondarySubtype = Constants.GearSecondarySubtype.none
    
    @State var types = Constants.GearTypes.allTypes
    @State var primarySubtypes = Constants.GearPrimarySubtype.allFirearmTypes
    @State var secondarySubtypes = Constants.GearSecondarySubtype.allFirearmTypes
    
    @State var desc = ""
    
    @State var loading = false
    
    let onCompletion: (_ gear: GearJsonModel?) -> Void
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("\(gearToEdit == nil ? "Add" : "Edit") Gear For\n\(characterName)")
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                        TextField("", text: $gearName)
                            .padding(.top, 8)
                            .padding(.trailing, 0)
                            .textFieldStyle(.roundedBorder)
                            .placeholder(when: gearName.isEmpty) {
                                Text("Gear Name")
                                    .foregroundColor(.gray).padding().padding(.top, 4)
                            }
                        StyledPickerView(title: .constant("Type"), selection: $type, options: $types) { _ in
                            calculatePrimarySubtypes()
                            calculateSecondarySubtypes()
                        }
                        StyledPickerView(title: .constant("Primary Subtype"), selection: $primarySubtype, options: $primarySubtypes) { _ in
                            calculateSecondarySubtypes()
                        }
                        StyledPickerView(title: .constant("Secondary Subtype"), selection: $secondarySubtype, options: $secondarySubtypes) { _ in }
                        
                        TextEditor(text: $desc)
                            .padding(.top, 8)
                            .padding(.trailing, 0)
                            .textFieldStyle(.roundedBorder)
                            .frame(minHeight: 150)
                            .fixedSize(horizontal: false, vertical: true)
                            .placeholder(when: desc.isEmpty) {
                                Text("Description").foregroundColor(.gray).padding().multilineTextAlignment(.center)
                            }
                        LoadingButtonView($loading, width: gr.size.width - 16, buttonText: "\(gearToEdit == nil ? "Create" : "Update")") {
                            onCompletion(GearJsonModel(name: gearName, gearType: type, primarySubtype: primarySubtype, secondarySubtype: secondarySubtype, desc: desc))
                            self.mode.wrappedValue.dismiss()
                        }
                        if gearToEdit != nil {
                            LoadingButtonView($loading, width: gr.size.width - 16, buttonText: "Delete") {
                                onCompletion(nil)
                                self.mode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .onAppear {
            if let gear = gearToEdit {
                runOnMainThread {
                    self.gearName = gear.name
                    self.type = gear.gearType
                    self.primarySubtype = gear.primarySubtype
                    self.secondarySubtype = gear.secondarySubtype
                    self.desc = gear.desc
                }
            }
        }
    }
    
    private func calculatePrimarySubtypes() {
        runOnMainThread {
            typealias gt = Constants.GearTypes
            typealias ps = Constants.GearPrimarySubtype
            switch type {
                case gt.meleeWeapon:
                    primarySubtypes = ps.allMeleeTypes
                case gt.firearm:
                    primarySubtypes = ps.allFirearmTypes
                case gt.clothing:
                    primarySubtypes = ps.allClothingTypes
                case gt.accessory:
                    primarySubtypes = ps.allAccessoryTypes
                case gt.bag:
                    primarySubtypes = ps.allBagTypes
                case gt.other:
                    primarySubtypes = ps.allOtherTypes
                default:
                    primarySubtypes = ps.allFirearmTypes
            }
            primarySubtype = primarySubtypes[0]
        }
    }
    
    private func calculateSecondarySubtypes() {
        runOnMainThread {
            typealias gt = Constants.GearTypes
            typealias ss = Constants.GearSecondarySubtype
            switch type {
                case gt.firearm:
                    secondarySubtypes = ss.allFirearmTypes
                default:
                    secondarySubtypes = ss.allNonFirearmTypes
            }
            secondarySubtype = secondarySubtypes[0]
        }
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return AddEditGearView(_dm: dm, gearToEdit: nil, characterName: md.character(id: 2).fullName) { _ in }
}
