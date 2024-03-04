//
//  MyObjectCaptureSession.swift
//  DesignScape
//
//  Created by Tony Banh on 2/29/24.
//

import RealityKit
import SwiftUI
import Combine

@available(iOS 17.0, *)
class MyObjectCaptureSession: ObservableObject {
    @Published var session: ObjectCaptureSession?
    @Published var userCompletedScanPass = false // New property for completion status
    var modelFile: URL?
    
    private(set) var scanFolderManager: CaptureFolderManager!

    init() {
        setupSession()
    }

    private func setupSession() {
        Task {
            let newSession = await ObjectCaptureSession()
            var configuration = ObjectCaptureSession.Configuration()
            guard let folderManager = CaptureFolderManager() else {
                return false
            }

            scanFolderManager = folderManager
            
            
            DispatchQueue.main.async {
                self.session = newSession
                configuration.checkpointDirectory = self.scanFolderManager.snapshotsFolder
                configuration.isOverCaptureEnabled = true

                // Starts the initial segment and sets the output locations.
                self.session!.start(imagesDirectory: self.scanFolderManager.imagesFolder,
                              configuration: configuration)
                
            }
            return true;
        }
    }
    
    func finishScanningSession() {
        // Update completion status or perform any other necessary actions
        userCompletedScanPass = true
    }
}
