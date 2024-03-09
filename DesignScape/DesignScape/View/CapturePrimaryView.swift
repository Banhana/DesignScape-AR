//
//  CapturePrimaryView.swift
//  DesignScape
//
//  Created by Tony Banh on 2/29/24.
//

import RealityKit
import SwiftUI

@available(iOS 17.0, *)
struct CapturePrimaryView: View {
    @StateObject var session = MyObjectCaptureSession()
    @State private var isReconstructionComplete = false

    var body: some View {
        ZStack {
            if session.userCompletedScanPass {
                VStack(spacing: 20) {
                    Spacer()
                    Button(action: {
                        session.session?.finish()
                        // Set the flag to true when you finish the capture session
                        isReconstructionComplete = true
                        // Puts the images/snapshots into a local directory
                        if let folderManager = CaptureFolderManager() {
                            ReconstructionPrimaryView(outputFile: folderManager.modelsFolder.appendingPathComponent("model-mobile.usdz"))
                        }
                    }) {
                        Text("Finish")
                            .padding()
                            .background(Color(red: 0.95, green: 0.85, blue: 0.6)) // Goldish
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding() // Add padding to the VStack
            } else if isReconstructionComplete {
                // Display the reconstructed model somehow
//                if let folderManager = CaptureFolderManager() {
//                    ReconstructionPrimaryView(outputFile: folderManager.modelsFolder.appendingPathComponent("model-mobile.usdz"))
//                }
            } else {
                ObjectCaptureView(session: session.session ?? ObjectCaptureSession())
                
                VStack(spacing: 20) {
                    Spacer() // Pushes the buttons to the bottom
                    if case .ready = session.session?.state {
                        Button(action: { session.session?.startDetecting() }) { // Button to start detecting the object
                            Text("Continue")
                                .padding()
                                .background(Color(red: 0.9, green: 0.85, blue: 0.7)) // Beige Color
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else if case .detecting = session.session?.state {
                        Button(action: { session.session?.startCapturing() }) { // Button to start capturing the object
                            Text("Start Capture")
                                .padding()
                                .background(Color(red: 0.6, green: 0.4, blue: 0.2)) // Brown Color
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else if case .capturing = session.session?.state {
                        Button(action: { session.finishScanningSession() }) { // Button to finish scanning session
                            Text("Finish Scanning")
                                .padding()
                                .background(Color(red: 0.8, green: 0.8, blue: 0.8)) // Grey Color
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding() // Add padding to the VStack
            }
        }
    }
}
