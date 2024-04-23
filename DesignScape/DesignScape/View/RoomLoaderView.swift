//
//  RoomView.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/16/24.
//

import SwiftUI
import FirebaseStorage

struct RoomLoaderView: View {
    @StateObject var sceneLoader = SceneLoader()
    @State var isGeneratedFirstTime = true
    @State var isGenerating = false
    
    let fileRef: StorageReference
    
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
                        isGenerating = true
                        sceneLoader.replaceObjects(ofType: .chair, with: chairModelURL)
                        sceneLoader.replaceObjects(ofType: .table, with: tableModelURL)
                        sceneLoader.replaceObjects(ofType: .storage, with: tableModelURL)
                        sceneLoader.replaceObjects(ofType: .television, with: tableModelURL)
                        isGenerating = false
                        isGeneratedFirstTime = false
                    } label: {
                        if isGenerating {
                            ProgressView()
                        } else {
                            PrimaryButton(text: isGeneratedFirstTime ? "GENERATE" : "REGENERATE", willSpan: true)
                                .disabled(isGenerating)
                        }
                    }
                }
                .padding(20)
            }
            .customNavBar()
        } else {
            ProgressView()
                .onAppear() {
                    Task {
                        await self.sceneLoader.loadScene(from: fileRef)
                    }
                }
        }
    }
}

#Preview {
//    NavigationStack {
//        RoomLoaderView(fileRef: DataController.shared.storage.reference(withPath: "/usdz_files/33i3YtIe6TTzBx7uElHrNdbSq1z1/Room1.usdz"))
//    }
    MainView()
}
