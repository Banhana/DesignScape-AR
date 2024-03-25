//
//  UserRoomsView.swift
//  DesignScape
//
//  Created by Minh Huynh on 3/24/24.
//

import SwiftUI
import Firebase
import FirebaseStorage

//struct UserRoomsView:View {
//    var body: some View {
//        Text("Hello")
//    }
//}
struct UserRoomsView: View {
    @State private var usdzFiles: [StorageReference] = []
    
    var body: some View {
        VStack {
            Button("Upload USDZ") {
                // Upload USDZ file
                let usdzFileURL = URL(fileURLWithPath: "file:///var/mobile/Containers/Data/Application/8BAE7D6C-EBF4-4A3A-B0EC-25F444B1FBE1/Documents/Room.usdz")
                uploadUSDZFile(fileURL: usdzFileURL)
            }
            
            // Display list of USDZ files with image previews
            List(usdzFiles, id: \.self) { fileRef in
                AsyncImageView(fileRef: fileRef)
            }
            .onAppear(perform: fetchUSDZFiles)
        }
    }
    
    func uploadUSDZFile(fileURL: URL) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let fileRef = storageRef.child("usdz_files/Room\(usdzFiles.count + 1).usdz")
        
        // Upload the file to the path "usdz_files/RoomX.usdz"
        let _ = fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            guard error == nil else {
                // Handle error
                print("Error uploading file: \(error!)")
                return
            }
            // File uploaded successfully
            print("USDZ file uploaded successfully")
            
            // Refresh the list of files
            fetchUSDZFiles()
        }
    }
    
    func fetchUSDZFiles() {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("usdz_files")
        
        // List all files under "usdz_files" folder
        storageRef.listAll { result, error in
            guard error == nil else {
                // Handle error
                print("Error listing files: \(error!)")
                return
            }
            
            // Get the list of file references
            usdzFiles = result!.items
        }
    }
}

//
struct AsyncImageView: View {
    @ObservedObject var thumbnailLoader: ThumbnailLoader
    let fileRef: StorageReference
    
    init(fileRef: StorageReference) {
        self.fileRef = fileRef
        thumbnailLoader = ThumbnailLoader(fileRef: fileRef)
    }
    
    var body: some View {
        VStack {
            if let image = thumbnailLoader.thumbnail {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 500, height: 500)
                RoomViewRepresentable(sceneView: thumbnailLoader.sceneView!)
                    .frame(width: 500, height: 500)
            } else {
                // Placeholder or loading indicator
                Text("Loading...")
            }
            Text(fileRef.name)
        }
        .onAppear(perform: thumbnailLoader.load)
    }
}

#Preview {
    NavigationView {
        UserRoomsView()
    }
}
