//
//  AddEditGearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/11/25.
//

import SwiftUI

struct AddEditGearView: View {
    
    @ObservedObject var _dm = DataManager.shared
    
    @Binding var gearToEdit: GearJsonModel?
    let character: CharacterModel
    
    @State var gearName = ""
    @State var type = Constants.GearTypes.firearm
    @State var primarySubtype = Constants.GearPrimarySubtype.lightFirearm
    @State var secondarySubtype = Constants.GearSecondarySubtype.none
    @State var desc = ""
    
    @State var loading = false
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("\(gearToEdit == nil ? "Add" : "Edit") Gear For\n\(character.fullName)")
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
                        // TODO add the rest of these
                        HStack {
                            Text("Type: ")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.horizontal, 8)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker(selection: $type, label: Text("Gear Type").font(.system(size: 28, weight: .bold))) {
                                ForEach(Constants.GearTypes.allTypes, id: \.self) { type in
                                    Text(type).font(.system(size: 28, weight: .bold))
                                }
                            }
                        }
                        .pickerStyle(.menu)
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
                            // TODO create/update gear
                        }
                        if gearToEdit != nil {
                            LoadingButtonView($loading, width: gr.size.width - 16, buttonText: "Delete") {
                                // TODO delete gear
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
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return AddEditGearView(_dm: dm, gearToEdit: .constant(nil), character: md.character(id: 2))
}
