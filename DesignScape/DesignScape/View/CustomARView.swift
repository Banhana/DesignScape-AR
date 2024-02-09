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
                    case .placeObject(let color):
                        self?.placeObject(ofColor: color)
                    
                    case .removeAllAnchors:
                        self?.scene.anchors.removeAll()
                    
                }
            }
            .store(in: &cancellables)
    }
    
    func configuration(){
        // Tracks the device relative to it's environment
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal] // plane detection
        session.run(configuration)
    }
    
    func anchor(){
        // Attach anchors at specfic coordinates in the iPhone-centered coordinate system
        let _ = AnchorEntity(world: .zero)
        
        // Attach anchors to detected planes (Best used on devices with LIDAR sensor)
        let _ = AnchorEntity()
        let _ = AnchorEntity()
    }
    
    func entity(){
        // Load an entity from a usdz file
        if let usdzEntity = try? Entity.load(named: "chair_swan.usdz"){
            let anchor = AnchorEntity()
            anchor.addChild(usdzEntity)
        }
        
        // Load an entity from a reality file
        if let realityEntity = try? Entity.load(named: "realityFileName"){
            let anchor = AnchorEntity()
            anchor.addChild(realityEntity)
        }
    }
    
    func placeObject(ofColor color: Color){
//        let block = MeshResource.generateBox(size: 1)
//        let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
//        let entity = ModelEntity(mesh: block, materials: [material])
//        
//        let anchor = AnchorEntity(plane: .horizontal, minimumBounds:[0.7, 0.7])
//        anchor.addChild(entity)
        
        let usdzEntity = try! ModelEntity.load(named: "Furniture/chair_swan.usdz")
        let anchor = AnchorEntity()
        anchor.addChild(usdzEntity)
        anchor.position = [0, 0, -1]
        
        scene.addAnchor(anchor)
    }
}
