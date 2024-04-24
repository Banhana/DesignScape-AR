//
//  ScanRoomView.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/8/24.
//

import SwiftUI
import AVKit

/// Scan Room View allows acess to camera to outline a 3D model of a room
struct ScanRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    
    /// RoomController instance
    @ObservedObject var roomController = ScanRoomController.instance
    /// Condition when scanning is completed
    @State private var doneScanning: Bool = false
    
    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                /// Camera View
                ScanRoomViewRepresentable().onAppear(perform: {
                    roomController.startSession()
                })
                .onDisappear(perform: {
                    roomController.stopSession()
                })
                .ignoresSafeArea()
                
                /// Share sheet
                if doneScanning, let url = roomController.url {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .font(.title)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(), trailing: DoneButton)
    }
    
    /// Finish Scan Button
    var DoneButton: some View {
        VStack {
            /// Done button
            if doneScanning == false {
                Button(action: {
                    roomController.stopSession()
                    self.doneScanning = true
                }, label: {
                    ZStack(alignment: .center){
                        Color("Grey")
                            .opacity(0.5)
                        Text("Done")
                            .font(Font.custom("Cambay-Regular", size: 14)
                                .weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.top, 3)
                    }
                    .frame(width: 60, height: 32)
                    .cornerRadius(8)
                })
            } else {
                CloseButton()
            }
        }
    }
}

/// An optional view depends on which view number is passed into
struct NextGuidedTourView: View {
    /// Next view is numberd by an integer
    var nextView: Int
    
    var body: some View {
        /// Step 1
        if nextView == 1 {
            GuidedTourImageScanRoomView(title: "Step 1", instruction: "\u{2022} Remove all personal items\n\u{2022} Ensure room is empty of people", nextDestinationView: 2, image: "personal-items")
        /// Step 2
        } else if nextView == 2 {
            GuidedTourImageScanRoomView(title: "Step 2", instruction: "\u{2022} Close all doors\n\u{2022} Move back to get a great angle", nextDestinationView: 3, nextBtnText: "START SCANNING", image: "closing-door")
        /// Final Step
        } else if nextView == 3 {
            ScanRoomView()
        }
    }
}

/// Getting Started View shows an overview of how Scanning a Room looks like
struct GuidedTourScanRoomView: View {
    /// Main contents
    var title: String
    var instruction: String
    
    /// Contents of next button
    var nextDestinationView: Int
    var nextBtnText: String = "NEXT"
    
    /// Load an overview video
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "roomplan-large", withExtension: "mp4")!)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            /// Main Contents
            H1Text(title: self.title)
            BodyText(text: self.instruction)
            
            /// Video player
            Rectangle()
                .foregroundColor(.clear)
                .background(
                    VideoPlayer(player: player)
                        .aspectRatio(5/2, contentMode: .fill
                                    )
                        .onAppear {
                            self.player.play()
                        }
                )
                .cornerRadius(24)
                .padding(.vertical, 15)
                .clipped()
            
            /// Next button to next view
            HStack {
                Spacer()
                NavigationLink(destination: NextGuidedTourView(nextView: self.nextDestinationView)) {
                    PrimaryButton(text: nextBtnText, image: "arrow-right")
                }
            }
        }
        .padding(10)
        .padding([.leading, .trailing], 40)
        .padding(.bottom, 20)
        .customNavBar()
    }
}

/// A temporary view to display image instead of video
struct GuidedTourImageScanRoomView: View {
    /// Main contents
    var title: String
    var instruction: String
    
    /// Contents of next button
    var nextDestinationView: Int
    var nextBtnText: String = "NEXT"
    
    /// Load an overview video
    var image: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            /// Main Contents
            H1Text(title: self.title)
            BodyText(text: self.instruction)
            
            /// Image
            ImageFrame(image: image)
            
            /// Next button to next view
            HStack {
                Spacer()
                NavigationLink(destination: NextGuidedTourView(nextView: self.nextDestinationView)) {
                    PrimaryButton(text: nextBtnText, image: "arrow-right")
                }
            }
        }
        .padding(10)
        .padding([.leading, .trailing], 40)
        .padding(.bottom, 20)
        .customNavBar()
    }
}

#Preview {
    NavigationView {
//        GuidedTourScanRoomView(title: "Get Started", instruction: "Scan your room and design in an immersive experience that brings your vision to life", nextDestinationView: 1)
//            .navigationBarTitleDisplayMode(.inline)
        ScanRoomView()
            .onAppear {
                ScanRoomController.instance.url =  URL(string: "www.google.com")!
            }
    }
}
