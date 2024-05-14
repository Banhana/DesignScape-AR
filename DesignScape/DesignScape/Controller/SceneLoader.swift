//
//  SceneLoader.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/16/24.
//

import SwiftUI
import SceneKit
import RealityKit
import RoomPlan
import FirebaseStorage

/// A SceneLoader to load any scene
class SceneLoader: ObservableObject {
    
    /// Setup
    @Published var scene: SCNScene? // The only scene
    @Published var sceneModel: SceneModel? // The scene model associate with the scene
    @Published var isAutoenablesDefaultLighting = true
    
    private lazy var rootNode = scene?.rootNode // Root node of the scene
    private var groundLevel: Float = 0.0 // Ground level of the scene
    
    /// Load the scene
    func loadScene(from fileRef: StorageReference) async {
        let sceneURL = try? await UserManager.shared.downloadRoomAsync(fileRef: fileRef)
        
        guard let sceneURL = sceneURL, let scene = try? SCNScene(url: sceneURL, options: nil) else {
            return
        }
        // Do not async this so that the below code is execute after this line
        DispatchQueue.main.async {
            self.scene = scene
            // Access the root node of the scene
            let rootNode = scene.rootNode
            
            self.groundLevel = self.findLowestYCoordinate(in: rootNode)
            
            let bathtubNodes = self.findNodes(withNamePrefix: "Bathtub", in: rootNode)
            let bedNodes = self.findNodes(withNamePrefix: "Bed", in: rootNode)
            let chairNodes = self.findNodes(withNamePrefix: "Chair", in: rootNode)
            let dishwasherNodes = self.findNodes(withNamePrefix: "Dishwasher", in: rootNode)
            let fireplaceNodes = self.findNodes(withNamePrefix: "Fireplace", in: rootNode)
            let ovenNodes = self.findNodes(withNamePrefix: "Oven", in: rootNode)
            let refrigeratorNodes = self.findNodes(withNamePrefix: "Refrigerator", in: rootNode)
            let sinkNodes = self.findNodes(withNamePrefix: "Sink", in: rootNode)
            let sofaNodes = self.findNodes(withNamePrefix: "Sofa", in: rootNode)
            let stairsNodes = self.findNodes(withNamePrefix: "Stairs", in: rootNode)
            let storageNodes = self.findNodes(withNamePrefix: "Storage", in: rootNode)
            let stoveNodes = self.findNodes(withNamePrefix: "Stove", in: rootNode)
            let tableNodes = self.findNodes(withNamePrefix: "Table", in: rootNode)
            let televisionNodes = self.findNodes(withNamePrefix: "Television", in: rootNode)
            let toiletNodes = self.findNodes(withNamePrefix: "Toilet", in: rootNode)
            let washerDryerNodes = self.findNodes(withNamePrefix: "WasherDryer", in: rootNode)
            let wallsNodes = self.findNodes(withNamePrefix: "Wall", in: rootNode)
            let doorClosedNodes = self.findNodes(withNamePrefix: "DoorClosed", in: rootNode)
            let doorOpenedNodes = self.findNodes(withNamePrefix: "DoorOpened", in: rootNode)
            let windowNodes = self.findNodes(withNamePrefix: "Window", in: rootNode)
            
            self.sceneModel = SceneModel(
                bathtubs: bathtubNodes,
                beds: bedNodes,
                chairs: chairNodes,
                dishwashers: dishwasherNodes,
                fireplaces: fireplaceNodes,
                ovens: ovenNodes,
                refridgerator: refrigeratorNodes,
                sinks: sinkNodes,
                sofas: sofaNodes,
                stairs: stairsNodes,
                storages: storageNodes,
                stoves: stoveNodes,
                tables: tableNodes,
                televisions: televisionNodes,
                toilets: toiletNodes,
                washerDryers: washerDryerNodes,
                walls: wallsNodes,
                windows: windowNodes,
                doorsClosed: doorClosedNodes,
                doorsOpened: doorOpenedNodes
            )
            print("Scene Loaded")
        }
    }
    
