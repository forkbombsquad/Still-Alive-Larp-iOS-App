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
    @State var loadingText: String = "Loading"
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
                                ProgressView().controlSize(.large).padding(.bottom, 8)
                                Text(loadingText)
                                Spacer()
                            }
                            
                        } else {
                            if let image = uiImage, let barcodeModel = OldDataManager.shared.checkinBarcodeModel {
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
            self.loadingText = "Loading Events and Player Model..."
            OldDataManager.shared.load([.events, .player]) {
                runOnMainThread {
                    if useChar {
                        self.loadingText = "Loading Character..."
                        OldDataManager.shared.load([.character]) {
                            runOnMainThread {
                                self.loadingText = "Loading Gear..."
                                OldDataManager.shared.selectedChar = OldDataManager.shared.character?.baseModel
                                OldDataManager.shared.load([.selectedCharacterGear]) {
                                    self.generateBarcode()
                                }
                            }
                        }
                        
                    } else {
                        self.generateBarcode()
                    }
                }
            }
        }
    }
    
    private func generateBarcode() {
        loadingText = "Generating Barcode..."
        if let events = OldDataManager.shared.events, let event = (events.first(where: { $0.isToday() }) ?? events.first(where: { $0.isStarted.boolValueDefaultFalse && !$0.isFinished.boolValueDefaultFalse })), let player = OldDataManager.shared.player {
            
            let char = OldDataManager.shared.character
            let gear = OldDataManager.shared.selectedCharacterGear?.first
            
            let barcode = CheckInOutBarcodeModel(player: player.barcodeModel, character: useChar ? char?.barcodeModel : nil, event: event.barcodeModel, relevantSkills: char?.getRelevantBarcodeSkills() ?? [], gear: gear)
            runOnMainThread {
                OldDataManager.shared.checkinBarcodeModel = barcode
                self.uiImage = BarcodeGenerator.generateCheckInBarcode(barcode)
                self.loading = false
                self.loadingText = ""
            }
        } else {
            AlertManager.shared.showOkAlert("Something Went Wrong!", message: "Error Generating Barcode. Please Try Again Later.") {
                self.mode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    let dm = OldDataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    dm.character = md.fullCharacters()[1]
    dm.player = md.player(id: 2)
    dm.checkinBarcodeModel = md.playerCheckInBarcodeModel(playerId: 2, characterId: 2, eventId: 2)
    return GenerateCheckInBarcodeView(_dm: dm, useChar: true, loading: false)
}

