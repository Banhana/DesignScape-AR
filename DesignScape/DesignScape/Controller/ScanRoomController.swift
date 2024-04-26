//
//  ScanRoomController.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/1/24.
//

import SwiftUI
import RoomPlan
import FirebaseStorage
import SceneKit


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
        sceneView?.scene?.rootNode.castsShadow = true
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
    }
    
    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: (Error)?) {
        if let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        generateRoomURL(with: data)
    }
    
    func generateRoomURL(with captureRoomData: CapturedRoomData){
        print("Starting to generate URL")
        // Export to file and share
        Task {
            if let finalRoom = try? await roomBuilder.capturedRoom(from: captureRoomData) {
                if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let url = directory.appendingPathComponent("Room.usdz")
                    try finalRoom.export(to: url)
                    self.url = url
                    print("Successful Export URL for model")
                    print(url)
                    uploadUSDZFile(fileURL: url)
                }
            }
        }
    }
    
    func uploadUSDZFile(fileURL: URL) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var usdzFiles: [StorageReference] = []
        do {
            let authDataResult = try AuthenticationController.shared.getAuthenticatedUser()
            UserManager.shared.fetchRooms { files in
                usdzFiles = files
                let fileUrl = "usdz_files/\(authDataResult.uid)/Room\(usdzFiles.count + 1)"
                let fileRef = storageRef.child(fileUrl)
                
                // Upload the file to the path "usdz_files/Room.usdz"
                _ = fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
                    guard error == nil else {
                        // Handle error
                        print("Error uploading file: \(error!)")
                        return
                    }
                    // File uploaded successfully
                    print("USDZ file uploaded successfully")
                    
                    // Add to user's rooms
                    Task {
                        do {
                            let authDataResult = try AuthenticationController.shared.getAuthenticatedUser()
                            try await UserManager.shared.addToRooms(userId: authDataResult.uid, fileRef: fileUrl)
                        } catch {
                            print("Error")
                        }
                    }
                }
            }
        } catch {
            print("Error")
        }
        
    }
    
    
    /// Start a session
    func startSession() {
        captureView.captureSession.run(configuration: sessionConfig)
    }
    
    /// Stops a session
    func stopSession() {
        captureView.captureSession.stop()
        print("Subviews \( captureView.subviews)")
    }
    
}

/// Scan Room Controller + SCNView
extension ScanRoomController {
    
    func onModelReady() {
        sceneView?.scene = SCNScene()
        sceneView?.scene?.rootNode.castsShadow = true
        guard let model = finalResult else { return }
        let walls = getAllNodes(for: model.walls,
                                length: 0.1,
                                contents: UIImage(named: "White-Marble-Diffuse"))
        walls.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let doors = getAllNodes(for: model.doors,
                                length: 0.1,
                                contents: UIImage(named: "doorTexture"))
        doors.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let windows = getAllNodes(for: model.windows,
                                  length: 0.1,
                                  contents: UIImage(named: "windowTexture"))
        windows.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let openings = getAllNodes(for: model.openings,
                                   length: 0.1,
                                   contents: UIColor.blue.withAlphaComponent(0.5))
        openings.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        let tables = getAllNodes(for: model.objects, contents: UIImage(named: "windowTexture"))
        tables.forEach { sceneView?.scene?.rootNode.addChildNode($0) }
        exportScene(sceneView?.scene)
    }
    
    private func getAllNodes(for surfaces: [CapturedRoom.Surface], length: CGFloat, contents: Any?) -> [SCNNode] {
        var nodes: [SCNNode] = []
        var name = ""
        switch surfaces.first?.category {
        case .door(isOpen: false):
            name = "DoorClosed"
        case .door(isOpen: true):
            name = "DoorOpened"
        case .floor:
            name = "Floor"
        case .window:
            name = "Window"
        case .opening:
            name = "Opening"
        case .wall:
            name = "Wall"
        default:
            name = "Unknown"
        }
        surfaces.enumerated().forEach { index, surface in
            let width = CGFloat(surface.dimensions.x)
            let height = CGFloat(surface.dimensions.y)
            let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
            let node = SCNNode(geometry: box)
            node.name = "\(name)\(index)"
            print(node.name)
            
            node.transform = SCNMatrix4(surface.transform)
            nodes.append(node)
        }
        return nodes
    }
    
    private func getAllNodes(for objects: [CapturedRoom.Object], contents: Any?) -> [SCNNode] {
        var nodes: [SCNNode] = []
        var name = ""
        if let category = objects.first?.category {
            name = SceneModel.getName(forCategory: category)
        }
        
//        switch objects.first?.category.description {
//        case .
//        }
        objects.enumerated().forEach { index, object in
            let width = CGFloat(object.dimensions.x)
            let height = CGFloat(object.dimensions.y)
            let length = CGFloat(object.dimensions.z)
            let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
                        let node = SCNNode(geometry: box)
                        node.name = "\(name)\(index)"
                        print(node.name)
            
                        node.transform = SCNMatrix4(object.transform)
                        nodes.append(node)
        }
        return nodes
    }
    
    
    func exportScene(_ scene: SCNScene?){
        if let scene = scene{
            print("Starting to generate URL")
            
            // Create a URL to save the scene to
            if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let sceneURL = directory.appendingPathComponent("Room.usdz")
                
                // Export the scene to the URL
                scene.write(to: sceneURL, delegate: nil)
                uploadUSDZFile(fileURL: sceneURL)
                print("Scene exported to \(sceneURL.path)")
            } else {
                print("Scene is nil, cannot export")
            }
        }
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
