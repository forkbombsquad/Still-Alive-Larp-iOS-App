//
//  GenerateCheckoutBarcodeView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/27/23.
//

import SwiftUI

struct GenerateCheckoutBarcodeView: View {
    @ObservedObject var _dm = DataManager.shared

    @State var loading = false
    @State var uiImage: UIImage? = nil

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        if loading {
                            HStack {
                                Spacer()
                                ProgressView().padding(.bottom, 8)
                                Text("Loading...")
                                Spacer()
                            }
                        } else {
                            if let image = uiImage, let barcodeModel = DataManager.shared.checkoutBarcodeModel {
                                Text("Check Out\n\(barcodeModel.player.fullName)")
                                    .font(.system(size: 32, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .frame(alignment: .center)
                                    .padding([.bottom], 16)
                                KeyValueView(key: "Checking Out", value: barcodeModel.character?.fullName ?? "NPC")
                                Image(uiImage: image)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.top, 16)
                            } else {
                                Text("Error Loading Barcode")
                                    .font(.system(size: 32, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .frame(alignment: .center)
                                    .padding([.bottom], 16)
                            }
                            LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Done") {
                                DataManager.shared.load([.player, .character, .intrigue, .events], forceDownloadIfApplicable: true)
                                runOnMainThread {
                                    self.mode.wrappedValue.dismiss()
                                }
                            }
                            .padding(.top, 16)
                        }
                    }
                }
            }

        }
        .padding(16)
        .background(Color.lightGray)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.loading = true
            DataManager.shared.load([.eventAttendees]) {
                if let ea = DataManager.shared.eventAttendeesForPlayer?.first(where: { $0.isCheckedIn.boolValueDefaultFalse }) {
                    var charBarcode: CharacterBarcodeModel?
                    var relevantSkills = [SkillBarcodeModel]()

                    if (!ea.asNpc.boolValueDefaultFalse) {
                        charBarcode = DataManager.shared.character?.barcodeModel
                        relevantSkills = DataManager.shared.character?.getRelevantBarcodeSkills() ?? []
                    }

                    DataManager.shared.checkoutBarcodeModel = PlayerCheckOutBarcodeModel(player: DataManager.shared.player!.barcodeModel, character: charBarcode, eventAttendeeId: ea.id, eventId: ea.eventId, relevantSkills: relevantSkills)
                    if let bc = DataManager.shared.checkoutBarcodeModel {
                        uiImage = BarcodeGenerator.generateCheckOutBarcode(bc)
                    }
                    self.loading = false
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
    dm.character = md.fullCharacters()[1]
    dm.player = md.player(id: 2)
    dm.checkoutBarcodeModel = md.playerCheckOutBarcodeModel(playerId: 2, characterId: 2, eventAttendeeId: 2, eventId: 2)
    return GenerateCheckoutBarcodeView(_dm: dm, loading: false)
}
