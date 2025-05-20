//
//  ResearchProjectCell.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

import SwiftUI

struct ResearchProjectCell: View {
    
    let researchProject: ResearchProjectModel
    @Binding var loading: Bool
    let onClick: (() -> Void)?
    
    init(researchProject: ResearchProjectModel, loading: Binding<Bool>, onClick: @escaping () -> Void) {
        self.researchProject = researchProject
        self._loading = loading
        self.onClick = onClick
    }
    
    init(researchProject: ResearchProjectModel, loading: Binding<Bool>) {
        self.researchProject = researchProject
        self._loading = loading
        self.onClick = nil
    }
    
    var body: some View {
        CardView {
            VStack {
                HStack {
                    VStack {
                        Text(researchProject.name)
                            .font(.system(size: 24, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 16)
                        Divider()
                            .frame(height: 1)
                            .background(Color.darkGray)
                            .padding(.horizontal, 48)
                        KeyValueView(key: "Project Complete?", value: researchProject.complete.boolValueDefaultFalse ? "Yes" : "No", showDivider: false)
                            .padding(.top, 8)
                        KeyValueView(key: "Completed Milestones", value: "\(researchProject.milestones)", showDivider: false)
                            .padding(.top, 8)
                        Divider()
                            .frame(height: 1)
                            .background(Color.darkGray)
                            .padding(.horizontal, 48)
                        Text(researchProject.description)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                            .padding([.horizontal], 16)
                            .padding(.top, 8)
                        
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .onTapGesture {
            if !loading {
                self.onClick?()
            }
        }
    }
}

#Preview {
    let md = getMockData()
    return ResearchProjectCell(researchProject: md.researchProject(), loading: .constant(false))
}
