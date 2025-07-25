//
//  Still_Alive_LarpApp.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/17/22.
//

import SwiftUI

@main
struct Still_Alive_LarpApp: App {

    @StateObject var alertManager = AlertManager.shared
    @ObservedObject var dataManager = OldDataManager.shared

    var body: some Scene {
        WindowGroup {
            CustomAlertContainerView {
                MainView()
                    .environmentObject(alertManager)
                    .alert(isPresented: $alertManager.isShowingAlert) {
                        alertManager.alert ?? Alert(title: Text(""))
                    }
            }
        }
    }
}
