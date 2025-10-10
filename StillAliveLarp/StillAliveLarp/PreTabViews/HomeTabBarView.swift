//
//  HomeTabBarView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/4/22.
//

import SwiftUI

struct HomeTabBarView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    var body: some View {
        TabView {
            HomeTabView().tabItem {
                Image("home-outline").renderingMode(.template)
                Text(DM.getTitlePotentiallyOffline("Home"))
            }
            RulesTabView().tabItem {
                Image("book-open-page-variant-outline").renderingMode(.template)
                Text(DM.getTitlePotentiallyOffline("Rules"))
            }
            CommunityTabView().tabItem {
                Image("account-group-outline").renderingMode(.template)
                Text(DM.getTitlePotentiallyOffline("Community"))
            }
            AccountTabView().tabItem {
                Image("account-outline").renderingMode(.template)
                Text(DM.getTitlePotentiallyOffline("My Account"))
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.lightGray)
    }
}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    return HomeTabBarView()
//}