    /// Add floor to the scene with animation
    func addFloor(infinity: Bool = false, from resource: MaterialResource) {
        guard let roomNode = scene?.rootNode.childNodes.first else {
            print("Cannot add floor")
            return
        }
        let boundingBox = roomNode.boundingBox
        
        // Floor Geometry
        let floorGeometry = SCNFloor()
        floorGeometry.reflectivity = 0.05
        floorGeometry.reflectionFalloffEnd = 0.8
        
        // Floor Material
        let floorMaterial = SCNMaterial()
        if let diffuse = resource.diffuse {
            floorMaterial.diffuse.contents = diffuse
            floorMaterial.diffuse.wrapS = .repeat
            floorMaterial.diffuse.wrapT = .repeat
        }
        if let normal = resource.normal {
            floorMaterial.normal.contents = normal
        }
        floorMaterial.lightingModel = .physicallyBased
        
        floorGeometry.materials = [floorMaterial]
        print("Root \(String(describing: scene?.rootNode.childNodes.first))")
        print("Bounding box \(boundingBox)")
        if !infinity {
            floorGeometry.width = CGFloat(boundingBox.max.x - boundingBox.min.x) / 2
            floorGeometry.length = CGFloat(boundingBox.max.z - boundingBox.min.z) / 2
        }
        
        /// Animation
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position.y = -20
        floorNode.opacity = 0
        floorNode.name = "Floor"
        floorNode.scale = SCNVector3(0.1, 0.1, 0.1)
        sceneModel?.floors?.append(floorNode)
        
        DispatchQueue.main.async {
            self.rootNode?.addChildNode(floorNode)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2
            floorNode.opacity = 0.99 // 1 cause render issue for fading action for unknown reason
            floorNode.position.y = self.groundLevel // Position the floor at the lowest Y-coordinate
            SCNTransaction.commit()
            
            // Use rotation of the wall to rotate the room
            if let wallRotation = self.sceneModel?.walls?.first?.simdRotation {
                floorNode.simdRotation = wallRotation
            }
        }
        
    }
    
    /// Add ceiling to the scene
    func addCeiling() {
        guard let roomNode = scene?.rootNode.childNodes.first else {
            print("Cannot add ceiling")
            return
        }
        let boundingBox = roomNode.boundingBox
        
        let ceilingGeometry = SCNPlane(width: CGFloat(boundingBox.max.x - boundingBox.min.x), height: CGFloat(boundingBox.max.z - boundingBox.min.z))
        let ceilingMaterial = SCNMaterial()
        //        ceilingMaterial.diffuse.contents = .
        ceilingGeometry.materials = [ceilingMaterial]
        
        let ceilingNode = SCNNode(geometry: ceilingGeometry)
        ceilingNode.position.y = self.groundLevel + boundingBox.max.y - boundingBox.min.y // Position the ceiling 2.5 units above the ground level
        ceilingNode.opacity = 0
        self.rootNode?.addChildNode(ceilingNode)
        
        let animationTime = Double.random(in: 2...3.0)
        let fadeIn = SCNAction.fadeIn(duration: animationTime)
        ceilingNode.runAction(fadeIn)
        // Use rotation of the wall to rotate the room
        if let wallRotation = self.sceneModel?.walls?.first?.simdRotation {
            ceilingNode.simdRotation = wallRotation
        }
        ceilingNode.eulerAngles.x = .pi / 2
    }
    
    /// Style a node with a MaterialResource
    func styleNode(node: SCNNode, with resource: MaterialResource) {
        let pbrMaterial = SCNMaterial()
        if let diffuseImage = resource.diffuse {
            pbrMaterial.diffuse.contents = diffuseImage
        }
        if  let metalnessImage = resource.metalness {
            pbrMaterial.metalness.contents = metalnessImage
        }
        if let normalImage = resource.normal {
            pbrMaterial.normal.contents = normalImage
        }
        if let roughnessImage = resource.roughness {
            pbrMaterial.roughness.contents = roughnessImage
        }
        if let glossImage = resource.gloss {
            pbrMaterial.specular.contents = glossImage
        }
        if let reflectionImage = resource.reflection {
            pbrMaterial.reflective.contents = reflectionImage
        }
        pbrMaterial.lightingModel = .physicallyBased
        
        DispatchQueue.main.async {
            node.geometry?.materials = [pbrMaterial]
        }
    }
    
