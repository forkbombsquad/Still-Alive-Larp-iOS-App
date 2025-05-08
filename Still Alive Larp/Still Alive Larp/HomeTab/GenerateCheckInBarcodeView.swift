//
//  GenerateCheckInBarcodeView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/20/23.
//

import SwiftUI

struct GenerateCheckInBarcodeView: View {
    @ObservedObject var _dm = DataManager.shared

    let useChar: Bool

    @State var loading: Bool = false
    @State var uiImage: UIImage? = nil

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        if loading {
                            ProgressView().padding(.bottom, 8)
                            Text("Loading...")
                        } else {
                            if let image = uiImage, let barcodeModel = DataManager.shared.checkinBarcodeModel {
                                Text("Check In\n\(barcodeModel.player.fullName)")
                                    .font(.system(size: 32, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .frame(alignment: .center)
                                    .padding([.bottom], 16)
                                KeyValueView(key: "Checking In As", value: barcodeModel.character?.fullName ?? "NPC")
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
                                runOnMainThread {
                                    NotificationCenter.default.post(name: Constants.Notifications.refreshHomescreen, object: nil)
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
            if let events = DataManager.shared.events, let event = (events.first(where: { $0.isToday() }) ?? events.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse })) {
                // TODO fix
//                DataManager.shared.checkinBarcodeModel = PlayerCheckInBarcodeModel(player: DataManager.shared.player!.barcodeModel, character: useChar ? DataManager.shared.character?.barcodeModel : nil, event: event.barcodeModel, relevantSkills: useChar ? DataManager.shared.character?.getRelevantBarcodeSkills() ?? [] : [], primaryWeapon: DataManager.shared.selectedCharacterGear?.primaryWeapon)
//                if let barcode = DataManager.shared.checkinBarcodeModel {
//                    self.uiImage = BarcodeGenerator.generateCheckInBarcode(barcode)
//                }
//                self.loading = false
            }
        }
    }
}

