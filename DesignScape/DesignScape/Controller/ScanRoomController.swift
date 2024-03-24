//
//  ScanRoomController.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/1/24.
//

import SwiftUI
import RoomPlan
import FirebaseStorage


/// Scan Room Controller in charge of capturing the room for a model
class ScanRoomController: RoomCaptureSessionDelegate, RoomCaptureViewDelegate, ObservableObject {
    func encode(with coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    /// The only instance
    static var instance = ScanRoomController()
    var captureView: RoomCaptureView
    let sessionConfig = RoomCaptureSession.Configuration()
    
    /// A 3d model of the final result
    var finalResult: CapturedRoom?
    
    // Setup RoomBuilder
    private var roomBuilder = RoomBuilder(options: [.beautifyObjects])
    
    // Export url
    @Published var url: URL?
    
    /// Initializer
    init() {
        captureView = RoomCaptureView(frame: .zero)
        captureView.delegate = self
        captureView.captureSession.delegate = self
    }
    
    /// Capture the room
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
        if (error == nil) {
            return true
        }
        return false
    }
    
    /// Scans completed
    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
        if let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        finalResult = processedResult
    }
    
    func captureSession(_ session: RoomCaptureSession, didEndWith data: CapturedRoomData, error: (Error)?) {
        if let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        generateRoomURL(with: data)
    }
    
    func generateRoomURL(with captureRoomData: CapturedRoomData){
        print("Starting to generate URL")
        // Export to file and share
        Task {
            if let finalRoom = try? await roomBuilder.capturedRoom(from: captureRoomData) {
                if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let url = directory.appendingPathComponent("Room.usdz")
                    try finalRoom.export(to: url)
                    self.url = url
                    print("Successful Export URL for model")
                    print(url)
                    uploadUSDZFile(fileURL: url)
                }
            }
        }
    }
    
    func uploadUSDZFile(fileURL: URL) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let fileRef = storageRef.child("usdz_files/Room.usdz")
        
        // Upload the file to the path "usdz_files/Room.usdz"
        _ = fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            guard error == nil else {
                // Handle error
                print("Error uploading file: \(error!)")
                return
            }
            // File uploaded successfully
            print("USDZ file uploaded successfully")
            
            // Fetch the download URL
            fileRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    // Handle error
                    print("Error getting download URL: \(error!)")
                    return
                }
                // Download URL obtained successfully
                print("Download URL: \(downloadURL)")
            }
        }
    }
    
    /// Start a session
    func startSession() {
        captureView.captureSession.run(configuration: sessionConfig)
    }
    
    /// Stops a session
    func stopSession() {
        captureView.captureSession.stop()
    }

}

/// A SwiftUI compatible view for Scan Room View
struct ScanRoomViewRepresentable: UIViewRepresentable {
    
    /// Get capture view
    func makeUIView(context: Context) -> RoomCaptureView {
        ScanRoomController.instance.captureView
    }
    
    /// Update the view when needed
    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
        
    }
}
