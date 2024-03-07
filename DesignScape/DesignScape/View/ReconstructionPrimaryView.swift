//
//  ReconstructionPrimaryView.swift
//  DesignScape
//
//  Created by Tony Banh on 3/6/24.
//

import Foundation
import RealityKit
import SwiftUI
import os

@available(iOS 17.0, *)
struct ReconstructionPrimaryView: View {
    let outputFile: URL

    @State private var completed: Bool = false
    @State private var cancelled: Bool = false

    var body: some View {
        ReconstructionProgressView(outputFile: outputFile,
                                   completed: $completed,
                                   cancelled: $cancelled)
        .onAppear(perform: {
            UIApplication.shared.isIdleTimerDisabled = true
        })
        .onDisappear(perform: {
            UIApplication.shared.isIdleTimerDisabled = false
        })
        .interactiveDismissDisabled()
    }
}

@available(iOS 17.0, *)
struct ReconstructionProgressView: View {
    static let logger = Logger(subsystem: DesignScapeApp.subsystem,
                               category: "ReconstructionProgressView")

    @StateObject var session = MyObjectCaptureSession()
    let logger = ReconstructionProgressView.logger
    let outputFile: URL
    @Binding var completed: Bool
    @Binding var cancelled: Bool

    // All var = Progress tracker stuff when the model is being created
    @State private var progress: Float = 0
    @State private var estimatedRemainingTime: TimeInterval?
    @State private var processingStageDescription: String?
    @State private var pointCloud: PhotogrammetrySession.PointCloud?
    @State private var gotError: Bool = false
    @State private var error: Error?
    @State private var isCancelling: Bool = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var padding: CGFloat {
        horizontalSizeClass == .regular ? 60.0 : 24.0
    }
    // Returns a bool to check if state is reconstructing or not
    private func isReconstructing() -> Bool {
        return !completed && !gotError && !cancelled
    }

    var body: some View {
        VStack(spacing: 0) {
            if isReconstructing() { // Figure out how to start reconstructing here
                HStack {
                    Button(action: {
                        logger.log("Cancelling...")
                        isCancelling = true
                    }, label: {
                        Text("Cancelling")
                            .font(.headline)
                            .bold()
                            .padding(30)
                            .foregroundColor(.blue)
                    })
                    .padding(.trailing)

                    Spacer()
                }
            }

            Spacer()

            Spacer()

            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
        .alert(
            "Failed:  " + (error != nil  ? "\(String(describing: error!))" : ""),
            isPresented: $gotError,
            actions: {
                Button("OK") {
                    logger.log("Calling restart...")
                }
            })
    }
}
