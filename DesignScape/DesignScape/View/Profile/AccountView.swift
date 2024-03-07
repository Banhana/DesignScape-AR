//
//  AccountView.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/14/24.
//

import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        ZStack{
            Color(.grey).edgesIgnoringSafeArea(.horizontal).opacity(0.2)
            VStack(alignment: .leading){
                Text("Welcome")
                    .font(.custom("Merriweather-Regular", size: 40))
                
                // if user is logged in, only displays the Projects & Favorites folder
                if viewModel.isUserLoggedIn {
                    Text("\(viewModel.name)")
                        .font(.custom("Merriweather-Regular", size: 36))
                    
                    // Button to sign out
                    Button(action: {
                        viewModel.signout()
                        NavigationLink(destination: AccountView()){}
                    }) {
                        Text("SIGN OUT")
                            .font(
                                Font.custom("Cambay-Regular", size: 14)
                                    .weight(.semibold)
                            )
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .padding([.top], 3)
                    }
                    .padding(10)
                    .background(Color("Brown"))
                    .cornerRadius(8)
                    
                } else {
                    Text("Sign in or create an account to access your designs and to manage your favorites")
                        .font(Font.custom("Cambay-Regular", size: 16))
                    
                    HStack(alignment: .center, spacing: 10) {
                        NavigationLink(destination: SignInView()) {
                            Text("SIGN IN")
                                .font(
                                    Font.custom("Cambay-Regular", size: 14)
                                        .weight(.semibold)
                                )
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .bottom)
                                .padding([.top], 3)
                        }
                    }
                    .padding(10)
                    .background(Color("Brown"))
                    .cornerRadius(8)
                    
                    HStack(alignment: .center, spacing: 10) {
                        NavigationLink(destination: SignUpView()) {
                            Text("CREATE AN ACCOUNT")
                                .font(
                                    Font.custom("Cambay-Regular", size: 14)
                                        .weight(.semibold)
                                )
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .bottom)
                                .padding([.top], 3)
                        }
                    }
                    .padding(10)
                    .background(Color("Grey").opacity(0.5))
                    .cornerRadius(8)
                }
                
                Text("MY PROJECTS")
                    .font(Font.custom("Cambay-Bold", size: 16))
                    .padding(.top)
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "folder")
                        .foregroundColor(.black)
                        .frame(width: 20, height: 20)
                    NavigationLink(destination: AccountView()) {
                        Text("Access my saved designs")
                            .font(
                                Font.custom("Cambay-Regular", size: 14)
                            )
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top], 3)
                    }
                    Spacer()
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                        .frame(width: 20, height: 20)
                }
                .padding(10)
                .background(Color(.white))
                
                
                Text("FAVORITES")
                    .font(Font.custom("Cambay-Bold", size: 16))
                    .padding(.top)
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                        .frame(width: 20, height: 20)
                    NavigationLink(destination: AccountView()) {
                        Text("Explore designs, products and add your favorites")
                            .font(
                                Font.custom("Cambay-Regular", size: 14)
                            )
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top], 3)
                    }
                    
                    Spacer()
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                        .frame(width: 20, height: 20)
                }
                .padding(10)
                .background(Color(.white))
                
                Spacer()
            }
            .padding(20)
            .padding(.horizontal, 28)
        } // zstack
        .onAppear {
            // Check user's login status when the view appears
            viewModel.checkUserLoggedIn()
            // Retrieve user's login status from Firebase Authentication
        }
    }
}

#Preview {
    AccountView()
}