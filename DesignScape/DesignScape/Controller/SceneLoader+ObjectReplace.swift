//
//  SceneLoader+ObjectReplace.swift
//  DesignScape
//
//  Created by Minh Huynh on 5/13/24.
//

import SceneKit

extension SceneLoader {
    /// Find the nearest wall from a point
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
    
    /// Hide a wall
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
    
    /// Hide all walls
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
    
    /// Show all walls
    func showAllWalls() {
        sceneModel?.walls?.forEach({ wall in
            wall.opacity = 1
        })
    }
    
}
