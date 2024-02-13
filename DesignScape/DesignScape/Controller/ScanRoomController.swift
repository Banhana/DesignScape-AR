//
//  ScanRoomController.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/1/24.
//

import SwiftUI
import RoomPlan

class ScanRoomController: RoomCaptureSessionDelegate, RoomCaptureViewDelegate {
    func encode(with coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    static var instance = ScanRoomController()
    var captureView: RoomCaptureView
    let sessionConfig = RoomCaptureSession.Configuration()
    var finalResult: CapturedRoom?
    init() {
        captureView = RoomCaptureView(frame: .zero)
        captureView.delegate = self
    }
    
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
        if (error == nil) {
            return true
        }
        return false
    }
    
    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
        finalResult = processedResult
    }
    
    func startSession() {
        captureView.captureSession.run(configuration: sessionConfig)
    }
    
    func stopSession() {
        captureView.captureSession.stop()
    }

}

struct ScanRoomViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> RoomCaptureView {
        ScanRoomController.instance.captureView
    }
    
    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
        
    }
}

