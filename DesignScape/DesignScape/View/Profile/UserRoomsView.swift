//
//  UserRoomsView.swift
//  DesignScape
//
//  Created by Minh Huynh on 3/24/24.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct UserRoomsView: View {
    @State private var usdzFiles: [StorageReference] = []
    @State var userManager = UserManager.shared
    
    var body: some View {
        VStack {
            HStack{
                Text("Rooms")
                    .font(
                        Font.custom("Merriweather-Regular", size: 20)
                    )
                Spacer()
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(usdzFiles, id: \.self) { fileRef in
                        NavigationLink(destination: RoomLoaderView(fileRef: fileRef)) {
                            VStack (alignment: .center, spacing: 4){
                                AsyncModelThumbnailView(fileRef: fileRef)
                                    .overlay(alignment: .topLeading) {
                                        Text(fileRef.name)
                                            .font(Font.custom("Cambay-Regular", size: 14))
                                            .padding(.horizontal, 8)
                                            .padding(.top, 3)
                                            .foregroundColor(.black)
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(8)
                                            .offset(x: 8, y: 8)
                                    }
                            }
                            .padding([.horizontal, .top])
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                Spacer()
            }
        }
        .onAppear(perform: {
            userManager.fetchRooms { usdzFiles in
                self.usdzFiles = usdzFiles
            }
        })
        .padding()
        .padding()
        .customNavBar()
    }
}

struct AsyncModelThumbnailView: View {
    @ObservedObject var thumbnailLoader: ThumbnailLoader
    let fileRef: StorageReference
    
    init(fileRef: StorageReference) {
        self.fileRef = fileRef
        thumbnailLoader = ThumbnailLoader(fileRef: fileRef)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if let image = thumbnailLoader.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 156, height: 226)
                    .cornerRadius(8)
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: thumbnailLoader.load)
    }
}

#Preview {
    NavigationView {
        UserRoomsView()
    }
}
