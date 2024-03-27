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
    
    var body: some View{
        ARViewRepresentable()
            .onAppear {
                modelNames = loadModelNamesFromPlist(named: "Furniture")
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
                        Button {
                            ARManager.shared.actionStream.send(.removeLastObject)
                        } label: {
                            // Undo image to undo the last placed objects
                            Image(systemName: "arrow.uturn.backward.circle")
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

// Loads all models into a list from a specified directory
func loadModelNamesFromPlist(named plistName: String) -> [String] {
    // Get the path to the plist file in the asset catalog
    guard let plistPath = Bundle.main.path(forResource: plistName, ofType: "plist") else {
        print("Plist file named \(plistName) not found in the app bundle.")
        return []
    }

    // Load contents of the plist file
    if let modelNames = NSArray(contentsOfFile: plistPath) as? [String] {
        return modelNames
    } else {
        print("Error loading model names from plist file.")
        return []
    }
}

struct CameraView_Preview: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
