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
    // Local URL after download from model url
    @State private var thumbnail: UIImage?
    @State var showingBottomSheet = true
    
    var body: some View{
        ZStack{
            ARViewRepresentable()
                .onAppear {
                    viewModel.getAllProducts()
                }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingBottomSheet) {
            bottom
                .presentationDetents([.height(200), .medium, .large])
                .presentationDragIndicator(.visible)
//                .presentationBackground(.ultraThinMaterial)
                .presentationCornerRadius(44)
                .presentationContentInteraction(.scrolls)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(200)))
                .interactiveDismissDisabled()
//                    .overlay(RoundedRectangle(cornerRadius: 44,style: .continuous).stroke(lineWidth: 0.5).fill(Color.white))
        }
            
    }
    
    var bottom: some View{
        VStack (alignment: .center){
            HStack{
                Text("Livingroom")
                    .bold()
                Spacer()
                Text("Chair")
                    
            }
            .foregroundStyle(.regularMaterial)
            .font(.system(size: 15))
            .padding(.horizontal)
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
            
            ScrollView(.vertical) {
                VStack {
//                    Button {
//                        ARManager.shared.actionStream.send(.removeAllAnchors)
//                    } label: {
//                        // Trashcan image to delete all the placed objects
//                        Image(systemName: "trash")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40, height: 40)
//                            .padding()
//                            .background(.regularMaterial)
//                            .cornerRadius(16)
//                    }
                    // Puts all model images into buttons
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(viewModel.products, id: \.self) { product in
                            if let modelURL = URL(string: product.modelURL) {
                                AsyncThumbnail(modelURL: modelURL, viewModel: viewModel)
                            }
                        }
                    }
                    
                }
                .padding()
            }
        }
        .padding(.top)
        .padding(.horizontal)
    }
}

struct AsyncThumbnail: View {
    @State var thumbnail: UIImage?
    @State private var localFileUrl: URL?

    let modelURL: URL
    let viewModel: ProductViewModel
    
    var body: some View {
        Button {
            // get local file URL
            viewModel.downloadModelFile(from: modelURL)
            { result in
                switch result {
                case .success(let localFileUrl):
                    self.localFileUrl = localFileUrl
                    print(localFileUrl)
                    DispatchQueue.main.async {
                        ARManager.shared.actionStream.send(.placeObject(modelLocalUrl: localFileUrl))
                    }
                case .failure(let error):
                    print("Error downloading file: \(error)")
                }
            }
        } label: {
            if let thumbnail = thumbnail{
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else{
                ProgressView()
            }
        }
        .onAppear{
            Task{
                await thumbnail = viewModel.productThumbnail(modelURL: modelURL)
            }
        }
    }
}

struct CameraView_Preview: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
