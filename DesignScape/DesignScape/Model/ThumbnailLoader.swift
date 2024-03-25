//
//  ImageLoader.swift
//  DesignScape
//
//  Created by Minh Huynh on 3/24/24.
//

import SwiftUI
import Firebase
import FirebaseStorage
import SceneKit

class ThumbnailLoader: ObservableObject {
    @Published var thumbnail: UIImage?
    @Published var sceneView: SCNView?
    private let fileRef: StorageReference
    
    init(fileRef: StorageReference) {
        self.fileRef = fileRef
    }
    
    func load() {
        // Generate thumbnail using SceneKit
        let sceneView = SCNView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 300, height: 300)))
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        
        // Create a temporary file URL
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("usdz")
        
        // Download the USDZ file to the temporary file URL
        fileRef.write(toFile: tempFileURL) { result in
            switch result {
            case .success(let url):
                // Load USDZ file URL into scene
                if let scene = try? SCNScene(url: url, options: nil) {
                    // Set camera position
                    let cameraNode = SCNNode()
                    cameraNode.camera = SCNCamera()
                    sceneView.allowsCameraControl = true
                    cameraNode.position = SCNVector3(0, 0, 15)
                    
                    // Add camera to the scene
                    scene.rootNode.addChildNode(cameraNode)
                    
                    // Render scene to generate thumbnail
                    sceneView.scene = scene
                    DispatchQueue.main.async {
                            
                            // Assign the generated thumbnail
                        self.sceneView = sceneView
                        self.thumbnail = sceneView.snapshot()
                    }
                } else {
                    print("Failed to load USDZ file")
                }
            case .failure(_):
                print("Error downloading USDZ")
            }
        }
    }
}

/// A SwiftUI compatible view for Scan Room View
struct RoomViewRepresentable: UIViewRepresentable {
    let sceneView: SCNView
    
    /// Get capture view
    func makeUIView(context: Context) -> SCNView {
        return sceneView
    }
    
    /// Update the view when needed
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}
