//
//  AllResearchProjectsListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

import SwiftUI

struct AllResearchProjectsListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @State var researchProjects: [ResearchProjectModel]
    @State var loading = false
    let allowEdit: Bool
    
    @State var projectName: String = ""
    @State var projectDesc: String = ""
    @State var projectMilestones: String = ""
    @State var projectComplete: Bool = false
    
    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Research Projects")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                        if loading {
                            LoadingBlock()
                        } else {
                            if allowEdit {
                                ArrowViewButtonGreen(title: "Add New", loading: self.$loading) {
                                    if !self.loading {
                                        self.displayProjectMessage(nil)
                                    }
                                }
                            }
                            LazyVStack(spacing: 8) {
                                ForEach(researchProjects) { rp in
                                    ResearchProjectCell(researchProject: rp, loading: self.$loading) {
                                        if self.allowEdit && !self.loading {
                                            self.displayProjectMessage(rp)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
        .navigationBarBackButtonHidden(true)
        .toolbar { // Custom back button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if self.loading {
                        AlertManager.shared.showOkAlert("Unsaved Changes!", message: "Your changes are still loading, please wait for them to finish!") { }
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    private func displayProjectMessage(_ rp: ResearchProjectModel?) {
        runOnMainThread {
            self.loading = true
            if let rp = rp {
                self.projectName = rp.name
                self.projectDesc = rp.description
                self.projectMilestones = rp.milestones.stringValue
                self.projectComplete = rp.complete.boolValueDefaultFalse
            } else {
                self.projectName = ""
                self.projectDesc = ""
                self.projectMilestones = ""
                self.projectComplete = false
            }
            let rpIsNil = rp == nil
            AlertManager.shared.showDynamicAlert(model: CustomAlertModel(
                title: "\(rpIsNil ? "Create" : "Edit") Research Project",
                textFields: [
                    AlertTextField(placeholder: "Project Name", value: self.$projectName),
                    AlertTextField(placeholder: "Completed Milestones", value: self.$projectMilestones),
                    AlertTextField(placeholder: "Project Description", value: self.$projectDesc, isMultiline: true)
                ],
                checkboxes: [
                    AlertToggle(text: "Is Complete?", isOn: self.$projectComplete)
                ],
                verticalButtons: [],
                buttons: [
                    AlertButton(title: rpIsNil ? "Create" : "Update", onPress: {
                        if let rp = rp {
                            // Edit
                            let editedRp = ResearchProjectModel(id: rp.id, name: self.projectName, description: self.projectDesc, milestones: self.projectMilestones.intValueDefaultZero, complete: self.projectComplete.stringValue.uppercased())
                            AdminService.updateResearchProject(editedRp) { researchProjectModel in
                                self.updateLocalAndDataManagerResearchProjects(researchProjectModel)
                            } failureCase: { error in
                                runOnMainThread {
                                    self.loading = false
                                }
                            }

                        } else {
                            // Create
                            let newRP = ResearchProjectCreateModel(name: self.projectName, description: self.projectDesc, milestones: self.projectMilestones.intValueDefaultZero, complete: self.projectComplete.stringValue.uppercased())
                            AdminService.createResearchProject(newRP) { researchProjectModel in
                                self.updateLocalAndDataManagerResearchProjects(researchProjectModel)
                            } failureCase: { error in
                                runOnMainThread {
                                    self.loading = false
                                }
                            }

                        }
                    }),
                    AlertButton.cancel {
                        runOnMainThread {
                            self.loading = false
                        }
                    }
                ])
            )
        }
    }
    
    private func updateLocalAndDataManagerResearchProjects(_ rp: ResearchProjectModel) {
        runOnMainThread {
            self.researchProjects.removeAll(where: { $0.id == rp.id })
            self.researchProjects.append(rp)
            OldDM.researchProjects = self.researchProjects
            self.loading = false
        }
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return AllResearchProjectsListView(_dm: dm, researchProjects: md.researchProjects.researchProjects, allowEdit: false)
}
