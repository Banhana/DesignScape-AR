//
//  ARActions.swift
//  DesignScape
//
//  Created by Tony Banh on 2/3/24.
//

import SwiftUI

// Actions for our AR Scene
enum ARActions{
    case placeObject(modelLocalUrl: URL) // Places the object we select from the images
    case removeAllAnchors // Removes all objects that we placed
}
