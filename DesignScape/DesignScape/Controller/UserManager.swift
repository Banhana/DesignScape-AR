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
    let photoURL: String?
}

final class UserManager{
    static let shared = UserManager()
    private init(){}
    
    func createNewUser(auth: AuthDataResultModel) async throws {
        // Define the data to be stored in the Firestore document
        var userData: [String: Any] = [
            "uid": auth.uid,
            "email": auth.email,
//            "name": name,
            // Add more user data as needed
        ]
        
        if let email = auth.email{
            userData["email"] = email
        }
        if let photoURL = auth.photoURL {
            userData["photo_URL"] = photoURL
        }
        
        // Set the user document in Firestore using the UID as the document ID
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(), let userId = data["uid"] as? String else {
            throw URLError(.badServerResponse)
        }
        

        let email = data["email"] as? String
        let photoURL = data["photo_url"] as? String
        
        return DBUser(userId: userId, email: email, photoURL: photoURL )
    }
}
