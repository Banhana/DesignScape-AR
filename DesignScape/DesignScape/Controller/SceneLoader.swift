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
        print("Scene Loaded")
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
    
    private func replaceObjects(objectNodes: inout [SCNNode]?, with resourceUrl: URL?) {
        let view = SCNView()
        view.scene = scene
        var newNodes: [SCNNode] = []
        if let newObjectUrl = resourceUrl,
           let newObjectScene = try? SCNScene(url: newObjectUrl),
           let newObjectNode = newObjectScene.rootNode.childNodes.first {
            objectNodes?.forEach { objectNode in
                
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
    let scene: SCNScene?
    let sceneLoader: SceneLoader?
    
    init(scene: SCNScene?, sceneLoader: SceneLoader?) {
        self.scene = scene
        self.sceneLoader = sceneLoader
    }
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = true
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ view: SCNView, context: Context) {
        view.scene = scene
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
                if let pointOfViewPos = renderer.pointOfView?.position {
                    let nearestWall = parent.sceneLoader?.findNearestWall(from: pointOfViewPos)
                    parent.sceneLoader?.hideWall(nearestWall)
                }
            }
        }
}


#Preview {
    MainView()
}
