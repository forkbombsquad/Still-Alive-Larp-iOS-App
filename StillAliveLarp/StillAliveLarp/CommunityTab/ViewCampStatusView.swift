//
//  ViewCampStatusView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/7/25.
//

import SwiftUI

struct ViewCampStatusView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let campStatus: CampStatusModel
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        globalCreateTitleView("Camp Status", DM: DM)
                        LazyVStack(spacing: 8) {
                            ForEach(campStatus.campFortifications.sorted(by: { $0.ring < $1.ring })) { fortification in
                                FortificationRingCell(allowOnClick: .constant(false), campFortification: fortification, onClick: nil)
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

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return ViewCampStatusView(campStatus: md.campStatus)
//}
