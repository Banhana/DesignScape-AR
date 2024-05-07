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
    @State private var localFileUrl: URL?
    @State var showingBottomSheet = false
    
    var body: some View{
        ZStack{
            ARViewRepresentable()
                .onAppear {
                    viewModel.getAllProducts()
                }
                
            
            Button {
                showingBottomSheet.toggle()
            } label: {
                PrimaryButton(text: "Add Furniture")
            }
            .padding(15)
            .sheet(isPresented: $showingBottomSheet) {
                bottom
                    .presentationDetents([.height(200), .medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.thinMaterial)
                    .presentationCornerRadius(44)
                    .presentationContentInteraction(.scrolls)
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(200)))
//                    .overlay(RoundedRectangle(cornerRadius: 44,style: .continuous).stroke(lineWidth: 0.5).fill(Color.white))

            }

        }
            .ignoresSafeArea()
    }
    
    var bottom: some View{
        VStack (alignment: .center){
            HStack{
                Text("Livingroom")
                    .foregroundColor(.white)
                    .bold()
                Spacer()
                Text("Chair")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Divider()
           .background(Color.white)
           .frame(height: 4)
           .shadow(radius: 5)
//            Divider()
//           .background(Color.grey)
//           .frame(height: 3)

            
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
                            }
                            
                        } label: {
                            AsyncImage(url: URL(string: product.imageURL)){
                                image in
                                image.resizable()
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .background(.clear)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

struct CameraView_Preview: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
