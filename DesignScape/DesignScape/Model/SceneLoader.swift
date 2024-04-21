//
//  SceneLoader.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/16/24.
//

import SceneKit

struct SceneLoader {
    
    func loadScene() -> SceneModel? {
        do {
            guard let sceneURL = Bundle.main.url(forResource: "Room 2", withExtension: "usdz") else {
                fatalError("Unable to find file.usdz")
            }
            
            let scene = try SCNScene(url: sceneURL, options: nil)
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

            let sceneModel = SceneModel(
                bathtubs: bathtubNodes,
                beds: bedNodes,
                chairs: chairNodes,
                dishwashers: dishwasherNodes,
                fireplaces: fireplaceNodes,
                ovens: ovenNodes,
                refridgerator: refrigeratorNodes,
                sink: sinkNodes,
                sofas: sofaNodes,
                stairs: stairsNodes,
                storages: storageNodes,
                stove: stoveNodes,
                tables: tableNodes,
                televisions: televisionNodes,
                toilet: toiletNodes,
                washerDryer: washerDryerNodes
            )
            return sceneModel
        } catch {
            print("An error occurred while loading the USDZ file: \(error)")
        }
        return nil
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
    var sink: [SCNNode]?    
    var sofas: [SCNNode]?
    var stairs: [SCNNode]?
    var storages: [SCNNode]?
    var stove: [SCNNode]?
    var tables: [SCNNode]?
    var televisions: [SCNNode]?
    var toilet: [SCNNode]?
    var washerDryer: [SCNNode]?
}
