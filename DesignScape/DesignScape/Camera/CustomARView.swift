//
//  CustomARView.swift
//  DesignScape
//
//  Created by Tony Banh on 2/1/24.
//

import ARKit
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
        
        placeBlueBlock()
    }
    
    func configuration(){
        // Tracks the device relative to it's environment
        let configuration = ARWorldTrackingConfiguration()
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
        if let usdzEntity = try? Entity.load(named: "usdzFileName"){
            let anchor = AnchorEntity()
            anchor.addChild(usdzEntity)
        }
        
        // Load an entity from a reality file
        if let realityEntity = try? Entity.load(named: "realityFileName"){
            let anchor = AnchorEntity()
            anchor.addChild(realityEntity)
        }
    }
    
    func placeBlueBlock(){
        let block = MeshResource.generateBox(size: 1)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        let entity = ModelEntity(mesh: block, materials: [material])
        
        let anchor = AnchorEntity()
        anchor.addChild(entity)
        
        scene.addAnchor(anchor)
    }
}
