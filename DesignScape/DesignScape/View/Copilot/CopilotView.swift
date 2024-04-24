//
//  CopilotView.swift
//  DesignScape
//
//  Created by Y Nguyen on 4/23/24.
//

import SwiftUI
import FirebaseStorage

class UserSelection: ObservableObject {
    @Published var room: StorageReference?
    @Published var roomType: String?
    @Published var style: String?
    
    init() {}
}

struct CopilotView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background {
                    Image("copilot-background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                }
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                /// Heading
                Rectangle()
                    .foregroundColor(.clear)
                    .background() {
                        VStack {
                            H1Text(title: "Copilot")
                                .padding()
                                .padding(.top, 100)
                            BodyText(text: "Pick a style and let DesignScape Copilot design your dream space.")
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .edgesIgnoringSafeArea(.horizontal)
                    }
                    .background(LinearGradient(gradient: Gradient(colors: [.white, .clear]), startPoint: .top, endPoint: .bottom))
                    .frame(maxHeight: 500)
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                Spacer()
                
                /// Continue button
                HStack(alignment: .center, spacing: 10) {
                    NavigationLink(destination: CopilotRoomsView()) {
                        PrimaryButton(text: "CONTINUE", willSpan: true)
                    }
                }
                .padding(.horizontal, 50)
            }
        }
        .customNavBar()
    }
}

/// View to pick rooms
struct CopilotRoomsView: View {
    @State private var usdzFiles: [StorageReference] = []
    @State var userManager = UserManager.shared
    @StateObject var userSelection = UserSelection()
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            /// Main Contents
            BodyText(text: "Choose a room")
            
            VStack {
                HStack{
                    Text("Rooms")
                        .font(
                            Font.custom("Merriweather-Regular", size: 20)
                        )
                    Spacer()
                }
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(usdzFiles, id: \.self) { fileRef in
                        // get file ref
                        NavigationLink(destination: CopilotRoomTypesView().environmentObject(userSelection)) {
                            VStack (alignment: .center, spacing: 4){
                                AsyncModelThumbnailView(fileRef: fileRef)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(fileRef.name)
                                        .font(
                                            Font.custom("Cambay-Regular", size: 12)
                                        )
                                        .foregroundColor(Color("AccentColor"))
                                }
                            }
                            .padding([.horizontal, .top])
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }// navigationlink
                        .onTapGesture {
                            userSelection.room = fileRef
                        }
                    }
                }
                Spacer()
            }
            .onAppear(perform: {
                userManager.fetchRooms { usdzFiles in
                    self.usdzFiles = usdzFiles
                }
            })
        }
        .padding(.top, 10)
        .padding([.leading, .trailing], 40)
        .padding(.bottom, 20)
        //        .customNavBar()
    }
} // CopilotRoomsView

/// View to pick room type
struct CopilotRoomTypesView: View {
    @EnvironmentObject var userSelection: UserSelection
    
    var body: some View {
        var rooms = ["Dining Room", "Bedroom", "Livingroom", "Kitchen", "Bathroom", "Office"]
        
        VStack(alignment: .center, spacing: 10) {
            /// Main Contents
            BodyText(text: "Choose a room type")
            
            VStack {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(rooms.indices, id: \.self) { index in
                        let room = rooms[index]
                        NavigationLink(destination: CopilotStyleView().environmentObject(userSelection)) {
                            VStack(alignment: .center, spacing: 4) {
                                Image("room\(index + 1)")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 156, height: 226)
                                    .cornerRadius(8)
                                    .overlay(
                                        Text(room)
                                            .font(
                                                Font.custom("Cambay-Regular", size: 14)
                                            )
                                            .padding(.horizontal, 8)
                                            .foregroundColor(.black)
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(8)
                                            .offset(x: 8, y: 8),
                                        alignment: .topLeading
                                    )
                            }
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        } // navigationlink
                        .onTapGesture {
                            userSelection.roomType = room
                        }
                    }
                }
                .padding()
            }
        }
        .padding(.top, 60)
        .padding([.leading, .trailing], 10)
        .padding(.bottom, 20)
    }
} // CopilotRoomsTypeView



/// View to pick room type
struct CopilotStyleView: View {
    @EnvironmentObject var userSelection: UserSelection
    
    var body: some View {
        var styles = ["Mid-Century Modern", "Traditional", "Comtemporary", "Coastal", "Bohemian", "Farmhouse"]
        
        VStack(alignment: .center, spacing: 10) {
            /// Main Contents
            BodyText(text: "Choose a design style")
            
            VStack {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(styles.indices, id: \.self) { index in
                        let style = styles[index]
                        NavigationLink(destination: CopilotGenerateView().environmentObject(userSelection)) {
                            VStack(alignment: .center, spacing: 4) {
                                Image("style\(index + 1)")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 156, height: 226)
                                    .cornerRadius(8)
                                    .overlay(
                                        Text(style)
                                            .font(
                                                Font.custom("Cambay-Regular", size: 14)
                                            )
                                            .padding(.horizontal, 8)
                                            .foregroundColor(.black)
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(8)
                                            .offset(x: 8, y: 8),
                                        alignment: .topLeading
                                    )
                            }
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }// navigationlink
                        .onTapGesture {
                            userSelection.style = style
                        }
                    }
                }
                .padding()
            }
        }
        .padding(.top, 60)
        .padding([.leading, .trailing], 10)
        .padding(.bottom, 20)
    }
} // CopilotRoomsView


struct CopilotGenerateView: View {
    @EnvironmentObject var userSelection: UserSelection

    var body: some View {
        /// Continue button
        VStack {
            HStack(alignment: .center, spacing: 10) {
                NavigationLink(destination: CopilotRoomsView()) {
                    PrimaryButton(text: "REGENERATE", willSpan: true)
                }
            }
            .padding(.horizontal, 50)
        }
        .onAppear {
            print("User Selection:")
            print("Room: \(userSelection.room)")
            print("Room Type: \(userSelection.roomType)")
            print("Style: \(userSelection.style)")
        }
    }
}


#Preview {
    NavigationStack{
        CopilotView()
//        CopilotRoomsView()
//        CopilotRoomTypesView()
//        CopilotStyleView()
    }
}
