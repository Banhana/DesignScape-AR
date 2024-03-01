//
//  ObjectCaptureSession.swift
//  DesignScape
//
//  Created by Tony Banh on 2/29/24.
//

import RealityKit
import SwiftUI

@available(iOS 17.0, *)
class MyObjectCaptureSession {
    var session: ObjectCaptureSession

    init() async {
        self.session = await ObjectCaptureSession()
    }
}
