//
//  ContentView.swift
//  DesignScape
//
//  Created by Tony Banh on 12/4/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct ContentView: View {
    let fileURLs: URL =
        URL(string: "https://firebasestorage.googleapis.com/v0/b/designscape-5d27c.appspot.com/o/products%2Fbisou-accent-chair.usdz?alt=media&token=4264ca44-3065-49fe-bce7-2136e08d4300")!
    let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("file")
    @State var isDownloadComplete = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("QuickLook Preview")
                //            if isDownloadComplete == true {
                ////                QuickLookPreviewController(url: destinationURL)
                ////                    .frame(height: 400) // Adjust the frame size as desired
                //            }
                NavigationLink(destination: WebView(url: fileURLs)) {
                    Text("View")
                }
                
            }
//            .task {
//                downloadFile(from: fileURLs, to: destinationURL)
//            }
        }
    }
    
    
    func downloadFile(from downloadURL: URL, to destinationURL: URL) {
        let storageRef = Storage.storage().reference(forURL: downloadURL.absoluteString)
        storageRef.write(toFile: destinationURL) { url, error in
            if let error = error {
                print("Error downloading file: \(error)")
                return
            }
            print("File downloaded successfully")
            isDownloadComplete = true
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
