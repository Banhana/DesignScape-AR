//
//  ARModelManager.swift
//  DesignScape
//
//  Created by Tony Banh on 2/20/24.
//

import Foundation

class ARModelManager {
    // Loads all models into a list from a specified directory
    static func loadModelNames(named directory: String) -> [String] {
        guard let directoryURL = Bundle.main.url(forResource: directory, withExtension: nil) else {
            return []
        }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            let modelNames = fileURLs.map { $0.deletingPathExtension().lastPathComponent }
            return modelNames
        } catch {
            print("Error loading model names from directory: \(error)")
            return []
        }
    }
}
