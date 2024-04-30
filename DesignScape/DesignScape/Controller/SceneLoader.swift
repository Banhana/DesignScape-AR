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

class SceneLoader: ObservableObject {
    
    @Published var scene: SCNScene?
    @Published var sceneModel: SceneModel?
    @Published var isAutoenablesDefaultLighting = true
    
    private lazy var rootNode = scene?.rootNode
    private var groundLevel: Float = 0.0
    
    
    // TODO: create the bounding box instead of the geometry itself because custom UIImage cannot be loaded
    func styleNode(node: SCNNode) {
        let pbrMaterial = SCNMaterial()
        if let diffuseImage = UIImage(named: "White-Marble-Diffuse.png"),
           let metalnessImage = UIImage(named: "White-Marble-Metalness.png"),
           let normalImage = UIImage(named: "White-Marble-Normal.png"),
           let roughnessImage = UIImage(named: "White-Marble-Roughness.png") {
            pbrMaterial.diffuse.contents = diffuseImage
            pbrMaterial.metalness.contents = metalnessImage
            pbrMaterial.normal.contents = normalImage
            pbrMaterial.roughness.contents = roughnessImage
            //            pbrMaterial.emission.contents = UIColor.grey
            pbrMaterial.lightingModel = .physicallyBased
        } else {
            print("Failed to load material images")
        }
        DispatchQueue.main.async {
            node.geometry?.materials = [pbrMaterial]
        }
    }
    
