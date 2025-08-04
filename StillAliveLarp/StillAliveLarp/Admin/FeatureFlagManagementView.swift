//
//  FeatureFlagManagementView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/7/25.
//

import SwiftUI

struct FeatureFlagManagementView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    @Binding var featureFlags: [FeatureFlagModel]
    @State var loading: Bool = false
    
    @State var flagName: String = ""
    @State var flagDesc: String = ""
    @State var activeiOS: Bool = false
    @State var activeAndroid: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("Feature Flag Management")
                        .font(.system(size: 32, weight: .bold))
                        .frame(alignment: .center)
                    LazyVStack(spacing: 8) {
                        ArrowViewButtonGreen(title: "Add New", loading: $loading) {
                            loading = true
                            flagName = ""
                            flagDesc = ""
                            activeiOS = false
                            activeAndroid = false
                            AlertManager.shared.showDynamicAlert(model: CustomAlertModel(title: "Edit Feature Flag", textFields: [
                                AlertTextField(placeholder: "Flag Name", value: $flagName),
                                AlertTextField(placeholder: "Flag Description", value: $flagDesc, isMultiline: true)
                                ], checkboxes: [
                                    AlertToggle(text: "Active on iOS", isOn: $activeiOS),
                                    AlertToggle(text: "Active on Android", isOn: $activeAndroid)
                                ], verticalButtons: [], buttons: [
                                    AlertButton(title: "Save", role: nil, onPress: {
                                        self.createNewFlag()
                                    }),
                                    AlertButton(title: "Cancel", role: .cancel, onPress: {
                                        AlertManager.shared.dismissDynamicAlert()
                                        loading = false
                                    })
                                ]))
                        }
                        ForEach($featureFlags) { flag in
                            HStack {
                                FeatureFlagCell(flag: flag.wrappedValue, loading: $loading, onEditPress: {
                                    loading = true
                                    flagName = flag.wrappedValue.name
                                    flagDesc = flag.wrappedValue.description
                                    activeiOS = flag.wrappedValue.isActiveIos
                                    activeAndroid = flag.wrappedValue.isActiveAndroid
                                    AlertManager.shared.showDynamicAlert(model: CustomAlertModel(title: "Edit Feature Flag", textFields: [
                                        AlertTextField(placeholder: "Flag Name", value: $flagName),
                                        AlertTextField(placeholder: "Flag Description", value: $flagDesc, isMultiline: true)
                                        ], checkboxes: [
                                            AlertToggle(text: "Active on iOS", isOn: $activeiOS),
                                            AlertToggle(text: "Active on Android", isOn: $activeAndroid)
                                        ], verticalButtons: [], buttons: [
                                            AlertButton(title: "Update", role: nil, onPress: {
                                                self.updateFlag(flag.wrappedValue.id)
                                            }),
                                            AlertButton(title: "Delete", role: .destructive, onPress: {
                                                self.deleteFlag(flag.wrappedValue.id)
                                            }),
                                            AlertButton(title: "Cancel", role: .cancel, onPress: {
                                                AlertManager.shared.dismissDynamicAlert()
                                                loading = false
                                            })
                                        ]))
                                    })
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.lightGray)
    }
    
    private func createNewFlag() {
        let flag = FeatureFlagCreateModel(name: flagName, description: flagDesc, activeAndroid: activeAndroid.stringValue, activeIos: activeiOS.stringValue)
        AdminService.createFeatureFlag(flag) { _ in
            self.reload()
        } failureCase: { error in
            self.loading = false
        }
    }
    
    private func updateFlag(_ id: Int) {
        let flag = FeatureFlagModel(id: id, name: flagName, description: flagDesc, activeAndroid: activeAndroid.stringValue, activeIos: activeiOS.stringValue)
        AdminService.updateFeatureFlag(featureFlagModel: flag) { _ in
            self.reload()
        } failureCase: { error in
            self.loading = false
        }
    }
    
    private func deleteFlag(_ id: Int) {
        AdminService.deleteFeatureFlag(featureFlagId: id) { featureFlagModel in
            self.reload()
        } failureCase: { error in
            self.loading = false
        }

    }
    
    private func reload() {
        OldDM.load([.featureFlags], forceDownloadIfApplicable: true) {
            self.loading = false
        }
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return FeatureFlagManagementView(_dm: dm, featureFlags: .constant(md.featureFlagList.results))
}
