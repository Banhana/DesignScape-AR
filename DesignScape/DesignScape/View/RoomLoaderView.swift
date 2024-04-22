//
//  RoomView.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/16/24.
//

import SwiftUI

struct RoomLoaderView: View {
    @StateObject var sceneLoader = SceneLoader()
    var body: some View {
        if let _ = sceneLoader.scene {
            SceneView(scene: sceneLoader.scene)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
//                    self.sceneLoader.loadScene()
//                    self.sceneLoader.styleWalls()
                }
        } else {
            ProgressView()
                .onAppear() {
                    self.sceneLoader.loadScene()
                    self.sceneLoader.styleWalls()
                }
        }
    }
}

#Preview {
    RoomLoaderView()
}
