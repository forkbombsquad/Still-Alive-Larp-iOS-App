//
//  FeatureFlagCell.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/7/25.
//

import SwiftUI

// TODO redo view
struct FeatureFlagCell: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let flag: FeatureFlagModel
    
    @Binding var loading: Bool
    @State private var containerWidth: CGFloat = 0
    let onEditPress: () -> Void
    
    var body: some View {
        CardView {
            VStack {
                HStack {
                    VStack {
                        Text(flag.name)
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(flag.description)
                            .font(.system(size: 20, weight: .regular))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            Text("iOS: \(flag.isActiveIos ? "ON" : "OFF")")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: containerWidth * 0.33, alignment: .center)
                                .foregroundColor(flag.isActiveIos ? Color.darkGreen : Color.midRed)
                            Text("ANDROID: \(flag.isActiveAndroid ? "ON" : "OFF")")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: containerWidth * 0.33, alignment: .center)
                                .foregroundColor(flag.isActiveAndroid ? Color.darkGreen : Color.midRed)
                        }
                    }
                    LoadingButtonView($loading, width: containerWidth * 0.2, height: 44, buttonText: "Edit", onButtonPress: onEditPress)
                }
            }
            .padding(8)
            .background(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                containerWidth = geo.size.width
                            }
                            .onChange(of: geo.size.width) { newWidth in
                                containerWidth = newWidth
                            }
                    }
                )
        }
        .padding(.horizontal, 16)
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    return FeatureFlagCell(flag: dm.featureFlags.first!, loading: .constant(false), onEditPress: {})
//}
