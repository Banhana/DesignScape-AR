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
    
    let fileRef: StorageReference
    
    //    let chairModelURL = Bundle.main.url(forResource: "bisou-accent-chair", withExtension: "usdz")
    let chairModelURL = Bundle.main.url(forResource: "cullen-shiitake-dining-chair", withExtension: "usdz")
    //    let chairModelURL = Bundle.main.url(forResource: "68809180-ec29-bd3b-ef5c-b1b41b277823", withExtension: "glb")
    let tableModelURL = Bundle.main.url(forResource: "monarch-shiitake-dining-table", withExtension: "usdz")
    //    let storageModelURL = Bundle.main.url(forResource: "501439_West Natural Cane Bar Cabinet", withExtension: "usdz")
    let storageModelURL = Bundle.main.url(forResource: "annie-whitewashed-wood-storage-bookcase-with-shelves-by-leanne-ford", withExtension: "usdz")
    let doorModelURL = Bundle.main.url(forResource: "door", withExtension: "usdz")
    let doorImage = UIImage(named: "door-white.png")
    let windowImage = UIImage(named: "window_PNG17640.png")
    let screenImage = UIImage(named: "screen.png")
    
    var body: some View {
        if let _ = sceneLoader.scene {
            ZStack {
                sceneView
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Button {
                        isGenerating = true
                        if isGeneratedFirstTime {
                            sceneView?.addLights()
                            self.isAutoEnablesDefaultLighting = false
                        }
                        sceneView?.sceneLoader.addFloor()
//                        sceneView?.sceneLoader.addCeiling()
                        sceneLoader.styleWalls()
                        sceneLoader.replaceObjects(ofType: .chair, with: chairModelURL)
                        sceneLoader.replaceObjects(ofType: .table, with: tableModelURL)
                        sceneLoader.replaceObjects(ofType: .storage, with: storageModelURL)
                        sceneLoader.replaceSurfaces(ofType: .door(isOpen: true), with: doorImage)
                        sceneLoader.replaceSurfaces(ofType: .door(isOpen: false), with: doorImage)
                        sceneLoader.replaceSurfaces(ofType: .window, with: windowImage)
                        
                        //                        sceneLoader.replaceObjects(ofType: .television, with: tableModelURL)
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
}

#Preview {
    //    NavigationStack {
    //        RoomLoaderView(fileRef: DataController.shared.storage.reference(withPath: "/usdz_files/33i3YtIe6TTzBx7uElHrNdbSq1z1/Room1.usdz"))
    //    }
    MainView()
}
