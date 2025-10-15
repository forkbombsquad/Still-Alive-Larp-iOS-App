//
//  FeatureFlagCell.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/7/25.
//

import SwiftUI

struct FeatureFlagCell: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let flag: FeatureFlagModel
    let width: CGFloat
    
    @Binding var loading: Bool
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
                                .frame(width: width * 0.33, alignment: .center)
                                .foregroundColor(flag.isActiveIos ? Color.darkGreen : Color.midRed)
                            Text("ANDROID: \(flag.isActiveAndroid ? "ON" : "OFF")")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: width * 0.33, alignment: .center)
                                .foregroundColor(flag.isActiveAndroid ? Color.darkGreen : Color.midRed)
                        }
                    }
                    LoadingButtonView($loading, width: width * 0.2, height: 44, buttonText: "Edit", onButtonPress: onEditPress)
                }
            }
            .padding(8)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    let dm = DataManager.shared
    dm.setDebugMode(true)
    let mockData = getMockData()
    return FeatureFlagCell(flag: mockData.featureFlag(), width: 350, loading: .constant(false), onEditPress: {}).environmentObject(dm)
}
