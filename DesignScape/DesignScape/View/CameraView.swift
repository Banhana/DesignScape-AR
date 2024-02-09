//
//  CameraView.swift
//  DesignScape
//
//  Created by Tony Banh on 2/1/24.
//

import SwiftUI

struct CameraView: View{
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
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(.regularMaterial)
                                .cornerRadius(16)
                        }
                        
                        ForEach(modelNames, id: \.self) { modelName in
                            Button {
                                ARManager.shared.actionStream.send(.placeObject(modelName: modelName))
                            } label: {
                                Image(modelName)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                }
            }
    }
}

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
