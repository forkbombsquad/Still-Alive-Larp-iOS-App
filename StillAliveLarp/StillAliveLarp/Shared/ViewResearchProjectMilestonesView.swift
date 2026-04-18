//
//  ViewResearchProjectMilestonesView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/18/26.
//

import SwiftUI

struct ViewResearchProjectMilestonesView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var alertManager: AlertManager
    
    let researchProject: ResearchProjectModel
    
    @State private var currentMilestoneIndex: Int = 0
    @State private var milestones: [ResearchProjectMilestoneJsonModel] = []
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text(researchProject.name)
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        Divider()
                            .frame(height: 1)
                            .background(Color.darkGray)
                            .padding(.horizontal, 64)
                            .padding(.bottom, 8)
                        
                        KeyValueView(key: "Project Complete?", value: researchProject.complete.boolValueDefaultFalse ? "Yes" : "No", showDivider: false)
                            .padding(.top, 16)
                        
                        KeyValueView(key: "Completed Milestones", value: "\(researchProject.milestones)", showDivider: false)
                            .padding(.top, 8)
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.darkGray)
                            .padding(.horizontal, 64)
                            .padding(.vertical, 8)
                        
                        if !milestones.isEmpty {
                            Text("Milestone \(milestones[currentMilestoneIndex].id)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.top, 8)
                            
                            HStack {
                                if currentMilestoneIndex > 0 {
                                    Image(systemName: "arrow.left.circle")
                                        .font(.system(size: 44))
                                        .foregroundColor(.midRed)
                                        .padding(.top, 8)
                                        .onTapGesture {
                                            self.currentMilestoneIndex -= 1
                                        }
                                }
                                Spacer()
                                if currentMilestoneIndex < milestones.count - 1 {
                                    Image(systemName: "arrow.right.circle")
                                        .font(.system(size: 44))
                                        .foregroundColor(.midRed)
                                        .padding(.top, 8)
                                        .onTapGesture {
                                            self.currentMilestoneIndex += 1
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            
                            Text(milestones[currentMilestoneIndex].text)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .frame(alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .onAppear {
            self.milestones = researchProject.milestoneJsonModels
        }
    }
}