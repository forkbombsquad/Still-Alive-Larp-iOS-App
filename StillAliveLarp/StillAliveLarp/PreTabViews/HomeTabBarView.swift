//
//  HomeTabBarView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/4/22.
//

import SwiftUI

struct HomeTabBarView: View {
    @ObservedObject var _dm = DataManager.shared
    
    var body: some View {
        TabView {
            HomeTabView().tabItem {
                Image("home-outline").renderingMode(.template)
                Text("Home")
            }
            RulesTabView().tabItem {
                Image("book-open-page-variant-outline").renderingMode(.template)
                Text("Rules")
            }
            CommunityTabView().tabItem {
                Image("account-group-outline").renderingMode(.template)
                Text("Community")
            }
            AccountTabView().tabItem {
                Image("account-outline").renderingMode(.template)
                Text("My Account")
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.lightGray)
    }
}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    return HomeTabBarView(_dm: dm)
}
