//
//  SignInView.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/14/24.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel = AuthenticationViewModel.instance
    @State private var saveUsername = false
    @State private var isPasswordHidden = true
    @State private var isSignedIn = false // Add state variable to track account creation
    
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
                Text("Sign In")
                    .font(.custom("Merriweather-Regular", size: 40))
                    .foregroundColor(.white)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(radius: 3)
                    
                    VStack(alignment: .leading, spacing: 20) {
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
                            Button(action: {
                                self.isPasswordHidden.toggle()
                            }) {
                                Image(systemName: isPasswordHidden ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: {
                            self.saveUsername.toggle()
                        }) {
                            HStack {
                                Image(systemName: saveUsername ? "checkmark.square" : "square")
                                    .foregroundColor(.grey)
                                Text("Save username")
                                    .foregroundColor(.grey)
                            }
                        }
                        
                        Button(action: {
                            Task{
                                do {
                                    try await viewModel.signin()
                                    isSignedIn = true
                                    self.presentationMode.wrappedValue.dismiss()
                                } catch {
                                    
                                }
                            }
                        }) {
                            Spacer()
                            
                            HStack (alignment: .center) {
                                
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.black)
                                Text("Sign In")
                                    .foregroundColor(.black)
                                    .font(.headline)
                            }
                            .padding()
                            .background(Color.grey.opacity(0.3))
                            .cornerRadius(8)
                            Spacer()
                        }
                        
                        HStack (alignment: .center){
                            Spacer()
                            Text("Forgot username or password?")
                                .foregroundColor(.grey)
                                .bold()
                            Spacer()
                        }
                    }
                    .padding()
                }
//                .padding(.horizontal, 120)
                .frame(height: 309)
                
                Spacer()
            }
            .padding()
            
        }
        
        // NavigationLink to navigate to AccountView when the account is successfully created
        .background(
            //            self.presentationMode.wrappedValue.dismiss()
            NavigationLink(destination: AccountView(), isActive: $isSignedIn) {
                EmptyView()
            }
                .hidden()
            
        )
        
    }
}

#Preview {
    SignInView()
}
