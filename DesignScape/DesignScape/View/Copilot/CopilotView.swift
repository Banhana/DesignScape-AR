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
    @Published var roomType: RoomType?
    @Published var style: RoomStyle?
    
    init() {}
}

enum RoomType: String, CaseIterable {
    case diningroom = "Dining Room"
    case bedroom = "Bedroom"
    case livingroom = "Livingroom"
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case office = "Office"
}

enum RoomStyle: String, CaseIterable {
    case midCenturyModern = "Mid-Century Modern"
    case traditional = "Traditional"
    case comtemporary = "Comtemporary"
    case coastal = "Coastal"
    case bohemian = "Bohemian"
    case farmhouse = "Farmhouse"
}

struct CopilotView: View {
    @StateObject var userSelection = UserSelection()
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
                        NavigationLink(value: "") {
                            PrimaryButton(text: "CONTINUE", willSpan: true)
                        }
                    }
                    .padding(.horizontal, 50)
                }
            }
            .navigationDestination(for: String.self) { _ in
                CopilotRoomsView().environmentObject(userSelection)
            }
            .navigationDestination(for: StorageReference.self) { fileRef in
                CopilotRoomTypesView().environmentObject(userSelection)
                    .onAppear(){
                        userSelection.room = fileRef
                        print("Room: \(String(describing: userSelection.room))")
                    }
            }
            .navigationDestination(for: RoomType.self) { roomType in
                CopilotStyleView().environmentObject(userSelection)
                    .onAppear(){
                        userSelection.roomType = roomType
                        print("Room: \(String(describing: userSelection.roomType))")
                    }
            }
            .navigationDestination(for: RoomStyle.self) { roomStyle in
                CopilotGenerateView().environmentObject(userSelection)
                    .onAppear(){
                        userSelection.style = roomStyle
                        print("Room: \(String(describing: userSelection.style))")
                    }
            }
//        .customNavBar()
    }
}

/// View to pick rooms
struct CopilotRoomsView: View {
    @State private var usdzFiles: [StorageReference] = []
    @State var userManager = UserManager.shared
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            /// Main Contents
            BodyText(text: "Choose a room")
            
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(usdzFiles, id: \.self) { fileRef in
                            // get file ref
                            NavigationLink(value: fileRef) {
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
        .padding(.top, 10)
        .padding([.leading, .trailing], 40)
        .padding(.bottom, 20)
                .customNavBar()
    }
} // CopilotRoomsView

/// View to pick room type
struct CopilotRoomTypesView: View {
    @EnvironmentObject var userSelection: UserSelection
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            /// Main Contents
            BodyText(text: "Choose a room type")
            
            VStack {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(RoomType.allCases, id: \.self) { roomType in
                        NavigationLink(value: roomType) {
                            VStack(alignment: .center, spacing: 4) {
                                Image(roomType.rawValue)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 156, height: 226)
                                    .cornerRadius(8)
                                    .overlay(
                                        Text(roomType.rawValue)
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
                    ForEach(RoomStyle.allCases, id: \.self) { style in
                        NavigationLink(value: style) {
                            VStack(alignment: .center, spacing: 4) {
                                Image(style.rawValue)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 156, height: 226)
                                    .cornerRadius(8)
                                    .overlay(
                                        Text(style.rawValue)
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
            print("Room: \(String(describing: userSelection.room))")
            print("Room Type: \(String(describing: userSelection.roomType))")
            print("Style: \(String(describing: userSelection.style))")
        }
    }
}


#Preview {
//    NavigationStack{
//        CopilotView()
////        CopilotRoomsView()
////        CopilotRoomTypesView()
////        CopilotStyleView()
//    }
    MainView()
}
