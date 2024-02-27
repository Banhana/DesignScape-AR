//
//  ScanRoomController.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/1/24.
//

import SwiftUI
import RoomPlan
import ARKit
import UIKit

/// Scan Room Controller in charge of capturing the room for a model
class ScanRoomController: UIViewController, RoomCaptureSessionDelegate, RoomCaptureViewDelegate, InfoViewDelegate {
    /// The only instance
    static var instance = ScanRoomController()
    var captureView: RoomCaptureView
    let sessionConfig = RoomCaptureSession.Configuration()
    
    /// A 3d model of the final result
    var finalResult: CapturedRoom?
    
    // RoomPlan: Data API
    lazy var captureSession: RoomCaptureSession = {
        let captureSession = RoomCaptureSession()
        return captureSession
    }()
    
    /// Scene View
    var sceneView: ARSCNView
    var infoView: InfoView?
    // objects
    var objectNodes: [UUID: ObjectNode]
    func infoViewDidTapCloseButton(_ infoView: InfoView, with title: String?) {
        return
    }
    
    init() {
        // objects
        print("Initializing")
        objectNodes = [UUID: ObjectNode]()
        captureView = RoomCaptureView(frame: .zero)
        sceneView = ARSCNView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 300, height: 300)))
        sceneView.layer.borderWidth = 5
        super.init(nibName: nil, bundle: nil)
        captureView.delegate = self
        captureSession.delegate = self
        setupInfoView()
        setupScene()
        startCaptureSession()
    }

    /// Initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
//        super.init(coder: coder)
    }
    
    
    private func setupInfoView() {
        let labelSize = CGSizeMake(view.bounds.width, 60)
        let pickerSize = CGSizeMake(view.bounds.width, 160)
        let statsSize = CGSizeMake(view.bounds.width, 90)
        let infoView = InfoView(pickerData: capturedRoomObjectCategoryStrings(), labelSize: labelSize, pickerSize: pickerSize, statsSize: statsSize, backgroundColor: themeBackPlaneColor, labelBackgroundColor: themeFrontPlaneColor, labelTextColor: themeTextColor)
        infoView.sizeToFit()

        var proposedViewSize = infoView.bounds.size
        proposedViewSize.height += view.safeAreaInsets.top + view.safeAreaInsets.bottom
        infoView.frame = CGRectMake(0.0, 0.5 * (view.bounds.height - proposedViewSize.height), proposedViewSize.width, proposedViewSize.height)
        infoView.layer.cornerRadius = 12
        infoView.alpha = 0.0

        infoView.delegate = self

        self.infoView = infoView

        view.addSubview(infoView)
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
        finalResult = processedResult
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

// MARK: - RoomPlan: Data API

extension ScanRoomController {
    private func setupCaptureSession() {
        captureSession.delegate = self
    }

    private func startCaptureSession() {
        captureSession.run(configuration: sessionConfig)
    }

    private func stopCaptureSession() {
        captureSession.stop()
    }
}

// MARK: - ARSCNViewDelegate
extension ScanRoomController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {}

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {}

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {}
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
//            self.updateStatusLabel()

            for (_, objectNode) in self.objectNodes {
                objectNode.updateAt(time: time)
            }
        }
    }
}

// MARK: - Scene Management

extension ScanRoomController {
    func setupScene() {
        print("setting up scene")
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }

//    func updateStatusLabel() {
//        // for testing, prioritize debug strings
//        guard debugMessage == "" else {
//            statusLabel.text = debugMessage
//            return
//        }
//
//        // next, prioritize status messages
//        guard statusMessage == "" else {
//            statusLabel.text = statusMessage
//            return
//        }
//
//        // next, prioritize session messages
//        guard sessionMessage == "" else {
//            statusLabel.text = sessionMessage
//            return
//        }
//    }
}

// MARK: - RoomCaptureSessionDelegate

extension ScanRoomController {
    private func logRoomObjects(_ room: CapturedRoom) {
        print("LOGGING ROOM OBJECTS")
        print(" -------------------- ")
        for object in room.objects {
            let uuidString = object.identifier.uuidString
            let categoryString = DesignScape.text(for: object.category)
            let position = object.transform.translation()
            let dimensions = object.dimensions
            print("object: identifier: \(uuidString), category: \(categoryString), position: \(position), dimensions: \(dimensions)")
        }
        print(" -------------------- ")
    }

