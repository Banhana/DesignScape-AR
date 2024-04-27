//
//  ModelLoader.swift
//  DesignScape
//
//  Created by Tony Banh on 3/27/24.
//

import Foundation

// Loads all models into a list from a specified directory
func loadModelNamesFromPlist(named plistName: String) -> [String] {
    // Get the path to the plist file in the asset catalog
    guard let plistPath = Bundle.main.path(forResource: plistName, ofType: "plist") else {
        print("Plist file named \(plistName) not found in the app bundle.")
        return []
    }

    // Load contents of the plist file
    if let modelNames = NSArray(contentsOfFile: plistPath) as? [String] {
        return modelNames
    } else {
        print("Error loading model names from plist file.")
        return []
    }
}
