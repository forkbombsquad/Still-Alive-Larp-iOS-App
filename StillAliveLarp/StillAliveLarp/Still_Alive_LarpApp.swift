//
//  Still_Alive_LarpApp.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/17/22.
//

import SwiftUI

@main
struct Still_Alive_LarpApp: App {
    
    @StateObject private var alertManager = AlertManager.shared
    @StateObject private var dataManager = DataManager.shared

    var body: some Scene {
        WindowGroup {
            CustomAlertContainerView {
                MainView()
                    .environmentObject(alertManager)
                    .environmentObject(dataManager)
                    .alert(isPresented: $alertManager.isShowingAlert) {
                        alertManager.alert ?? Alert(title: Text(""))
                    }
            }
        }
    }
}
