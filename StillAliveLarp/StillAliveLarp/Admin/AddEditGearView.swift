//
//  AddEditGearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/11/25.
//

import SwiftUI

struct AddEditGearView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
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
                        
                        if let limit = getNewCharacterLimitString() {
                            Text("**New Character Limits**\n\(limit)")
                                .multilineTextAlignment(.center)
                                .frame(alignment: .center)
                                .padding(8)
                        }
                        
                        if let classification = getClassificationString() {
                            Text("**Classification**\n\(classification)")
                                .multilineTextAlignment(.center)
                                .frame(alignment: .center)
                                .padding(8)
                        }
                        
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
    
    private func getNewCharacterLimitString() -> String? {
        typealias gt = Constants.GearTypes
        switch type {
        case gt.meleeWeapon, gt.firearm:
            return "Up to 2 of each type you're proficient with"
        case gt.clothing:
            return "1 Mechanically Advantageous piece of Clothing\nNO LIMIT ON: regular clothing"
        case gt.accessory:
            return "2 Mechancially Advangageous Accessories (such as flashlights or holsters)\nNO LIMIT ON: non-advantageous accessories (such as safety glasses, sunglasses, belts, masks, headbands, gloves, phones, watches, etc)"
        case gt.bag:
            return "1 Small Bag and 1 of Either: 1 Large Bag or 1 Medium Bag."
        default:
            return nil
        }
    }
    
    private func getClassificationString() -> String? {
        typealias gt = Constants.GearTypes
        switch type {
        case gt.meleeWeapon:
            return "Super Light: Coreless\nLight: 22.99\" (57.3cm) or shorter\nMedium: 23\" - 43.99\" (57.4cm - 111.7cm)\nHeavy: 44\" (111.8cm) or longer"
        case gt.firearm:
            return "+1 per magazine\n+1 more than 5 bullets\n+1 more than 10 bullets\n+1 more than 15 bullets\n+1 Semi-Auto\n+2 Auto\nRivals or Rockets = Military Grade\n\nLight: 0\nMedium: 1\nHeavy: 2\nAdvanced: 3+\nMilitary Grade: Shoots Rivals or Rockets"
        case gt.clothing:
            return nil
        case gt.accessory:
            return nil
        case gt.bag:
            return "Small: 0.5L (30.5cu in) or less\nMedium: 0.5L - 5L (30.5cu in - 305.1cu in)\nLarge: 5L - 25L (305.1cu in - 1,525.6cu in)\nExtra Large: 25L (1,525.6cu in) or more"
        default:
            return nil
        }
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return AddEditGearView(gearToEdit: nil, characterName: md.character(id: 2).fullName) { _ in }
}
