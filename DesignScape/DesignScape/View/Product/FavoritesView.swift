//
//  FavoritesView.swift
//  DesignScape
//
//  Created by Y Nguyen on 3/12/24.
//

import SwiftUI

struct FavoritesView: View {
    var body: some View {
        VStack {
            ProductBannerView()
            Spacer()
        }
        .navigationTitle("Favorites")
        .customNavBar()
        
    }
}



#Preview {
    NavigationView {
        FavoritesView()
    }
}
