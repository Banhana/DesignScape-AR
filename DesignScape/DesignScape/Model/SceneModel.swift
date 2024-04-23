//
//  SceneModel.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/23/24.
//

import RoomPlan
import SceneKit


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
