//
//  FortificationCell.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/7/25.
//

import SwiftUI

struct FortificationCell: View {
    
    let fortification: Fortification?
    
    var body: some View {
        CardView {
            VStack {
                let empty = fortification == nil
                Text("\(empty ? "Empty" : fortification!.fortificationType.rawValue.capitalizingFirstLetterOfEachWord()) Fortification\(empty ? " Slot" : "")")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16)
                Divider()
                    .frame(height: 1)
                    .background(Color.darkGray)
                    .padding(.horizontal, 48)
                KeyValueView(key: "Health Remaining", value: "\(empty ? "0" : fortification!.health.stringValue) / \(empty ? "0" : fortification!.fortificationType.getMaxHealth().stringValue)", showDivider: false)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    let md = getMockData()
    return FortificationCell(fortification: md.campStatus.campFortifications.first!.fortifications.first!)
}



