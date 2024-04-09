//
//  ManageGearView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/30/23.
//

import SwiftUI

struct ManageGearView: View {
    @ObservedObject private var _dm = DataManager.shared

    let gear: GearModel?
    @State private var type: String
    @State private var name: String
    @State private var description: String

    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    init(gear: GearModel?) {
        self.gear = gear
        if let gear = gear {
            _type = State(initialValue: gear.type)
            _name = State(initialValue: gear.name)
            _description = State(initialValue: gear.description)
        } else {
            _type = State(initialValue: "")
            _name = State(initialValue: "")
            _description = State(initialValue: "")
        }
    }

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("\(gear == nil ? "Add" : "Edit") Gear\nFor \(DataManager.shared.selectedChar?.fullName ?? "")")
                            .font(Font.system(size: 36, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.trailing, 0)
                        TextField("Gear Type", text: $type)
                            .padding(.top, 8)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.default)
                            .padding(.trailing, 0)
                        TextField("Gear Name", text: $name)
                            .padding(.top, 8)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.default)
                            .padding(.trailing, 0)
                        TextField("Gear Description", text: $description)
                            .padding(.top, 8)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.default)
                            .padding(.trailing, 0)
                            .padding(.bottom, 16)
                        LoadingButtonView($loading, width: gr.size.width - 32, buttonText: gear == nil ? "Submit" : "Submit Changes") {
                            let valResult = validateFields()
                            if !valResult.hasError {
                                self.loading = true
                                if let gear = self.gear {
                                    // Edit
                                    let editedGear = GearModel(id: gear.id, characterId: DataManager.shared.selectedChar?.id ?? -1, type: self.type, name: self.name, description: self.description)
                                    AdminService.updateGear(gearModel: editedGear) { gearModel in
                                        self.loading = false
                                        AlertManager.shared.showSuccessAlert("\(self.name) gear edited for \(DataManager.shared.selectedChar?.fullName ?? "")") {
                                            runOnMainThread {
                                                self.mode.wrappedValue.dismiss()
                                            }
                                        }
                                    } failureCase: { error in
                                        self.loading = false
                                    }
                                } else {
                                    // Create
                                    let gear = GearCreateModel(characterId: DataManager.shared.selectedChar?.id ?? -1, type: self.type, name: self.name, description: self.description)
                                    AdminService.createGear(gear) { gearModel in
                                        self.loading = false
                                        AlertManager.shared.showSuccessAlert("\(self.name) gear created for \(DataManager.shared.selectedChar?.fullName ?? "")") {
                                            runOnMainThread {
                                                self.mode.wrappedValue.dismiss()
                                            }
                                        }
                                    } failureCase: { error in
                                        self.loading = false
                                    }
                                }
                            } else {
                                AlertManager.shared.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
                            }
                        }
                        .padding(.trailing, 0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.lightGray)
    }

    private func validateFields() -> ValidationResult {
        return Validator.validateMultiple([
            ValidationGroup(text: type, validationType: .gearType),
            ValidationGroup(text: name, validationType: .gearName),
            ValidationGroup(text: description, validationType: .gearDesc)])
    }
}