    /// Find lowest Y Coordinate in the scene
    func findLowestYCoordinate(in rootNode: SCNNode) -> Float {
        var lowestY: Float = Float.greatestFiniteMagnitude
        // Finding the lowest of all object gives false value (Walls bounding box is lower than expected), therefore only find the bounding box of Room node
        rootNode.childNodes.forEach { node in
            let boundingBox = node.boundingBox
            lowestY = min(lowestY, boundingBox.min.y)
        }
        return lowestY
    }
    
    /// Style all the walls
    func styleWalls(with resource: MaterialResource) {
        sceneModel?.walls?.forEach({ wall in
            styleNode(node: wall, with: resource)
        })
    }
    
    /// Replace all objects with given model url
    func replaceObjects(ofType type: CapturedRoom.Object.Category, with resourceUrl: URL?, scale: Float = 1, onFloorLevel: Bool = true) {
        var objectNodes: [SCNNode]? = nil
        
        switch type {
        case .storage, .refrigerator, .stove, .bed, .sink, .washerDryer, .toilet, .bathtub, .oven, .dishwasher, .sofa, .chair, .fireplace, .television, .stairs, .table:
            objectNodes = sceneModel?.nodes(forCategory: type)
        @unknown default:
            return
        }
        
        replaceObjects(objectNodes: &objectNodes, with: resourceUrl, scale: scale, onFloorLevel: onFloorLevel)
        sceneModel?.updateNodes(objectNodes ?? [], forCategory: type)
    }
    
    /// Replace all surfaces
    func replaceSurfaces(ofType type: CapturedRoom.Surface.Category, with image: UIImage?) {
        var objectNodes: [SCNNode]? = nil
        
        switch type {
        case .door(isOpen: false), .door(isOpen: true), .window, .wall:
            objectNodes = sceneModel?.nodes(forCategory: type)
        case .opening:
            return
        case .floor:
            return
        @unknown default:
            return
        }
        
        replaceSurfaces(surfaceNodes: &objectNodes, with: image)
        sceneModel?.updateNodes(objectNodes ?? [], forCategory: type)
    }
    
    /// Helper function to replace all surfaces
    private func replaceSurfaces(surfaceNodes: inout [SCNNode]?, with image: UIImage?) {
        guard let surfaceNodes = surfaceNodes, !surfaceNodes.isEmpty else {
            print("No surface nodes to replace")
            return
        }
        if let image = image {
            surfaceNodes.forEach { surfaceNode in
                surfaceNode.geometry?.firstMaterial?.diffuse.contents = image
            }
        }
    }
    
