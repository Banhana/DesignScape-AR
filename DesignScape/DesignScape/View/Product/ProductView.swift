//
//  ProductView.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/21/24.
//

import SwiftUI

struct ProductView: View {
    @StateObject var viewModel = ProductViewModel() 
    @State private var isFavorite = false // State to track favorite status
    @StateObject var user = AuthenticationViewModel()
    var id: String
    
    // Preview state
    @State private var showingPreview = false
    // Local URL after download from model url
    @State private var localFileUrl: URL?
    
    var body: some View {
        VStack (alignment: .leading){
            if let product = viewModel.product {
                // Display product information
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                
                HStack {
                    Text(product.name.capitalized)
                        .font(
                            Font.custom("Merriweather-Regular", size: 22)
                        )
                    .padding(.vertical)
                    Spacer()
                    Button(action: {
                        // add product to favorites folder
                        Task {
                            do {
                                try await addFavorite(userId: user.userId, productId: product.id!)
                            } catch {
                                // Handle the error if addFavorite fails
                                print("Failed to add favorite: \(error.localizedDescription)")
                            }
                        }
                    }, label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart") // Change image based on isFavorite state
                            .foregroundColor(isFavorite ? .red : .black) // Change color based on isFavorite state
                            .frame(width: 20, height: 20)
                    })
                }
                

                
                BodyText(text: "$\(String(format: "%.2f", product.price))")
                
                Text("Description")
                    .font(
                        Font.custom("Merriweather-Regular", size: 22)
                    )
                    .padding(.vertical)
                
                BodyText(text: product.description)
                    
                
                Button(action: {
                    if let modelURL = URL(string: product.modelURL) {
                        showingPreview.toggle()
                        viewModel.downloadModelFile(from: modelURL) { result in
                            switch result {
                            case .success(let localFileUrl):
                                self.localFileUrl = localFileUrl
                            case .failure(let error):
                                print("Error downloading file: \(error)")
                            }
                        }
                    }
                }, label: {
                    PrimaryButton(text: "VIEW PRODUCT IN ROOM", willSpan: true)
                })
                
                Spacer()
            } else {
                // Show loading indicator or error message
                ProgressView()
                    .onAppear {
                        viewModel.getProduct(id: id)
                    }
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let localFileUrl = self.localFileUrl {
                ARQuickLookView(url: localFileUrl) { hasDismissed in
                    showingPreview.toggle()
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Product Details")
        .customNavBar()
        .padding(25)
    }
    
    func addFavorite(userId: String, productId: String) async throws{
        isFavorite.toggle()
        try await UserManager.shared.addToFavorites(userId: userId, productUID: productId)
    }
}

#Preview {
    NavigationStack{
        ProductView(id: "uQHEfRFfaznBBksD02Ps")
    }
    
}
