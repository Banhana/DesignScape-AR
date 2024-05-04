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
                        ForEach(modelNames, id: \.self) { modelName in
                            Button {
                                ARManager.shared.actionStream.send(.placeObject(modelName: modelName))
                            } label: {
                                Image(modelName) 
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .background(.regularMaterial)
                                    .cornerRadius(16)
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
