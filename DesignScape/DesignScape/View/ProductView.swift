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
        VStack (alignment: .leading){
            if let product = viewModel.product {
                // Display product information
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                .padding()
                
                Text(product.name.capitalized)
                    .font(
                        Font.custom("Merriweather-Regular", size: 22)
                    )
                    .padding(.vertical)
                
                BodyText(text: "$\(String(format: "%.2f", product.price))")
                
                Text("Description")
                    .font(
                        Font.custom("Merriweather-Regular", size: 22)
                    )
                    .padding(.vertical)
                
                BodyText(text: product.description)
                    
                
                Button(action: {
                    
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
        .navigationTitle("Product Details")
        .customNavBar()
        .padding(25)
    }
}

#Preview {
    NavigationStack{
        ProductView(id: "uQHEfRFfaznBBksD02Ps")
    }
    
}
