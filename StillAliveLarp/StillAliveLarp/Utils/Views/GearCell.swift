//
//  GearCell.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/10/25.
//

import SwiftUI

// TODO
struct GearCell<Content: View>: View {
    
    var destinationView: Content?
    
    let gearJsonModel: GearJsonModel
    @State var loading: Bool
    
    init(gearJsonModel: GearJsonModel, loading: Bool = false) where Content == EmptyView {
            self.gearJsonModel = gearJsonModel
            self.loading = loading
            self.destinationView = nil
        }

    init(gearJsonModel: GearJsonModel, loading: Bool = false, @ViewBuilder content: () -> Content) {
        self.gearJsonModel = gearJsonModel
        self.loading = loading
        self.destinationView = content()
    }
    
    var body: some View {
        if !loading, let destinationView = destinationView {
            NavigationLink(destination: destinationView) {
                GearCellContent(gearJsonModel: gearJsonModel)
            }
            .buttonStyle(.plain)
        } else {
            GearCellContent(gearJsonModel: gearJsonModel)
        }
    }
}

private struct GearCellContent: View {
    
    let gearJsonModel: GearJsonModel
    
    var body: some View {
        CardView {
            VStack {
                HStack {
                    VStack {
                        Text(gearJsonModel.name)
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 16)
                        Divider()
                            .frame(height: 1)
                            .background(Color.darkGray)
                            .padding(.horizontal, 48)
                        KeyValueView(key: "Gear Type", value: gearJsonModel.gearType, showDivider: false)
                            .padding(.top, 8)
                        KeyValueView(key: "Primary Subtype", value: gearJsonModel.primarySubtype, showDivider: false)
                            .padding(.top, 8)
                        KeyValueView(key: "Secondary Subtype", value: gearJsonModel.secondarySubtype, showDivider: false)
                            .padding(.vertical, 8)
                        Divider()
                            .frame(height: 1)
                            .background(Color.darkGray)
                            .padding(.horizontal, 48)
                        Text(gearJsonModel.desc)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                            .padding([.horizontal], 16)
                            .padding(.top, 8)
                        
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

//#Preview {
//    let md = getMockData()
//    return GearCell(gearJsonModel: md.gear(characterId: 2).jsonModels!.first!, loading: false) {
//        LoadingButtonView(.constant(false), width: 55, height: 55, buttonText: "OPE", progressViewOffset: 8) {}
//    }
//}
