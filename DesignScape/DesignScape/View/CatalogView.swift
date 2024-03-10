//
//  CatalogView.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/4/24.
//

import SwiftUI

struct CatalogView: View {
    @State private var selectedOption = 0
    @State private var rooms = ["Dining Room", "Bedroom", "Livingroom", "Kitchen", "Bathroom", "Office"]
    @State private var furniture = ["Chair", "Sofa", "Desk"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
            VStack{
                ZStack{
                    VStack{
                        // furniture categories
                        FurnitureView(furniture: furniture)
                        
                        // furniture promotion
                        Button(action: {}){
                            PromotionView()
                        }
                        
                        // popular products
                        ProductBannerView()
                        
                        //sale
                        Button(action: {}){
                            SaleView()
                        }
                        
                        // rooms
                        RoomView(rooms: rooms)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
        }
        
    }
}

struct FurnitureView: View{
    var furniture: [String]
    var body: some View{
        VStack(alignment: .leading, content: {
            HStack{
                Text("Furniture")
                    .font(
                        Font.custom("Merriweather-Regular", size: 20)
                    )
                
                Spacer()
                
                Text("See all")
                    .foregroundColor(Color("AccentColor"))
                
                Image("arrow-right-accent")
                    .frame(width: 16, height: 16)
                
            }
            .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<3) { index in
                        FurnitureCard(imageName: "furniture\(index + 1)", category: "\(furniture[index])")
                        
                    }
                }
                .padding(.horizontal) // Add padding around the entire HStack
                Spacer()
            }
        })
    }
}

struct FurnitureCard: View {
    let imageName: String
    let category: String
    
    var body: some View {
        NavigationLink(destination: Text("Furniture category: \(category)")) {
            ZStack (alignment: .leading) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 125, height: 56)
                    .cornerRadius(8)
                
                Text(category)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }
            .padding(2)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

struct ProductBannerView: View {
    var body: some View {
        VStack (alignment: .leading){
            HStack{
                Text("Popular")
                    .font(
                        Font.custom("Merriweather-Regular", size: 20)
                    )
                
                Spacer()
                
                Text("See all")
                    .foregroundColor(Color("AccentColor"))
                
                Image("arrow-right-accent")
                    .frame(width: 16, height: 16)
            }
            .padding()
            
            VStack {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(1..<5) { index in
                        NavigationLink(destination: ProductView(id: "uQHEfRFfaznBBksD02Ps")) {
                            ProductCard(productName: "Product \(index)", price: "\(index * 10)", imageName: "product\(index)", productUID: "uQHEfRFfaznBBksD02Ps")
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                                    .padding()
            }
        }
    }
}

struct ProductCard: View {
    var productName: String
    var price: String
    var imageName: String
    var productUID: String // Add product UID
    
    @State private var isFavorite = false // State to track favorite status
    
    var body: some View {
        VStack (alignment: .leading, spacing: 4){
            Image(imageName)
                .aspectRatio(contentMode: .fill)
                .frame(width: 141, height: 149)
                .cornerRadius(8)
                .overlay(
                    ZStack {
                        Circle()
                            .foregroundColor(Color.white.opacity(0.8))
                            .frame(width: 32, height: 32)
                            .offset(x: 40, y: -40)
                        Image(systemName: "heart")
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                            .offset(x: 40, y: -40)
                    }
                )
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(productName)
                    .font(
                        Font.custom("Cambay-Regular", size: 12)
                    )
                    .foregroundColor(Color("AccentColor"))
                //                    .padding(.bottom, 4)
                Text("$\(price)")
                    .font(
                        Font.custom("Cambay-Bold", size: 14)
                    )
            }
            //            .padding(.vertical)
        }
        .frame(width: 157)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RoomView: View{
    var rooms: [String]
    
    var body: some View{
        VStack(alignment: .leading) {
            Text("Rooms")
                .font(
                    Font.custom("Merriweather-Regular", size: 20)
                )
                .padding(.horizontal)
                .padding(.top)
            
            Text("Furniture for every corner in your home")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<6) { index in
                        RoomCard(roomName: "\(rooms[index])", imageName: "room\(index+1)")
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct RoomCard: View {
    var roomName: String
    var imageName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 127, height: 195)
                .cornerRadius(8)
                .overlay(
                    Text(roomName)
                        .font(
                            Font.custom("Cambay-Regular", size: 14)
                        )
                        .padding(8)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .offset(x: 8, y: 8),
                    alignment: .topLeading
                )
        }
        .frame(width: 127)
        .padding(.trailing, 8)
    }
}

struct PromotionView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Image("sofa")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 335, height: 142)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("High quality sofa started")
                    .font(
                        Font.custom("Cambay-Bold", size: 12)
                    )
                    .foregroundColor(Color("AccentColor"))
                Text("70% off")
                    .font(
                        Font.custom("Cambay-Bold", size: 32)
                    )
                    .foregroundColor(Color("AccentColor"))
                HStack {
                    Text("See all items")
                        .font(
                            Font.custom("Cambay-Bold", size: 12)
                        )
                        .foregroundColor(Color("AccentColor"))
                    Image("arrow-right-accent")
                        .frame(width: 16, height: 16)
                }
            }
            .padding()
        }
    }
}

struct SaleView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Image("chair")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 335, height: 142)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Sale")
                    .font(
                        Font.custom("Cambay-Bold", size: 32)
                    )
                    .foregroundColor(Color("AccentColor"))
                HStack {
                    Text("All chairs up to 70% off")
                        .font(
                            Font.custom("Cambay-Bold", size: 12)
                        )
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding()
        }
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView()
    }
}
