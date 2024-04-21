//
//  RoomView.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/16/24.
//

import SwiftUI

struct RoomLoaderView: View {
    var body: some View {
        Text("Hello, World!")
            .task {
                SceneLoader().loadScene()
            }
    }
}

#Preview {
    RoomLoaderView()
}
