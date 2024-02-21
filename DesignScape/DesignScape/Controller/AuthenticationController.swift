//
//  AuthenticationController.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/18/24.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

struct AuthDataResultModel {
    var user: User
//    let uid: String
//    let email: String?
//    let photoURL: String?
//    
//    init(user: User) {
//        self.user = user.user
//        self.uid = user.uid
//        self.email = user.email
//        self.photoURL = user.photoURL?.absoluteString
//    }
}

final class AuthenticationController {
    static let shared = AuthenticationController()
    private init() {}
    
    // get existing user - sync - get value from local sdk
    func getAuthenticatedUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else {
            // throw actual errors here please
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    // creates user - async
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Access the newly created user's UID
            let uid = authDataResult.user.uid
            
        // Define the data to be stored in the Firestore document
        let userData: [String: Any] = [
            "email": email,
            // Add more user data as needed
        ]
                
        // Reference to the users collection in Firestore
        let usersCollection = Firestore.firestore().collection("users")
            
        // Set the user document in Firestore using the UID as the document ID
        try await usersCollection.document(uid).setData(userData)
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // signs in
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // signs out
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

