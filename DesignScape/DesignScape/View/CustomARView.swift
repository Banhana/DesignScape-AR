//
//  CustomARView.swift
//  DesignScape
//
//  Created by Tony Banh on 2/1/24.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

class CustomARView: ARView{
    required init(frame frameRect: CGRect){
        super.init(frame: frameRect)
    }
    
    // Error message if error occurs
    dynamic required init?(coder decoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(){
        self.init(frame: UIScreen.main.bounds)
        
        subscribeToActionStream()
    }
    
    // Needed when using Combine
    private var cancellables: Set<AnyCancellable> = []
    
    // Controlls what action is being done in the scene
    func subscribeToActionStream(){
        ARManager.shared.actionStream
            .sink { [weak self] action in
                switch action {
                    case .placeObject(let modelName):
                        self?.placeObject(modelName: modelName) // Places the object you picked into the AR Scene
                    
                    case .removeAllAnchors:
                        self?.scene.anchors.removeAll()
                }
            }
            .store(in: &cancellables)
    }
    
    func configuration(){
        // Tracks the device relative to it's environment
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable scene reconstruction if LIDAR is supported
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            configuration.sceneReconstruction = .meshWithClassification
        }
        
        configuration.planeDetection = [.horizontal] // plane detection
        session.run(configuration)
    }
    
    func placeObject(modelName: String) {
        // Loads the model picked from the Furniture directory if it exists
        ModelEntity.loadModelAsync(named: "Furniture/" + modelName + ".usdz").sink(receiveCompletion: { _ in }, receiveValue: { usdzEntity in
            let anchor = AnchorEntity()

            // Perform a raycast from the center of the screen.
            let screenCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            if let result = self.raycast(from: screenCenter, allowing: .estimatedPlane, alignment: .horizontal).first {
                // If the raycast hit a surface, position the anchor at that location.
                anchor.transform = Transform(matrix: result.worldTransform)
            } else {
                // If no surface is detected, find the closest detected surface and place the object on it.
                if let closestPlaneResult = self.findClosestPlane() {
                    anchor.transform = Transform(matrix: closestPlaneResult.worldTransform)
                }
            }
            anchor.addChild(usdzEntity)
            self.scene.addAnchor(anchor)

            // Add gestures to the entity.
            usdzEntity.generateCollisionShapes(recursive: true)
            // .translation allows you to move the object
            // .rotation allows you to rotate the object
            // .scale allows you to change the size of the object
            self.installGestures([.translation, .rotation, .scale], for: usdzEntity)
        }).store(in: &cancellables)
    }

    func findClosestPlane() -> ARRaycastResult? {
        // Perform a raycast to find the closest detected plane.
        let raycastResults = self.raycast(from: self.center, allowing: .estimatedPlane, alignment: .horizontal)
        
        return raycastResults.min(by: { result1, result2 in
            let distance1 = simd_length(result1.worldTransform.columns.3)
            let distance2 = simd_length(result2.worldTransform.columns.3)
            return distance1 < distance2
        })
    }
}
