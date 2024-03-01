//
//  ObjectCaptureView.swift
//  DesignScape
//
//  Created by Tony Banh on 2/29/24.
//

import RealityKit
import SwiftUI

@available(iOS 17.0, *)
struct CapturePrimaryView: View {
    var session: ObjectCaptureSession

    init(session: ObjectCaptureSession) {
        self.session = session
    }

    var body: some View {
        ZStack {
            ObjectCaptureView(session: session.session)
            if case .ready = session.session.state {
                CreateButton(label: "Continue") {
                    session.session.startDetecting()
                }
            } else if case .detecting = session.session.state {
                CreateButton(label: "Start Capture") {
                    session.session.startCapturing()
                }
            }
        }
    }
}
