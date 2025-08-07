//
//  FortificationRingCell.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/7/25.
//

import SwiftUI

struct FortificationRingCell: View {
    
    @Binding var allowOnClick: Bool
    
    let campFortification: CampFortification
    let onClick: (() -> Void)?
    
    var body: some View {
        CardView {
            VStack {
                Text("Ring \(campFortification.ring)")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16)
                Divider()
                    .frame(height: 1)
                    .background(Color.darkGray)
                    .padding(.horizontal, 48)
                KeyValueView(key: "Filled Fortification Slots", value: "\(campFortification.fortifications.count) / \(campFortification.ring)", showDivider: true)
                    .padding(.top, 8)
                LazyVStack(spacing: 8) {
                    ForEach(campFortification.fortifications) { fortification in
                        FortificationCell(fortification: fortification)
                    }
                    let missingCount = campFortification.ring - campFortification.fortifications.count
                    if missingCount > 0 {
                        ForEach(0..<missingCount, id: \.self) { _ in
                            FortificationCell(fortification: nil)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .onTapGesture {
            if allowOnClick {
                self.onClick?()
            }
        }
    }
}

#Preview {
    let md = getMockData()
    return FortificationRingCell(allowOnClick: .constant(false), campFortification: md.campStatus.campFortifications.first!, onClick: nil)
}

