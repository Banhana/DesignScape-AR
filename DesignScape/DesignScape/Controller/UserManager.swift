//
//  UserManager.swift
//  DesignScape
//
//  Created by Y Nguyen on 3/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

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
