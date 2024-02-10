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
    
    dynamic required init?(coder decoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(){
        self.init(frame: UIScreen.main.bounds)
        
        subscribeToActionStream()
    }
    
    // Needed when using Combine
    private var cancellables: Set<AnyCancellable> = []
    
    func subscribeToActionStream(){
        ARManager.shared.actionStream
            .sink { [weak self] action in
                switch action {
                    case .placeObject(let modelName):
                        self?.placeObject(modelName: modelName)
                    
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
        let usdzEntity = try! ModelEntity.load(named: "Furniture/" + modelName + ".usdz")
        let anchor = AnchorEntity()

        // Perform a raycast from the center of the screen.
        let screenCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        if let result = self.raycast(from: screenCenter, allowing: .estimatedPlane, alignment: .horizontal).first {
            // If the raycast hit a surface, position the anchor at that location.
            anchor.transform = Transform(matrix: result.worldTransform)
        } else {
            // If the raycast did not hit a surface, place the object in front of the camera.
            anchor.position = [0, 0, -1]
        }

        anchor.addChild(usdzEntity)
        scene.addAnchor(anchor)
    }
}
