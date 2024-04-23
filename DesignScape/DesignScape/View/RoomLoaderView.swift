//
//  RoomView.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/16/24.
//

import SwiftUI

struct RoomLoaderView: View {
    @StateObject var sceneLoader = SceneLoader()
    
    let chairModelURL = Bundle.main.url(forResource: "bisou-accent-chair", withExtension: "usdz")
    let tableModelURL = Bundle.main.url(forResource: "wells-leather-sofa", withExtension: "usdz")
    
    var body: some View {
        if let _ = sceneLoader.scene {
            ZStack {
                SceneView(scene: sceneLoader.scene)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Button {
                        sceneLoader.replaceChairs(with: chairModelURL)
                        sceneLoader.replaceTables(with: tableModelURL)
                    } label: {
                        PrimaryButton(text: "GENERATE", willSpan: true)
                    }
                }
                .padding(20)
            }
            .customNavBar()
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
    NavigationStack {
        RoomLoaderView()
    }
}
