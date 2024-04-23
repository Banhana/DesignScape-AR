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

class SceneLoader: ObservableObject {
    
    @Published var scene: SCNScene?
    @Published var sceneModel: SceneModel?
    
    private lazy var rootNode = scene?.rootNode
    private var groundLevel: Float = 0.0
    
    
    // TODO: create the bounding box instead of the geometry itself because custom UIImage cannot be loaded
    func styleNode(node: SCNNode) {
        let pbrMaterial = SCNMaterial()
        if let diffuseImage = UIImage(named: "White-Marble-Diffuse"),
           let metalnessImage = UIImage(named: "White-Marble-Metalness"),
           let normalImage = UIImage(named: "White-Marble-Normal"),
           let roughnessImage = UIImage(named: "White-Marble-Roughness") {
            pbrMaterial.diffuse.contents = diffuseImage
            //                pbrMaterial.metalness.contents = metalnessImage
            //                pbrMaterial.normal.contents = normalImage
            //                pbrMaterial.roughness.contents = roughnessImage
            //            pbrMaterial.emission.contents = UIColor.grey
            pbrMaterial.lightingModel = .physicallyBased
        } else {
            print("Failed to load material images")
        }
        DispatchQueue.main.async {
            node.geometry?.materials = [pbrMaterial]
        }
    }
    
    func loadScene() {
        guard let sceneURL = Bundle.main.url(forResource: "Room 2", withExtension: "usdz"), let scene = try? SCNScene(url: sceneURL, options: nil) else {
            print("Unable to find file.usdz")
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
        
//        replaceObjects(objectNodes: chairNodes, with: Bundle.main.url(forResource: "bisou-accent-chair", withExtension: "usdz"))
//        replaceObjects(objectNodes: tableNodes, with: Bundle.main.url(forResource: "wells-leather-sofa", withExtension: "usdz"))
        
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
            walls: wallsNodes
        )
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
        
//        if var nodes = objectNodes {
            replaceObjects(objectNodes: &objectNodes, with: resourceUrl)
        sceneModel?.updateNodes(objectNodes ?? [], forCategory: type)
//        }
    }
    
//    func replaceChairs(with resourceUrl: URL?) {
//        var chairs: [SCNNode]? = sceneModel?.chairs
//        replaceObjects(objectNodes: &chairs, with: resourceUrl)
//        sceneModel?.chairs = chairs
//    }
//    
//    func replaceTables(with resourceUrl: URL?) {
//        var tables: [SCNNode]? = sceneModel?.tables
//        replaceObjects(objectNodes: &tables, with: resourceUrl)
//        sceneModel?.tables = tables
//    }
    
    private func replaceObjects(objectNodes: inout [SCNNode]?, with resourceUrl: URL?) {
        let view = SCNView()
        view.scene = scene
        var newNodes: [SCNNode] = []
        objectNodes?.forEach { objectNode in
            if let newObjectUrl = resourceUrl,
               let newObjectScene = try? SCNScene(url: newObjectUrl),
               let newObjectNode = newObjectScene.rootNode.childNodes.first {
                let node = newObjectNode.clone()
                // Initial state before animation
                node.name = objectNode.name
                node.opacity = 0.0
                node.transform = objectNode.transform
                node.position.y -= Float((node.boundingBox.max.z) - (node.boundingBox.min.z))
                newNodes.append(node)
                self.scene?.rootNode.addChildNode(node)
                print("Initial y \(node.position.y)")
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.2...0.8)) {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = Double.random(in: 0.5...2.5)
                    node.position.y = self.groundLevel // Final position adjustment
                    node.opacity = 1.0
                    objectNode.position.y -= Float((objectNode.boundingBox.max.z) - (objectNode.boundingBox.min.z))
                    objectNode.opacity = 0.0
                    SCNTransaction.commit()
                }
                // End animation
                
                // Remove after animation ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                    objectNode.removeFromParentNode()
                }
                
                print("Replaced \(String(describing: objectNode.name))")
            } else {
                print("Cannot load file")
            }
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
}

struct SceneModel {
    var bathtubs: [SCNNode]?
    var beds: [SCNNode]?
    var chairs: [SCNNode]?
    var dishwashers: [SCNNode]?
    var fireplaces: [SCNNode]?
    var ovens: [SCNNode]?
    var refridgerator: [SCNNode]?
    var sinks: [SCNNode]?
    var sofas: [SCNNode]?
    var stairs: [SCNNode]?
    var storages: [SCNNode]?
    var stoves: [SCNNode]?
    var tables: [SCNNode]?
    var televisions: [SCNNode]?
    var toilets: [SCNNode]?
    var washerDryers: [SCNNode]?
    
    var walls: [SCNNode]?
}

extension SceneModel {
    func nodes(forCategory category: CapturedRoom.Object.Category) -> [SCNNode]? {
        switch category {
        case .storage: return storages
        case .refrigerator: return refridgerator
        case .stove: return stoves
        case .bed: return beds
        case .sink: return sinks
        case .washerDryer: return washerDryers
        case .toilet: return toilets
        case .bathtub: return bathtubs
        case .oven: return ovens
        case .dishwasher: return dishwashers
        case .table: return tables
        case .sofa: return sofas
        case .chair: return chairs
        case .fireplace: return fireplaces
        case .television: return televisions
        case .stairs: return stairs
        @unknown default:
            return nil
        }
    }
    
    mutating func updateNodes(_ nodes: [SCNNode], forCategory category: CapturedRoom.Object.Category) {
        switch category {
        case .storage: storages = nodes
        case .refrigerator: refridgerator = nodes
        case .stove: stoves = nodes
        case .bed: beds = nodes
        case .sink: sinks = nodes
        case .washerDryer: washerDryers = nodes
        case .toilet: toilets = nodes
        case .bathtub: bathtubs = nodes
        case .oven: ovens = nodes
        case .dishwasher: dishwashers = nodes
        case .table: tables = nodes
        case .sofa: sofas = nodes
        case .chair: chairs = nodes
        case .fireplace: fireplaces = nodes
        case .television: televisions = nodes
        case .stairs: stairs = nodes
        @unknown default:
            return
        }
    }
}

struct SceneView: UIViewRepresentable {
    let scene: SCNScene?
    
    init(scene: SCNScene?) {
        self.scene = scene
    }
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = true
        return view
    }
    
    func updateUIView(_ view: SCNView, context: Context) {
        view.scene = scene
    }
}

#Preview {
    NavigationStack {
        RoomLoaderView()
    }
}
