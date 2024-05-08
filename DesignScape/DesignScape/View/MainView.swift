//
//  MainView.swift
//  DesignScape
//
//  Created by Minh Huynh on 1/28/24.
//

import SwiftUI

/// Main View of the entire app
struct MainView: View {
    
    /// Current active tab, numbered 1-5
    @State private var selectedTab = 1
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                Text("Home")
                    .tabItem {
                        Text("Home")
                        selectedTab == 1 ? Image("home.fill") : Image("home")
                    }
                    .tag(1)
                CopilotView()
                    .tabItem {
                        Text("Leo")
                        selectedTab == 2 ? Image("stars.fill") : Image("stars")
                    }.tag(2)
                CreateDesignView()
                    .tabItem {
                        Image("add")
                    }.tag(3)
                CatalogView()
                    .tabItem {
                        Text("Explore")
                        selectedTab == 4 ? Image("search.fill") : Image("search")
                    }.tag(4)
                AccountView()
                    .tabItem {
                        Text("Profile")
                        selectedTab == 5 ? Image("profile.fill") : Image("profile")
                    }.tag(5)
            }
            .navigationTitle(Text("DesignScape AR"))
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.font, Font.custom("Merriweather-Regular", size: 14))
    }
}
