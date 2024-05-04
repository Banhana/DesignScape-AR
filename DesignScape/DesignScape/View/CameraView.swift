//
//  CameraView.swift
//  DesignScape
//
//  Created by Tony Banh on 2/1/24.
//

import SwiftUI

// UI for our AR scene for object placement
struct CameraView: View{
    // List to hold the model names
    @State private var modelNames: [String] = []
    @StateObject var viewModel = ProductViewModel()
    
    var body: some View{
        ARViewRepresentable()
            .onAppear {
                viewModel.getAllProducts()
            }
            .ignoresSafeArea()
        // Requires iOS 15+ for .overlay
            .overlay(alignment: .bottom) {
                ScrollView(.horizontal) {
                    HStack {
                        Button {
                            ARManager.shared.actionStream.send(.removeAllAnchors)
                        } label: {
                            // Trashcan image to delete all the placed objects
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.regularMaterial)
                                .cornerRadius(16)
                        }
                        // Puts all model images into buttons
                        ForEach(viewModel.products, id: \.self) { product in
                            Button {
                                // get local file URL
                                if let modelURL = URL(string: product.modelURL) {
                                    
                                    viewModel.downloadModelFile(from: modelURL)
//                                    { result in
//                                        switch result {
//                                        case .success(let localFileUrl):
//                                            self.localFileUrl = localFileUrl
//                                        case .failure(let error):
//                                            print("Error downloading file: \(error)")
//                                        }
//                                    }
                                }
                                
//                                ARManager.shared.actionStream.send(.placeObject(modelLocalUrl: self.localFileUrl))
                            } label: {
                                AsyncImage(url: URL(string: product.imageURL)){
                                    image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
//                                    .resizable()
//                                    .frame(width: 40, height: 40)
//                                    .padding()
//                                    .background(.regularMaterial)
//                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                }
            }
    }
}

struct CameraView_Preview: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
