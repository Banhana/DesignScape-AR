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
                modelNames = loadModelNames(named: "Furniture")
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
func loadModelNames(named directory: String) -> [String] {
    guard let directoryURL = Bundle.main.url(forResource: directory, withExtension: nil) else {
        return []
    }

    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        let modelNames = fileURLs.map { $0.deletingPathExtension().lastPathComponent }
        return modelNames
    } catch {
        print("Error loading model names from directory: \(error)")
        return []
    }
}

struct CameraView_Preview: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