    /// Helper function to replace all object
    private func replaceObjects(objectNodes: inout [SCNNode]?, with resourceUrl: URL?, scale: Float = 1, onFloorLevel: Bool = true) {
        var newNodes: [SCNNode] = []
        if let newObjectUrl = resourceUrl,
           let newObjectScene = try? SCNScene(url: newObjectUrl),
           let newObjectNode = newObjectScene.rootNode.childNodes.first {
            objectNodes?.forEach { objectNode in
                //                DispatchQueue.main.async {
                let node = newObjectNode.clone()
                //                node.l
                // Initial state before animation
                node.name = objectNode.name
                node.opacity = 0.0
                node.transform = objectNode.transform
                node.scale = SCNVector3(scale, scale, scale)
                print("Scaled down by: \(scale)")
                node.position.y -= Float((node.boundingBox.max.y) - (node.boundingBox.min.y))
                newNodes.append(node)
                self.scene?.rootNode.addChildNode(node)
                
                // Start animating
                let randomAnimationTime = Double.random(in: 0.5...1)
                
                // Remove current nodes
                let fadeOut = SCNAction.fadeOut(duration: randomAnimationTime)
                var move = SCNAction.move(to: SCNVector3(objectNode.position.x, objectNode.position.y - Float((objectNode.boundingBox.max.y) - (objectNode.boundingBox.min.y)), objectNode.position.z) , duration: randomAnimationTime)
                objectNode.runAction(fadeOut)
                objectNode.runAction(move)
                
                // Add new nodes
                DispatchQueue.main.asyncAfter(deadline: .now() + randomAnimationTime + Double.random(in: 0...1)) {
                    let animationTime = Double.random(in: 0.5...1.0)
                    let fadeIn = SCNAction.fadeIn(duration: animationTime)
                    if onFloorLevel {
                        move = SCNAction.move(to: SCNVector3(node.position.x, self.groundLevel, node.position.z), duration: animationTime)
                    } else {
                        move = SCNAction.move(to: SCNVector3(node.position.x, objectNode.position.y, node.position.z), duration: animationTime)
                    }
                    
                    node.runAction(fadeIn)
                    node.runAction(move)
                }
                
                // Remove after animation ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                    objectNode.removeFromParentNode()
                }
                //                }
                
                print("Replaced \(String(describing: objectNode.name))")
                
            }
        } else {
            print("Cannot load file")
        }
        // Replace oldnodes with newnodes
        objectNodes = newNodes
    }
    
    /// Find all nodes within a node recursively with a prefix
    func findNodes(withNamePrefix namePrefix: String, in node: SCNNode) -> [SCNNode] {
        var foundNodes: [SCNNode] = []
        
        for child in node.childNodes {
            if child.name?.hasPrefix(namePrefix) == true, child.name?.hasSuffix("_grp") == false  {
                foundNodes.append(child)
            }
            
            foundNodes.append(contentsOf: findNodes(withNamePrefix: namePrefix, in: child))
        }
        
        return foundNodes
    }

}

/// SceneView for SwiftUI with custom delegate
struct SceneView: UIViewRepresentable {
    @ObservedObject var sceneLoader: SceneLoader
    // True for before furnishing the room
    @Binding var isAutoEnablesDefaultLighting: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = sceneLoader.scene
        // Debug
//        view.debugOptions = [
//            .showWireframe, // Show wireframe
//            .showBoundingBoxes, // Show bounding boxes
//            .showCameras, // Show cameras
//            .showSkeletons,
//            .showLightInfluences, // Show lights
//            .showLightExtents // Show field of view cones
//        ]
//        view.backgroundColor = .grey
        
