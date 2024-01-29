//
//  MainView.swift
//  DesignScape
//
//  Created by Minh Huynh on 1/28/24.
//

import SwiftUI

struct MainView: View {
    
    @State private var selectedTab = 1
    
    struct Tab {
        let text: String
        let imageName: String
        let tag: Int
    }
    
    let tabs: [Tab] = [
        Tab(text: "Home", imageName: "home", tag: 1),
        Tab(text: "Copilot", imageName: "stars", tag: 2),
        Tab(text: "Add", imageName: "add", tag: 3),
        Tab(text: "Search", imageName: "search", tag: 4),
        Tab(text: "Profile", imageName: "profile", tag: 5)
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs, id: \.tag) { tab in
                Text(tab.text)
                    .tabItem {
                        if !tab.text.isEmpty {
                            Text(tab.text)
                        }
                        Image(selectedTab == tab.tag ? "\(tab.imageName).fill" : tab.imageName)
                    }
                    .tag(tab.tag)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
