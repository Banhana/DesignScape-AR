//
//  SignInView.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/14/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var agreeTerms = false
    
    var body: some View {
        ZStack {
            Image("background-chairs")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
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
                        
                        Button(action: {
                            Task{
                                do {
                                    try await viewModel.signup()
                                } catch {
                                    
                                }
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
                .frame(width: .infinity, height: 280)
                
                Spacer()
            }
            .padding()
            
        }


    }
}

#Preview {
    SignUpView()
}