        // Important for realistic environment
        sceneLoader.scene?.wantsScreenSpaceReflection = true
        sceneLoader.scene?.rootNode.castsShadow = true
        addSpotLight(to: sceneLoader.scene?.rootNode)
        //        visualizeLights()
        view.allowsCameraControl = true
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ view: SCNView, context: Context) {
        view.scene = sceneLoader.scene
        view.autoenablesDefaultLighting = isAutoEnablesDefaultLighting
        print("Auto lighting: \(view.autoenablesDefaultLighting)")
    }
    
    func addSpotLight(to rootNode: SCNNode?) {
        // Create a spot light
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.color = UIColor.white
        spotLight.intensity = 300 // Adjust intensity as needed
        spotLight.spotInnerAngle = 0 // Adjust inner angle of the spot light
        spotLight.spotOuterAngle = 60 // Adjust outer angle of the spot light
        spotLight.castsShadow = true
        spotLight.shadowRadius = 10
        spotLight.shadowSampleCount = 40
        
        // Create a node to attach the spot light
        let spotLightNode = SCNNode()
        spotLightNode.light = spotLight
        
        // Position and orient the spot light node
        spotLightNode.position = SCNVector3(x: 2, y: 9, z: 4) // Adjust position as needed
        spotLightNode.eulerAngles = SCNVector3(x: .pi * 60 / 180, // Rotate around X-axis first
                                               y: -.pi * 70 / 180, // Rotate around Y-axis next
                                               z: -.pi * 160 / 180)  // Point light downwards
        
        
        // Add the spot light node to the root node
        rootNode?.addChildNode(spotLightNode)
    }
    
    /// Add lights to the scene for realistic environment
    func addLights() {
        guard let scene = sceneLoader.scene else {
            print("Couldn't add light. No scene were found")
            return
        }
        
        let waitAction = SCNAction.wait(duration: 0.5)
        
        for x in stride(from: -10, through: 10, by: 5) {
            for z in stride(from: -10, through: 10, by: 5) {
                let omniLight = SCNLight()
                omniLight.type = .omni
                omniLight.color = UIColor.white
                omniLight.intensity = 5
                omniLight.castsShadow = true
                omniLight.shadowMode = .forward
                
                let omniLightNode = SCNNode()
                omniLightNode.light = omniLight
                omniLightNode.position = SCNVector3(x: Float(x), y: 5, z: Float(z))
                omniLightNode.opacity = 0 // Start with opacity 0 to fade in
                scene.rootNode.addChildNode(omniLightNode)
                
                // Animate the opacity to fade in
                let fadeInSequence = SCNAction.sequence([waitAction, SCNAction.fadeIn(duration: 1.0)])
                omniLightNode.runAction(fadeInSequence)
            }
        }
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white // Adjust the intensity and color as needed
        ambientLight.intensity = 1200
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        ambientLightNode.position = SCNVector3(x: 0, y: 1000, z: 10) // Set the position of the light
        ambientLightNode.opacity = 0 // Start with opacity 0 to fade in
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Animate the opacity to fade in
        let fadeInActionForAmbient = SCNAction.fadeIn(duration: 10.0)
        //        DispatchQueue.main.async {
        ambientLightNode.runAction(fadeInActionForAmbient)
        //        }
        
        print("Lights added with animation")
    }
    
    /// Enable this will visualize where the lights are, however, all the light sources will be blocked
    func visualizeLights() {
        // Iterate through the scene's rootNode to find lights
        if let childNodes = sceneLoader.scene?.rootNode.childNodes {
            for node in childNodes {
                if let light = node.light {
                    // Create a visual representation for the light
                    let lightGeometry: SCNGeometry
                    switch light.type {
                    case .ambient:
                        // Visualize ambient light with a sphere
                        lightGeometry = SCNSphere(radius: 0.2)
                    case .directional:
                        // Visualize directional light with an arrow
                        lightGeometry = SCNCylinder(radius: 0.1, height: 1.0)
                        lightGeometry.firstMaterial?.diffuse.contents = UIColor.red // Set arrow color
                        let arrow = SCNNode(geometry: lightGeometry)
                        arrow.eulerAngles.x = -.pi / 2 // Point the arrow upward
                        node.addChildNode(arrow)
                        continue // Skip adding the light node itself
                    case .omni:
                        // Visualize point light with a sphere
                        lightGeometry = SCNSphere(radius: 0.2)
                    case .spot:
                        // Visualize spot light with a cone
                        lightGeometry = SCNCone(topRadius: 0, bottomRadius: 0.2, height: 0.5)
                        let lightNode = SCNNode(geometry: lightGeometry)
                        lightNode.eulerAngles.x = .pi / 2
                        node.addChildNode(lightNode)
                        continue
                    default:
                        continue // Skip other light types
                    }
                    
                    // Set the color of the light representation
                    lightGeometry.firstMaterial?.diffuse.contents = light.color
                    
                    // Create a node to hold the light representation geometry
                    let lightNode = SCNNode(geometry: lightGeometry)
                    node.addChildNode(lightNode)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        print("Coordinator made")
        return Coordinator(self)
    }
    
    /// SceneView delegate
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: SceneView
        
        init(_ parent: SceneView) {
            self.parent = parent
        }
        
        /// Scene updates
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            // Find and hide nearest wall
            if parent.sceneLoader.sceneModel?.walls?.count ?? 0 >= 4, let pointOfViewPos = renderer.pointOfView?.position {
                let nearestWall = parent.sceneLoader.findNearestWall(from: pointOfViewPos)
                parent.sceneLoader.hideWall(nearestWall)
            }
        }
    }
}


#Preview {
    MainView()
}
