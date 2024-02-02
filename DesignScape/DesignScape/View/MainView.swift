//
//  MainView.swift
//  DesignScape
//
//  Created by Minh Huynh on 1/28/24.
//

import SwiftUI

struct MainView: View {
    
    @State private var selectedTab = 1
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                Text("Home")
                    .tabItem {
                        Text("Home")
                        selectedTab == 1 ? Image("home.fill") : Image("home")
                    }
                    .tag(1)
                Text("Copilot")
                    .tabItem {
                        Text("Copilot")
                        selectedTab == 2 ? Image("stars.fill") : Image("stars")
                    }.tag(2)
                CreateDesignView()
                    .tabItem {
                        Image("add")
                    }.tag(3)
                Text("Search")
                    .tabItem {
                        Text("Search")
                        selectedTab == 4 ? Image("search.fill") : Image("search")
                    }.tag(4)
                Text("Profile")
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
