//
//  FavoritesView.swift
//  DesignScape
//
//  Created by Y Nguyen on 3/12/24.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var auth = AuthenticationViewModel.instance
    @StateObject var productViewModel = ProductViewModel()
    @StateObject var viewModel = UserManager()
    @State private var productUids: [String] = []
    @State private var products: [Product] = []
    var body: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(products, id: \.self) { product in
                    if let product = productViewModel.product {
                        NavigationLink(destination: ProductView(id: product.id!)) {
                            ProductCard(productName: product.name, price: product.price, imageURL: product.imageURL, productId: product.id!)
                        }
                    }
                }
            }
                                .padding()
        }
        .onAppear(perform: {
            // Load favorites when the view appears
            // Call getFavorites with completion handler
            if auth.isUserLoggedIn {
                fetchProducts()
            }
            
        })
        Spacer()
    }
    func fetchProducts() {
        viewModel.getFavorites(userId: auth.userId) { faveProductUids, error in
            if let error = error {
                // Handle the error
                print("Error fetching favorites: \(error.localizedDescription)")
            } else if let faveProductUids = faveProductUids {
                // Handle the retrieved products
                print("Favorites: \(faveProductUids)")
                productUids = faveProductUids
                for productUid in productUids {
                    productViewModel.getProduct(id: productUid) { product in
                        DispatchQueue.main.async {
                            products.append(product)
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    NavigationView {
        FavoritesView()
    }
}
