//
//  ObjectDetectionController.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/23/24.
//

import SwiftUI
import RoomPlan
import ARKit
import UIKit

/// Object Detection Controller in charge of recognizing objects and display its type
class ObjectDetectionController: UIViewController, RoomCaptureViewDelegate {
    /// The only instance
    static var instance = ObjectDetectionController()
    let sessionConfig = RoomCaptureSession.Configuration()

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
        sceneView = ARSCNView(frame: .zero)
        sceneView.debugOptions = .showFeaturePoints
        super.init(nibName: nil, bundle: nil)
        captureSession.delegate = self
        setupScene()
        startCaptureSession()
    }

    /// Initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Capture the room
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
        if (error == nil) {
            return true
        }
        return false
    }

}

// MARK: - RoomPlan: Data API

extension ObjectDetectionController {
    private func setupCaptureSession() {
        captureSession.delegate = self
    }

    func startCaptureSession() {
        captureSession.run(configuration: sessionConfig)
    }

    private func stopCaptureSession() {
        captureSession.stop()
    }
}

// MARK: - ARSCNViewDelegate
extension ObjectDetectionController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {}

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {}

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {}
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            for (_, objectNode) in self.objectNodes {
                objectNode.updateAt(time: time)
            }
        }
    }
}

// MARK: - Scene Management

extension ObjectDetectionController {
    func setupScene() {
        print("setting up scene")
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
}

// MARK: - RoomCaptureSessionDelegate

extension ObjectDetectionController: RoomCaptureSessionDelegate {
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

    /// session starts with a configuration
    func captureSession(_ session: RoomCaptureSession, didStartWith configuration: RoomCaptureSession.Configuration) {
        sceneView.session = session.arSession
    }

    /// session ends with either CapturedRoom or error
    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: Error?) {}
}

/// A SwiftUI compatible view for Scan Room View
struct ObjectDetectionViewRepresentable: UIViewRepresentable {
    /// Get capture view
    func makeUIView(context: Context) -> ARSCNView {
        ObjectDetectionController.instance.sceneView
    }
    
    /// Update the view when needed
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        
    }
}

