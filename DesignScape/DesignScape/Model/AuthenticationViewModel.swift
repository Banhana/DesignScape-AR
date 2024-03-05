//
//  AuthenticationViewModel.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/18/24.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {
    // Published properties for email and password
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var isUserLoggedIn = false
    
    init() {
        checkUserLoggedIn() // Check user login status when the view model is initialized
    }
    
    // Function to check if a user is logged in
    func checkUserLoggedIn() {
        Task {
            do {
                // Attempt to get authenticated user using the shared AuthenticationController
                let returnedUserData = try AuthenticationController.shared.getAuthenticatedUser()
                // User is logged in
                isUserLoggedIn = true
                name = try await UserManager.shared.getUser(userId: returnedUserData.uid).name ?? ""
                print(returnedUserData)
            } catch {
                // User is not logged in
                isUserLoggedIn = false
                // Handle the error thrown by getAuthenticatedUser()
                print("Error checking user login status: \(error)")
            }
        }
    }
    
    // Function to handle user sign-up
    func signup() async throws {
        // Check if email and password are not empty
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            // Print message if email or password is empty
            print("No name, email, or password found")
            return
        }
        
        // Perform sign-up task asynchronously
        Task {
            do {
                // Attempt to create a new user using provided email and password
                let authDataResult = try await AuthenticationController.shared.createUser(email: email, password: password, name: name)
                try await UserManager.shared.createNewUser(auth: authDataResult, name: name)
                
                // Print success message and user data upon successful sign-up
                print("Sign-up Success")
                print(authDataResult)
            } catch {
                // Print error message if sign-up fails
                print("Sign-up Error \(error)")
            }
        }
    }
    
    // Function to handle user sign-in
    func signin() async throws {
        // Check if email and password are not empty
        guard !email.isEmpty, !password.isEmpty else {
            // Print message if email or password is empty
            print("No email or password found")
            return
        }
        
        // Perform sign-in task asynchronously
        Task {
            do {
                // Attempt to sign in user using provided email and password
                let returnedUserData = try await AuthenticationController.shared.signIn(email: email, password: password)
                // Print success message and user data upon successful sign-in
                print("Sign-in Success")
                print(returnedUserData)
            } catch {
                // Print error message if sign-in fails
                print("Sign-in Error \(error)")
            }
        }
    } // signin
    
    // Function to handle user sign-out
    func signout() {
        do {
            try AuthenticationController.shared.signOut()
        } catch {
            // Handle sign-out error
            print("Sign-out Error \(error)")
        }
    } // signout
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationController.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
