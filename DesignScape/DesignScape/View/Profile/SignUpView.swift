//
//  SignInView.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/14/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel = AuthenticationViewModel.instance
    @State private var agreeTerms = false
    @State private var isAccountCreated = false // Add state variable to track account creation
    @State private var passwordError = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background {
                    Image("background-chairs")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                }
            VStack {
                ZStack{
                    Text("Create an Account")
                        .font(.custom("Merriweather-Regular", size: 40))
                        .foregroundColor(.white)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(radius: 3)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        TextField("Name", text: $viewModel.name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(
                                Font.custom("Cambay-Regular", size: 16)
                            )
                            .padding(.horizontal)
                        
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(
                                Font.custom("Cambay-Regular", size: 16)
                            )
                            .padding(.horizontal)
                        
                        HStack {
                            SecureField("Password", text: $viewModel.password)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(
                                    Font.custom("Cambay-Regular", size: 16)
                                )
                                .foregroundColor(.black)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            self.agreeTerms.toggle()
                        }) {
                            HStack {
                                Image(systemName: agreeTerms ? "checkmark.square" : "square")
                                    .foregroundColor(.grey)
                                Text("I agree to the Terms & Conditions")
                                    .foregroundColor(.grey)
                                    .font(
                                        Font.custom("Cambay-Regular", size: 12)
                                    )
                            }
                        }
                        if passwordError {
                            Text("Password must be at least 6 characters long.")
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            if viewModel.password.count >= 6 {
                                passwordError = false
                                Task {
                                    do {
                                        try await viewModel.signup()
                                        // Set the state variable to true after successful signup
                                        isAccountCreated = true
                                        self.presentationMode.wrappedValue.dismiss()
                                    } catch {
                                        // Handle error if any
                                    }
                                }
                            } else {
                                passwordError = true
                            }
                        }) {
                            Spacer()
                            
                            HStack (alignment: .center) {
                                
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.black)
                                Text("Sign Up")
                                    .foregroundColor(.black)
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.grey.opacity(0.3))
                            .cornerRadius(8)
                            Spacer()
                        }
                    }
                    .padding()
                }
                .padding(.horizontal, 120)
                .frame(height: 280)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SignUpView()
}
