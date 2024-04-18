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
#if !targetEnvironment(simulator)
    @StateObject var session = MyObjectCaptureSession()
    @State private var isReconstructionComplete = false
#endif
    
    var body: some View {
#if !targetEnvironment(simulator)
    ZStack {
        ObjectCaptureView(session: session.session ?? ObjectCaptureSession())
        
        VStack(spacing: 20) {
            Spacer() // Pushes the buttons to the bottom
            if case .ready = session.session?.state {
                Button(action: { _ = session.session?.startDetecting() }) { // Button to start detecting the object
                    GreyButton(text: "CONTINUE", systemImage: "arrow.right")
                }
            } else if case .detecting = session.session?.state {
                Button(action: { session.session?.startCapturing() }) { // Button to start capturing the object
                    PrimaryButton(text: "START CAPTURING", systemImage: "camera")
                        .opacity(0.8)
                }
            } else if case .capturing = session.session?.state {
                Button(action: { session.finishScanningSession() }) { // Button to finish scanning session
                    GoldButton(text: "FINISH", systemImage: "checkmark")
                        .opacity(0.8)
                }
            } else if case session.session?.userCompletedScanPass = true {
                VStack {
                    ObjectCapturePointCloudView(session: session.session ?? ObjectCaptureSession())
                    Button(action: { session.session?.finish() }) { // Button to finish scanning session
                        GoldButton(text: "am done", systemImage: "checkmark")
                            .opacity(0.8)
                    }
                }
//            } else {
//                ZStack {
//                    ObjectCaptureView(session: session.session ?? ObjectCaptureSession())
//                }
            }
//            else if case .completed = session.session?.state {
//                ObjectCaptureView(session: session.session ?? ObjectCaptureSession())
//                if let folderManager = CaptureFolderManager() {
//                    ReconstructionPrimaryView(outputFile: folderManager.modelsFolder.appendingPathComponent("model-mobile.usdz"))
//                }
//            }
        }
        .padding() // Add padding to the VStack
    }
    .customNavBar(isTitleHidden: true, isCloseButtonHidden: true)
#endif
    }
}
