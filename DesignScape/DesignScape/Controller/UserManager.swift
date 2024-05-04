//
//  UserManager.swift
//  DesignScape
//
//  Created by Y Nguyen on 3/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

struct DBUser{
    let userId: String
    let email: String?
    let name: String?
    
}

final class UserManager: ObservableObject {
    static let shared = UserManager()
    private var db = DataController.shared.db
    init(){}
    
    func createNewUser(auth: AuthDataResultModel, name: String) async throws {
        // Define the data to be stored in the Firestore document
        var userData: [String: Any] = [
            "uid": auth.uid,
            "email": auth.email ?? "",
            "name": name,
            // Add more user data as needed
        ]
        
        if let email = auth.email{
            userData["email"] = email
        }
        //        iflet name = name {
        userData["name"] = name
        //        }
        
        // Set the user document in Firestore using the UID as the document ID
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(), let userId = data["uid"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        
        let email = data["email"] as? String
        let name = data["name"] as? String
        
        return DBUser(userId: userId, email: email, name: name )
    }
    
    func addToFavorites(userId: String, productUID: String) async throws {
        let favoritesRef = db.collection("users").document(userId).collection("favorites")
        
        // Add product UID to favorites collection
        try await favoritesRef.document(productUID).setData(["productUID": productUID])
    }
    
    func getFavorites(userId: String, completion: @escaping ([String]?, Error?) -> Void) {
        let favoritesRef = db.collection("users").document(userId).collection("favorites")
        var products: [String] = []
        
        favoritesRef.getDocuments { snapshot, error in
            if let error = error {
                // Call completion handler with error if an error occurs
                completion(nil, error)
            } else {
                // Iterate through each document in the collection
                for document in snapshot!.documents {
                    // Try to decode document data into Product model
                    if let product = document.data()["productUID"] as? String {
                        // Append the decoded product to the products array
                        products.append(product)
                    }
                }
                // Call completion handler with products if no error occurs
                completion(products, nil)
            }
        }
    }

}

/// User Rooms Manager
extension UserManager {
    /// Add a new room to database and bid it to the user
    func addToRooms(userId: String, fileRef: String) async throws {
        let roomsRef = Firestore.firestore().collection("users").document(userId).collection("rooms")
        
        // Add product UID to favorites collection
        try await roomsRef.document().setData(["fileRef": fileRef])
    }
    
    /// Fetch All Rooms
    func fetchRooms(completion: @escaping (([StorageReference]) -> Void)) {
        Task {
            do {
                let authDataResult = try AuthenticationController.shared.getAuthenticatedUser()
                let roomsRef = Firestore.firestore().collection("users").document(authDataResult.uid).collection("rooms")
                let documents = try await roomsRef.getDocuments()
                
                // Array to store storageRefs
                let storage = DataController.shared.storage
                var storageRefs: [StorageReference] = []
                
                // Iterate through documents and extract fileRef from each document
                for document in documents.documents {
                    if let fileRef = document.data()["fileRef"] as? String {
                        storageRefs.append(storage.reference().child(fileRef))
                    }
                }
                // Get the list of file references
                completion(storageRefs)
            } catch {
                print("Error fetchRooms")
            }
        }
    }
    
    func downloadRoomAsync(fileRef: StorageReference) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            downloadRoom(fileRef: fileRef) { url in
                continuation.resume(returning: url)
            }
        }
    }
    
    func downloadRoom(fileRef: StorageReference, onSuccess: @escaping ((URL) -> Void)) {
        // Create a temporary file URL
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("usdz")
        
        // Download the USDZ file to the temporary file URL
        fileRef.write(toFile: tempFileURL) { result in
            switch result {
            case .success(let url):
                onSuccess(url)
            case .failure(_):
                print("Error downloading USDZ")
            }
        }
    }
}
