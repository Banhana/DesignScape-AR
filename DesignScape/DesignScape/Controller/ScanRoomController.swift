//
//  ScanRoomController.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/1/24.
//

import SwiftUI
import RoomPlan
import ARKit


/// Scan Room Controller in charge of capturing the room for a model
class ScanRoomController: RoomCaptureSessionDelegate, RoomCaptureViewDelegate, ObservableObject {
    func encode(with coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    /// The only instance
    static var instance = ScanRoomController()
    var captureView: RoomCaptureView
    let sessionConfig = RoomCaptureSession.Configuration()
    
    /// A 3d model of the final result
    var finalResult: CapturedRoom?
    
    // Setup RoomBuilder
    private var roomBuilder = RoomBuilder(options: [.beautifyObjects])
    
    // Export url
    @Published var url: URL?
    
    // Scene View to build model
    var sceneView: SCNView?
    
    /// Initializer
    init() {
        captureView = RoomCaptureView(frame: .zero)
        captureView.delegate = self
        captureView.captureSession.delegate = self
        
        // Setup scene
        sceneView = SCNView(frame: .zero)
        sceneView?.scene = SCNScene()
        sceneView?.allowsCameraControl = true
        sceneView?.autoenablesDefaultLighting = true
    }
    
    /// Capture the room
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
        if (error == nil) {
            return true
        }
        return false
    }
    
    /// Scans completed
    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
        if let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        finalResult = processedResult
        generateRoomURL()
    }
    
    func generateRoomURL(){
        print("Starting to generate URL")
        do {
            if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
               let finalResult = self.finalResult {
                let url = directory.appendingPathComponent("Room.usdz")
                try finalResult.export(to: url)
                DispatchQueue.main.async {
                    self.url = url
                    print("Successful Export URL for model")
                    print(url)
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    /// Start a session
    func startSession() {
        captureView.captureSession.run(configuration: sessionConfig)
    }
    
    /// Stops a session
    func stopSession() {
        captureView.captureSession.stop()
    }

}

/// Scan Room Controller + SCNView
extension ScanRoomController {
    
    func onModelReady() {
        guard let model = finalResult else { return }
        let walls = getAllNodes(for: model.walls,
                                length: 0.1,
                                contents: UIImage(named: "White-Marble-Diffuse"))
        walls.forEach { wallNode in
            print("Added a wall")
            let initialY = wallNode.position.y
            wallNode.opacity = 0.0
            wallNode.position.y -= Float((wallNode.geometry?.boundingBox.max.z)! - (wallNode.geometry?.boundingBox.min.z)!) // Initial position adjustment
            sceneView?.scene?.rootNode.addChildNode(wallNode)
            // Apply fade-and-float animation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.5
            wallNode.opacity = 1.0
            wallNode.position.y = initialY // Final position adjustment
            SCNTransaction.commit()
        }
//        let doors = getAllNodes(for: model.doors,
//                                length: 0.11,
//                                contents: UIImage(named: "doorTexture"))
//        doors.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
//        let windows = getAllNodes(for: model.windows,
//                                  length: 0.11,
//                                  contents: UIImage(named: "windowTexture"))
//        windows.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
//        let openings = getAllNodes(for: model.openings,
//                                   length: 0.11,
//                                   contents: UIColor.blue.withAlphaComponent(0.5))
//        openings.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
    }
    
    private func getAllNodes(for surfaces: [CapturedRoom.Surface], length: CGFloat, contents: Any?) -> [SCNNode] {
        var nodes: [SCNNode] = []
        surfaces.forEach { surface in
            let width = CGFloat(surface.dimensions.x)
            let height = CGFloat(surface.dimensions.y)
            let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
            let node = SCNNode(geometry: box)
            
            let pbrMaterial = SCNMaterial()
            pbrMaterial.diffuse.contents = contents
            pbrMaterial.metalness.contents = UIImage(named: "White-Marble-Metalness")
            pbrMaterial.normal.contents = UIImage(named: "White-Marble-Normal")
            pbrMaterial.roughness.contents = UIImage(named: "White-Marble-Normal")
            node.geometry?.materials = [pbrMaterial]
            
            node.transform = SCNMatrix4(surface.transform)
            nodes.append(node)
        }
        return nodes
    }
}

/// A SwiftUI compatible view for Model View
struct ModelViewRepresentable: UIViewRepresentable {
    
    /// Get capture view
    func makeUIView(context: Context) -> SCNView {
        ScanRoomController.instance.sceneView!
    }
    
    /// Update the view when needed
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}

/// A SwiftUI compatible view for Scan Room View
struct ScanRoomViewRepresentable: UIViewRepresentable {
    
    /// Get capture view
    func makeUIView(context: Context) -> RoomCaptureView {
        ScanRoomController.instance.captureView
    }
    
    /// Update the view when needed
    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
        
    }
}
