//
//  RoomView.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/16/24.
//

import SwiftUI
import FirebaseStorage
import SceneKit

struct RoomLoaderView: View {
    @StateObject var sceneLoader = SceneLoader()
    @State var scene: SCNScene?
    @State var isGeneratedFirstTime = true
    @State var isGenerating = false
    @State var sceneView: SceneView?
    @State var isAutoEnablesDefaultLighting = true
    
    var showOverlayOptions = true
    let fileRef: StorageReference
    
    //    let chairModelURL = Bundle.main.url(forResource: "bisou-accent-chair", withExtension: "usdz")
    let chairModelURL = Bundle.main.url(forResource: "cullen-shiitake-dining-chair", withExtension: "usdz")
    //    let chairModelURL = Bundle.main.url(forResource: "68809180-ec29-bd3b-ef5c-b1b41b277823", withExtension: "glb")
    let tableModelURL = Bundle.main.url(forResource: "monarch-shiitake-dining-table", withExtension: "usdz")
    //    let storageModelURL = Bundle.main.url(forResource: "501439_West Natural Cane Bar Cabinet", withExtension: "usdz")
    let storageModelURL = Bundle.main.url(forResource: "annie-whitewashed-wood-storage-bookcase-with-shelves-by-leanne-ford", withExtension: "usdz")
//    let storageModelURL = Bundle.main.url(forResource: "elias-natural-elm-wood-open-bookcase", withExtension: "usdz")
    let doorModelURL = Bundle.main.url(forResource: "door", withExtension: "usdz")
    let televisionModelURL = Bundle.main.url(forResource: "television", withExtension: "usdz")
    let doorImage = UIImage(named: "door-white.png")
    let windowImage = UIImage(named: "window_PNG17640.png")
    
    var body: some View {
        if let _ = sceneLoader.scene {
            ZStack {
                sceneView
                    .edgesIgnoringSafeArea(.all)
                if showOverlayOptions {
                    overlayOptionsView
                }
            }
            .onAppear {
                self.sceneView = SceneView(sceneLoader: sceneLoader, isAutoEnablesDefaultLighting: $isAutoEnablesDefaultLighting)
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
    
    var overlayOptionsView: some View {
        VStack {
            Spacer()
            Button {
                isGenerating = true
                if isGeneratedFirstTime {
                    sceneView?.addLights()
                    self.isAutoEnablesDefaultLighting = false
                }
                sceneView?.sceneLoader.addFloor(infinity: true)
//                        sceneView?.sceneLoader.addCeiling()
                sceneLoader.styleWalls()
                sceneLoader.replaceObjects(ofType: .chair, with: chairModelURL)
                sceneLoader.replaceObjects(ofType: .table, with: tableModelURL)
                sceneLoader.replaceObjects(ofType: .storage, with: storageModelURL, scale: 1)
                
                // Hide Doors, Windows, and TV
                sceneLoader.sceneModel?.doorsClosed?.forEach({ door in
                    door.opacity = 0
                })
                sceneLoader.sceneModel?.windows?.forEach({ window in
                    window.opacity = 0
                })
                sceneLoader.sceneModel?.televisions?.forEach({ tv in
                    tv.opacity = 0
                })
                
//                        sceneLoader.replaceSurfaces(ofType: .door(isOpen: true), with: doorImage)
//                        sceneLoader.replaceSurfaces(ofType: .door(isOpen: false), with: doorImage)
//                        sceneLoader.replaceSurfaces(ofType: .window, with: windowImage)
//                        sceneLoader.replaceObjects(ofType: .television, with: televisionModelURL, scale: 0.018, onFloorLevel: false)
                
                isGenerating = false
                isGeneratedFirstTime = false
            } label: {
                if isGenerating == true {
                    ProgressView()
                } else {
                    PrimaryButton(text: isGeneratedFirstTime ? "GENERATE" : "REGENERATE", willSpan: true)
                        .disabled(isGenerating)
                }
            }
        }
        .padding(20)
    }
}

#Preview {
    //    NavigationStack {
    //        RoomLoaderView(fileRef: DataController.shared.storage.reference(withPath: "/usdz_files/33i3YtIe6TTzBx7uElHrNdbSq1z1/Room1.usdz"))
    //    }
    MainView()
}
