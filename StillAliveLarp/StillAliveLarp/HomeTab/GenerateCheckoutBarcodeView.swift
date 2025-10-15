//
//  GenerateCheckoutBarcodeView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/27/23.
//

import SwiftUI

struct GenerateCheckoutBarcodeView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let player: FullPlayerModel
    let attendee: EventAttendeeModel
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        let npc = DM.characters.first(where: { $0.id == attendee.npcId })
                        let char = DM.characters.first(where: { $0.id == attendee.characterId ?? -1 })
                        let image = BarcodeGenerator.generateCheckOutBarcode(player.getCheckOutBarcodeModel(eventAttendee: attendee))
                        Text("Check Out\n\(player.fullName)")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(alignment: .center)
                            .padding([.bottom], 16)
                        KeyValueView(key: "Checking Out", value: attendee.asNpc.boolValueDefaultFalse ? "\(npc?.fullName ?? "NPC") - NPC" : "\(char?.fullName ?? "???")")
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

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return GenerateCheckoutBarcodeView(player: md.fullPlayers().first!, attendee: md.eventAttendee())
//}