    func loadScene(from fileRef: StorageReference) async {
        let sceneURL = try? await UserManager.shared.downloadRoomAsync(fileRef: fileRef)
        
        guard let sceneURL = sceneURL, let scene = try? SCNScene(url: sceneURL, options: nil) else {
            return
        }
        // Do not async this
        self.scene = scene
        // Access the root node of the scene
        let rootNode = scene.rootNode
        
        groundLevel = findLowestYCoordinate(in: rootNode)
        
        let bathtubNodes = findNodes(withNamePrefix: "Bathtub", in: rootNode)
        let bedNodes = findNodes(withNamePrefix: "Bed", in: rootNode)
        let chairNodes = findNodes(withNamePrefix: "Chair", in: rootNode)
        let dishwasherNodes = findNodes(withNamePrefix: "Dishwasher", in: rootNode)
        let fireplaceNodes = findNodes(withNamePrefix: "Fireplace", in: rootNode)
        let ovenNodes = findNodes(withNamePrefix: "Oven", in: rootNode)
        let refrigeratorNodes = findNodes(withNamePrefix: "Refrigerator", in: rootNode)
        let sinkNodes = findNodes(withNamePrefix: "Sink", in: rootNode)
        let sofaNodes = findNodes(withNamePrefix: "Sofa", in: rootNode)
        let stairsNodes = findNodes(withNamePrefix: "Stairs", in: rootNode)
        let storageNodes = findNodes(withNamePrefix: "Storage", in: rootNode)
        let stoveNodes = findNodes(withNamePrefix: "Stove", in: rootNode)
        let tableNodes = findNodes(withNamePrefix: "Table", in: rootNode)
        let televisionNodes = findNodes(withNamePrefix: "Screen", in: rootNode)
        let toiletNodes = findNodes(withNamePrefix: "Toilet", in: rootNode)
        let washerDryerNodes = findNodes(withNamePrefix: "WasherDryer", in: rootNode)
        let wallsNodes = findNodes(withNamePrefix: "Wall", in: rootNode)
        let doorClosedNodes = findNodes(withNamePrefix: "DoorClosed", in: rootNode)
        let doorOpenedNodes = findNodes(withNamePrefix: "DoorOpened", in: rootNode)
        let windowNodes = findNodes(withNamePrefix: "Window", in: rootNode)
        
        sceneModel = SceneModel(
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
    
    func addFloor() {
        guard let roomNode = scene?.rootNode.childNodes.first else {
            print("Cannot add floor")
            return
        }
        let boundingBox = roomNode.boundingBox
        
        let floorGeometry = SCNFloor()
        // TODO: If wood then do not set reflection
        floorGeometry.reflectivity = 0.05
        floorGeometry.reflectionFalloffEnd = 0.8
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIImage(named: "WoodFlooringAshSuperWhite001_COL_2K.jpg")
        floorMaterial.diffuse.wrapS = .repeat
        floorMaterial.diffuse.wrapT = .repeat
        floorMaterial.normal.contents = UIImage(named: "WoodFlooringAshSuperWhite001_NRM_2K.jpg")
        //            floorMaterial.specular.contents = UIImage(named: "WoodFlooringAshSuperWhite001_GLOSS_2K.jpg")
        //            floorMaterial.emission.contents = UIImage(named: "WoodFlooringAshSuperWhite001_REFL_2K.jpg") //Crash
        //        floorMaterial.emission.intensity = 0
        floorMaterial.lightingModel = .physicallyBased
        
        floorGeometry.materials = [floorMaterial]
        print("Root \(String(describing: scene?.rootNode.childNodes.first))")
        print("Bounding box \(boundingBox)")
        floorGeometry.width = CGFloat(boundingBox.max.x - boundingBox.min.x) / 2
        floorGeometry.length = CGFloat(boundingBox.max.z - boundingBox.min.z) / 2
        
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position.y = -20
        floorNode.opacity = 0
        floorNode.name = "Floor"
        sceneModel?.floors?.append(floorNode)
        self.rootNode?.addChildNode(floorNode)
        
        let animationTime = Double.random(in: 2...3.0)
        let fadeIn = SCNAction.fadeIn(duration: animationTime)
        floorNode.runAction(fadeIn)
        floorNode.position.y = self.groundLevel // Position the floor at the lowest Y-coordinate
//        floorNode.runAction(.rotate(by: .pi/2, around: T##SCNVector3, duration: T##TimeInterval))
        
        // Use rotation of the wall to rotate the room
        if let wallRotation = self.sceneModel?.walls?.first?.simdRotation {
            floorNode.simdRotation = wallRotation
        }
        
    }
    
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
    
    func findLowestYCoordinate(in rootNode: SCNNode) -> Float {
        var lowestY: Float = Float.greatestFiniteMagnitude
        // Finding the lowest of all object gives false value (Walls bounding box is lower than expected), therefore only find the bounding box of Room node
        rootNode.childNodes.forEach { node in
            let boundingBox = node.boundingBox
            lowestY = min(lowestY, boundingBox.min.y)
        }
        return lowestY
    }
    
    func styleWalls() {
        sceneModel?.walls?.forEach({ wall in
            styleNode(node: wall)
        })
    }
    
    func replaceObjects(ofType type: CapturedRoom.Object.Category, with resourceUrl: URL?) {
        var objectNodes: [SCNNode]? = nil
        
        switch type {
        case .storage, .refrigerator, .stove, .bed, .sink, .washerDryer, .toilet, .bathtub, .oven, .dishwasher, .sofa, .chair, .fireplace, .television, .stairs, .table:
            objectNodes = sceneModel?.nodes(forCategory: type)
        @unknown default:
            return
        }
        
        replaceObjects(objectNodes: &objectNodes, with: resourceUrl)
        sceneModel?.updateNodes(objectNodes ?? [], forCategory: type)
    }
    
    func replaceSurfaces(ofType type: CapturedRoom.Surface.Category, with image: UIImage?) {
        var objectNodes: [SCNNode]? = nil
        
        switch type {
        case .door(isOpen: false), .door(isOpen: true), .window, .wall:
            objectNodes = sceneModel?.nodes(forCategory: type)
        case .opening:
            return
        case .floor:
            addFloor()
        @unknown default:
            return
        }
        
        replaceSurfaces(surfaceNodes: &objectNodes, with: image)
        sceneModel?.updateNodes(objectNodes ?? [], forCategory: type)
    }
    
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
    
    private func replaceObjects(objectNodes: inout [SCNNode]?, with resourceUrl: URL?, scale: Float = 1) {
        var newNodes: [SCNNode] = []
        if let newObjectUrl = resourceUrl,
           let newObjectScene = try? SCNScene(url: newObjectUrl),
           let newObjectNode = newObjectScene.rootNode.childNodes.first {
            newObjectNode.scale = SCNVector3(scale, scale, scale)
            objectNodes?.forEach { objectNode in
//                DispatchQueue.main.async {
                    let node = newObjectNode.clone()
                    //                node.l
                    // Initial state before animation
                    node.name = objectNode.name
                    node.opacity = 0.0
                    node.transform = objectNode.transform
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
                        move = SCNAction.move(to: SCNVector3(node.position.x, self.groundLevel, node.position.z) , duration: animationTime)
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
    
    func loadCustomChairScene() -> SCNScene? {
        guard let customChairSceneURL = Bundle.main.url(forResource: "CustomChair", withExtension: "usdz"), let customChairScene = try? SCNScene(url: customChairSceneURL, options: nil) else {
            print("Unable to find CustomChair.usdz")
            return nil
        }
        return customChairScene
    }
    
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
    
    func findNearestWall(from point: SCNVector3) -> SCNNode? {
        guard let walls = sceneModel?.walls else { return nil }
        
        var nearestWall: SCNNode?
        var shortestDistance: Float = .greatestFiniteMagnitude
        
        for wall in walls {
            let wallCenter = wall.position
            let distance = SCNVector3.distanceFrom(vector: wallCenter, toVector: point)
            
            if distance < shortestDistance {
                shortestDistance = distance
                nearestWall = wall
            }
        }
        
        return nearestWall
    }
    
    func hideWall(_ wall: SCNNode?) {
        if let wallToHide = wall {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            sceneModel?.walls?.forEach({ wall in
                if wall != wallToHide {
                    wall.opacity = 1
                }
            })
            wallToHide.opacity = 0
            SCNTransaction.commit()
        }
    }
    
    func hideWalls(_ walls: [SCNNode]?) {
        if let wallsToHide = walls {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            // Only unhide the wall not currently hidden
            sceneModel?.walls?.filter({!wallsToHide.contains($0)}).forEach({ wall in
                wall.opacity = 1
            })
            wallsToHide.filter({$0.opacity == 1}).forEach { wallToHide in
                wallToHide.opacity = 0.01
            }
            SCNTransaction.commit()
        }
    }
    
    func showAllWalls() {
        //         Show all walls
        sceneModel?.walls?.forEach({ wall in
            wall.opacity = 1
        })
    }
    
}

extension SCNVector3 {
    static func distanceFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> Float {
        let x0 = vector1.x
        let x1 = vector2.x
        let y0 = vector1.y
        let y1 = vector2.y
        let z0 = vector1.z
        let z1 = vector2.z
        
        return sqrtf(powf(x1-x0, 2) + powf(y1-y0, 2) + powf(z1-z0, 2))
    }
}


struct SceneView: UIViewRepresentable {
    @ObservedObject var sceneLoader: SceneLoader
    // True for before furnishing the room
    @Binding var isAutoEnablesDefaultLighting: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = sceneLoader.scene
        // Debug
        view.debugOptions = [
            .showWireframe, // Show wireframe
            .showBoundingBoxes, // Show bounding boxes
            .showCameras, // Show cameras
            .showSkeletons,
            .showLightInfluences, // Show lights
            .showLightExtents // Show field of view cones
        ]
        view.backgroundColor = .grey
        
        // Important for realistic environment
        sceneLoader.scene?.wantsScreenSpaceReflection = true
        sceneLoader.scene?.rootNode.castsShadow = true
        addSpotLight(to: sceneLoader.scene?.rootNode)
//        visualizeLights()
        view.allowsCameraControl = true
        view.delegate = context.coordinator
        return view
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
        
        let fadeInAction = SCNAction.fadeIn(duration: 10.0)
        let waitAction = SCNAction.wait(duration: 0.5)
        
        var delay: TimeInterval = 0.0
        
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
    
    func updateUIView(_ view: SCNView, context: Context) {
        view.scene = sceneLoader.scene
        view.autoenablesDefaultLighting = isAutoEnablesDefaultLighting
        print("Auto lighting: \(view.autoenablesDefaultLighting)")
    }
    
    func makeCoordinator() -> Coordinator {
        print("Coordinator made")
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: SceneView
        
        init(_ parent: SceneView) {
            self.parent = parent
        }
        
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