    private func updateObjectNodes(with room: CapturedRoom) {
        var objectNodeKeys = Set(self.objectNodes.keys)

        for object in room.objects {
            let uuid = object.identifier

            let dimensions = object.dimensions
            let transform = object.transform
            let category = object.category
            let model = ObjectModel(dimensions: dimensions, transform: transform, category: category)

            if let objectNode = self.objectNodes[uuid] {
                objectNodeKeys.remove(uuid)
                objectNode.update(with: model)
            } else {
                let objectNode = ObjectNode(model: model, uuid: uuid)
//                objectNode.box.opacity = self.showObjectBoxesSwitch.isOn ? 1.0 : 0.0

                self.objectNodes[uuid] = objectNode
                self.sceneView.scene.rootNode.addChildNode(objectNode.box)
                self.sceneView.scene.rootNode.addChildNode(objectNode.label)
            }
        }

        // remove any object nodes that are no longer in room
        for uuid in objectNodeKeys {
            if let objectNode = self.objectNodes[uuid] {
                objectNode.cleanup()
                self.objectNodes[uuid] = nil
            }
        }
    }

    private func addObjectNodes(with room: CapturedRoom) {
        for object in room.objects {
            let uuid = object.identifier

            let dimensions = object.dimensions
            let transform = object.transform
            let category = object.category
            let model = ObjectModel(dimensions: dimensions, transform: transform, category: category)

            guard self.objectNodes[uuid] == nil else {
                print("error: there's already an object with uuid: \(uuid.uuidString)")
                return
            }
            let objectNode = ObjectNode(model: model, uuid: uuid)
//            objectNode.box.opacity = self.showObjectBoxesSwitch.isOn ? 1.0 : 0.0

            self.objectNodes[uuid] = objectNode
            self.sceneView.scene.rootNode.addChildNode(objectNode.box)
            self.sceneView.scene.rootNode.addChildNode(objectNode.label)
        }
    }

    private func removeObjectNodes(with room: CapturedRoom) {
        for object in room.objects {
            let uuid = object.identifier
            if let objectNode = self.objectNodes[uuid] {
                objectNode.cleanup()
                self.objectNodes[uuid] = nil
            }
        }
    }

    private func changeObjectNodes(with room: CapturedRoom) {
        for object in room.objects {
            let uuid = object.identifier

            let dimensions = object.dimensions
            let transform = object.transform
            let category = object.category
            let model = ObjectModel(dimensions: dimensions, transform: transform, category: category)

            guard let objectNode = self.objectNodes[uuid] else {
                print("error: there should be an object to change")
                return
            }
            objectNode.update(with: model)
        }
    }

    /// session has live snapshot / wholesale update
    func captureSession(_ session: RoomCaptureSession, didUpdate room: CapturedRoom) {
        DispatchQueue.main.async {
            print("captureSession(_:didUpdate:)")
            //self.logRoomObjects(room)
            self.updateObjectNodes(with: room)
        }
    }

    /// session has newly added surfaces and objects
    func captureSession(_ session: RoomCaptureSession, didAdd room: CapturedRoom) {
        DispatchQueue.main.async {
            print("captureSession(_:didAdd:)")
            //self.logRoomObjects(room)
            self.addObjectNodes(with: room)
        }
    }

    /// session has changed dimensions and transform properties of surfaces and objects
    func captureSession(_ session: RoomCaptureSession, didChange room: CapturedRoom) {
        DispatchQueue.main.async {
            print("captureSession(_:didChange:)")
            //self.logRoomObjects(room)
            self.changeObjectNodes(with: room)
        }
    }

    /// session has recently removed surfaces and objects
    func captureSession(_ session: RoomCaptureSession, didRemove room: CapturedRoom) {
        DispatchQueue.main.async {
            print("captureSession(_:didRemove:)")
            //self.logRoomObjects(room)
            self.removeObjectNodes(with: room)
        }
    }

    /// session has user guidance instructions
//    func captureSession(_ session: RoomCaptureSession, didProvide instruction: RoomCaptureSession.Instruction) {
//        switch instruction {
//        case .moveCloseToWall:
//            sessionMessage = "Session: Move close to wall"
//        case .moveAwayFromWall:
//            sessionMessage = "Session: Move close to wall"
//        case .slowDown:
//            sessionMessage = "Session: Slow down"
//        case .turnOnLight:
//            sessionMessage = "Session: Turn on light"
//        case .normal:
//            //sessionMessage = "Session: Normal"
//            sessionMessage = "Tap objects to explore"
//        case .lowTexture:
//            sessionMessage = "Session: low texture"
//        @unknown default:
//            sessionMessage = ""
//        }
//    }

    /// session starts with a configuration
    func captureSession(_ session: RoomCaptureSession, didStartWith configuration: RoomCaptureSession.Configuration) {
        sceneView.session = session.arSession
    }

    /// session ends with either CapturedRoom or error
    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?) {}
}

/// A SwiftUI compatible view for Scan Room View
struct ScanRoomViewRepresentable: UIViewRepresentable {
    /// Get capture view
    func makeUIView(context: Context) -> ARSCNView {
//        ScanRoomController.instance.captureView
        ScanRoomController.instance.sceneView
    }
    
    /// Update the view when needed
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
}

