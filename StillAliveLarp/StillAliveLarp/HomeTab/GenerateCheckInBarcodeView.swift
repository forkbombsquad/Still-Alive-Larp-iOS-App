//
//  GenerateCheckInBarcodeView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/20/23.
//

import SwiftUI

struct GenerateCheckInBarcodeView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let player: FullPlayerModel
    let useChar: Bool
    let event: FullEventModel

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        let image = BarcodeGenerator.generateCheckInBarcode(player.getCheckInBarcodeModel(useChar: useChar, event: event))
                        Text("Check In\n\(player.fullName)")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                            .padding([.bottom], 16)
                        KeyValueView(key: "Checking In As", value: useChar ? "\(player.getActiveCharacter()?.fullName ?? "NPC")" : "NPC")
                        Image(uiImage: image)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 16)
                        LoadingButtonView(.constant(false), width: gr.size.width - 32, buttonText: "Done") {
                            runOnMainThread {
                                DM.load()
                                self.mode.wrappedValue.dismiss()
                            }
                        }
                        .padding(.top, 16)
                        
                    }
                }
            }

        }
        .padding(16)
        .background(Color.lightGray)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return GenerateCheckInBarcodeView(player: md.fullPlayers().first!, useChar: true, event: md.fullEvents().first!)
}

