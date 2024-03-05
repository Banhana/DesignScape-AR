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
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var saveUsername = false
    @State private var isPasswordHidden = true
    @State private var isSignedIn = false // Add state variable to track account creation
    
    var body: some View {
        ZStack {
            Image("background-chairs")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack{
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            ZStack(alignment: .center) {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color.grey.opacity(0.5))
                                    .frame(width: 32, height: 32)
                                Image("arrow-back")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 12)
                            }
                        }
                        .padding(.top)
                        .padding(.trailing, 16)
                        .foregroundColor(.white)
                        .edgesIgnoringSafeArea(.horizontal)
                    }
                    
                    Text("Sign In")
                        .font(.custom("Merriweather-Regular", size: 40))
                        .foregroundColor(.white)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(radius: 3)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        TextField("Email", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(
                                Font.custom("Cambay-Regular", size: 16)
                            )
                            .padding(.horizontal)
                        
                        HStack {
                            SecureField("Password", text: $password)
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
                        
                        HStack {
                            Spacer()
                            Text("Forgot username or password?")
                                .foregroundColor(.grey)
                                .bold()
                        }
                        .padding(.trailing)
                    }
                    .padding()
                }
                .padding(.horizontal, 120)
                .frame(width: .infinity, height: 309)
                
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
