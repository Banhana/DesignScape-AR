//
//  ContentView.swift
//  DesignScape
//
//  Created by Tony Banh on 12/4/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore


struct ContentView: View {
    var imageURLS: [String] = []
    private var db = DataController.shared.db
    private var storage = DataController.shared.storage
    
    var body: some View {
        
        
        Text("hi")
            .onAppear(perform: {
                print("Start")
                let storageRef = storage.reference().child("products")
                
                storageRef.listAll { result, error in
                    print("Fetch")
                    if let error = error {
                        print("Error listing images: \(error.localizedDescription)")
                    } else {
                        for item in result!.items {
                            item.downloadURL { url, error in
                                if let error = error {
                                    print("Error getting download URL for \(item.name): \(error.localizedDescription)")
                                } else if let url = url {
                                    print("Download URL for \(item.name): \(url.absoluteString)")
                                    // Here you can store the download URL as needed
                                }
                            }
                        }
                        print("Completed")
                    }
                    
                }
            })
//        print("\(storageRef)")
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
