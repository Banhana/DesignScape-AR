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
                let returnedUserData = try await AuthenticationController.shared.createUser(email: email, password: password, name: name)
                // Print success message and user data upon successful sign-up
                print("Sign-up Success")
                print(returnedUserData)
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
    }
}

