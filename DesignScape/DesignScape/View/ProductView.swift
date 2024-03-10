//
//  ProductView.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/21/24.
//

import SwiftUI

struct ProductView: View {
    @StateObject var viewModel = ProductViewModel()
    
    var id: String
    
    var body: some View {
        VStack {
            if let product = viewModel.product {
                // Display product information
                Image("product1")
                .frame(width: 200, height: 200)
                .padding()
                
                Text(product.name)
                    .font(.title)
                    .padding()
                
                Text("$\(product.price)")
                    .font(.headline)
                    .padding()
                
                Text(product.description)
                    .padding()
                
                Spacer()
            } else {
                // Show loading indicator or error message
                ProgressView()
                    .onAppear {
                        viewModel.getProduct(id: id)
                    }
            }
        }
        .navigationTitle("Product Details")
    }
}

#Preview {
    ProductView(id: "uQHEfRFfaznBBksD02Ps")
}
