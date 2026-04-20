//
//  CreateNPCView.swift
//  Still Alive Larp
//

import SwiftUI

struct CreateNPCView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State var loading = false
    @State var fullName = ""
    @State var bio = ""
    @State var isHidden = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text(isHidden ? "Create Hidden NPC" : "Create NPC")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                            .padding(.bottom, 16)

                        Toggle(isOn: $isHidden) {
                            Text("Create as Hidden NPC")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .padding(.bottom, 16)

                        Text("Name")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Character Name", text: $fullName)
                            .textFieldStyling()

                        Text("Bio")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        TextField("Bio (Optional)", text: $bio)
                            .textFieldStyling()

                        LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Create \(isHidden ? "Hidden NPC" : "NPC")") {
                            createCharacter()
                        }.padding(.top, 24)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }

    private func createCharacter() {
        guard fullName.trimmingCharacters(in: .whitespaces).isNotEmpty else {
            alertManager.showOkAlert("Validation Error", message: "Name is required")
            return
        }

        loading = true
        let createModel = CreateCharacterModel(
            fullName: fullName.trimmingCharacters(in: .whitespaces),
            startDate: Date().yyyyMMddFormatted,
            isAlive: "TRUE",
            deathDate: "",
            infection: "0",
            bio: bio.trimmingCharacters(in: .whitespaces),
            approvedBio: "TRUE",
            bullets: "20",
            megas: "0",
            rivals: "0",
            rockets: "0",
            bulletCasings: "0",
            clothSupplies: "0",
            woodSupplies: "0",
            metalSupplies: "0",
            techSupplies: "0",
            medicalSupplies: "0",
            armor: CharacterModel.ArmorType.none.rawValue,
            unshakableResolveUses: "0",
            mysteriousStrangerUses: "0",
            playerId: Constants.SpecificCharacterIds.commanderDavis,
            characterTypeId: isHidden ? Constants.CharacterTypes.hidden : Constants.CharacterTypes.NPC
        )

        CharacterService.createPlannedCharacter(createModel) { newCharacter in
            runOnMainThread {
                DM.load()
                alertManager.showOkAlert("Success!", message: "\(isHidden ? "Hidden NPC" : "NPC") named \(newCharacter.fullName) created!") {
                    runOnMainThread {
                        self.mode.wrappedValue.dismiss()
                    }
                }
            }
        } failureCase: { error in
            runOnMainThread {
                self.loading = false
            }
        }
    }
}

struct HiddenNPCListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let destination: NPCListView.NPCListViewDestination

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        let npcs = DM.getAllCharacters(.hidden)
                        let living = npcs.filter({ $0.isAlive })
                        let dead = npcs.filter({ !$0.isAlive })

                        globalCreateTitleView("Hidden NPCs", DM: DM)
                        Divider().padding(.horizontal, 16).padding(.bottom, 8)

                        KeyValueView(key: "Total Living Hidden NPCs", value: "\(living.count)", showDivider: false)

                        LazyVStack(spacing: 8) {
                            ForEach(living.alphabetized) { npc in
                                NavArrowView(title: npc.fullName) { _ in
                                    switch destination {
                                    case .view:
                                        ViewNPCStuffView(npc: npc)
                                    case .manage:
                                        ManageNPCView(character: npc)
                                    }
                                }
                            }
                            ForEach(dead.alphabetized) { npc in
                                NavArrowViewRed(title: "\(npc.fullName) (Dead)") {
                                    switch destination {
                                    case .view:
                                        ViewNPCStuffView(npc: npc)
                                    case .manage:
                                        ManageNPCView(character: npc)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }
}