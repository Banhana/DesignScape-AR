//
//  MyPhotogrammetrySession.swift
//  DesignScape
//
//  Created by Tony Banh on 4/27/24.
//

import RealityKit
import SwiftUI

@available(iOS 17.0, *)
class MyPhotogrammetrySession: ObservableObject {
#if !targetEnvironment(simulator)
    @Published var session: PhotogrammetrySession?
    let scanFolderManager = CaptureFolderManager()
    let inputFolderUrl: URL?
    let url: URL
    var request: PhotogrammetrySession.Request?

    init() {
        self.inputFolderUrl = scanFolderManager?.modelsFolder
        self.url = URL(fileURLWithPath: "model-mobile.usdz")
        do {
            if let inputFolderUrl = self.inputFolderUrl {
                self.session = try PhotogrammetrySession(input: inputFolderUrl)
                if let session = self.session {
                    let request = PhotogrammetrySession.Request.modelFile(url: url, detail: .reduced)
                }
            }
        } catch {
            // Handle error
            print(error)
        }
    }
#endif
}

