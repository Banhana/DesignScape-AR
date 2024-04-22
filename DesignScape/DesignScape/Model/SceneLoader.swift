//
//  SceneLoader.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/16/24.
//

import SwiftUI
import SceneKit

class SceneLoader: ObservableObject {
    
    @Published var scene: SCNScene?
    @Published var sceneModel: SceneModel?
    
    
    // TODO: create the bounding box instead of the geometry itself because custom UIImage cannot be loaded
    func styleNode(node: SCNNode) {
        let pbrMaterial = SCNMaterial()
        if let diffuseImage = UIImage(named: "White-Marble-Diffuse"),
           let metalnessImage = UIImage(named: "White-Marble-Metalness"),
           let normalImage = UIImage(named: "White-Marble-Normal"),
           let roughnessImage = UIImage(named: "White-Marble-Roughness") {
//            if let jpegData = diffuseImage.jpegData(compressionQuality: 1.0) {
//                let jpegImage = UIImage(data: jpegData)!
//                pbrMaterial.diffuse.contents = jpegImage
//            }
            pbrMaterial.diffuse.contents = diffuseImage
            //                pbrMaterial.metalness.contents = metalnessImage
            //                pbrMaterial.normal.contents = normalImage
            //                pbrMaterial.roughness.contents = roughnessImage
            //            pbrMaterial.emission.contents = UIColor.grey
            pbrMaterial.lightingModel = .physicallyBased
        } else {
            print("Failed to load material images")
        }
        
//
        // Get the existing geometry of the node
            guard let geometry = node.geometry else {
                print("Node has no geometry")
                return
            }
        let box = createBoundingBox(for: geometry)
//        // Define texture coordinates for the geometry
//        let texCoords: [SCNVector3] = extractVertices(from: geometry)
//        
//        // Create a new geometry source with the texture coordinates
//            let texCoordSource = SCNGeometrySource(vertices: texCoords)
//        
//            
//            // Create a new geometry with the existing geometry's data and the new texture coordinate source
//            let newGeometry = SCNGeometry(sources: [geometry.sources(for: .vertex).first!, texCoordSource], elements: geometry.elements)
//            
//            // Set the semantics of the texture coordinate source
//            newGeometry.firstMaterial?.diffuse.wrapS = .repeat
//            newGeometry.firstMaterial?.diffuse.wrapT = .repeat
////            newGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
//            
//            // Replace the existing geometry with the new geometry
//            node.geometry = newGeometry
//        
//        node.geometry?.materials = [pbrMaterial]
        box.geometry?.materials = [pbrMaterial]
        scene?.rootNode.addChildNode(box)
        
    }
    
    func createBoundingBox(for geometry: SCNGeometry) -> SCNNode {
        let boundingBox = geometry.boundingBox
        let boxNode = SCNNode(geometry: SCNBox(width: CGFloat(boundingBox.max.x - boundingBox.min.x),
                                               height: CGFloat(boundingBox.max.y - boundingBox.min.y),
                                               length: CGFloat(boundingBox.max.z - boundingBox.min.z),
                                              chamferRadius: 0))
        var mid: SCNVector3 {
            let x = (boundingBox.min.x + boundingBox.max.x) / 2
            let y = (boundingBox.min.y + boundingBox.max.y) / 2
            let z = (boundingBox.min.z + boundingBox.max.z) / 2
            return SCNVector3(x: x, y: y, z: z)
        }
        boxNode.position = SCNVector3(mid.x, mid.y, mid.z)
        return boxNode
    }
    
    func extractVertices(from geometry: SCNGeometry) -> [SCNVector3] {
        guard let vertexSource = geometry.sources(for: .vertex).first else {
            print("Geometry has no vertex data")
            return []
        }
        
        let vertices = vertexSource.data.map { Float32($0) }
        var vertexArray: [SCNVector3] = []
        for i in 0..<vertices.count / 3 {
            let index = i * 3
            let x = vertices[index]
            let y = vertices[index + 1]
            let z = vertices[index + 2]
            vertexArray.append(SCNVector3(x, y, z))
        }
        return vertexArray
    }
    
    func loadScene() {
        guard let sceneURL = Bundle.main.url(forResource: "Room 2", withExtension: "usdz"), let scene = try? SCNScene(url: sceneURL, options: nil) else {
            print("Unable to find file.usdz")
            return
        }
        
        DispatchQueue.main.async {
            self.scene = scene
        }
        // Access the root node of the scene
        let rootNode = scene.rootNode
        
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
        let televisionNodes = findNodes(withNamePrefix: "Television", in: rootNode)
        let toiletNodes = findNodes(withNamePrefix: "Toilet", in: rootNode)
        let washerDryerNodes = findNodes(withNamePrefix: "WasherDryer", in: rootNode)
        let wallsNodes = findNodes(withNamePrefix: "Wall", in: rootNode)
        
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
        print("Scene Loaded! \(String(describing: sceneModel))")
    }
    
    func styleWalls() {
        sceneModel?.walls?.forEach({ wall in
            styleNode(node: wall)
            print("Style Wall Once")
        })
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
