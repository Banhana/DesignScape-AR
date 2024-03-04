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
                    Spacer() // Pushes the buttons to the bottom
                    Button(action: {
                        session.session?.finish()
                        // Set the flag to true when you finish the capture session
                        isReconstructionComplete = true
                    }) {
                        Text("Finish")
                            .padding() // Increase padding to make the button bigger
                            .background(Color.red) // Add background color
                            .foregroundColor(.white) // Text color
                            .cornerRadius(10) // Rounded corners
                    }
                }
                .padding() // Add padding to the VStack
            } else if isReconstructionComplete {
                // Display the reconstructed model somehow
            } else {
                ObjectCaptureView(session: session.session ?? ObjectCaptureSession())
                
                VStack(spacing: 20) {
                    Spacer() // Pushes the buttons to the bottom
                    if case .ready = session.session?.state {
                        Button(action: { session.session?.startDetecting() }) {
                            Text("Continue")
                                .padding() // Increase padding to make the button bigger
                                .background(Color.blue) // Add background color
                                .foregroundColor(.white) // Text color
                                .cornerRadius(10) // Rounded corners
                        }
                    } else if case .detecting = session.session?.state {
                        Button(action: { session.session?.startCapturing() }) {
                            Text("Start Capture")
                                .padding() // Increase padding to make the button bigger
                                .background(Color.green) // Add background color
                                .foregroundColor(.white) // Text color
                                .cornerRadius(10) // Rounded corners
                        }
                    } else if case .capturing = session.session?.state {
                        Button(action: { session.finishScanningSession() }) { // Add button to finish scanning session
                            Text("Finish Scanning")
                                .padding() // Increase padding to make the button bigger
                                .background(Color.red) // Add background color
                                .foregroundColor(.white) // Text color
                                .cornerRadius(10) // Rounded corners
                        }
                    }
                }
                .padding() // Add padding to the VStack
            }
        }
    }
}
