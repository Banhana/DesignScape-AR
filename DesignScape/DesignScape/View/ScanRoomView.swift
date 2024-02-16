//
//  ScanRoomView.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/8/24.
//

import SwiftUI
import AVKit

struct ScanRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var roomController = ScanRoomController.instance
    
    @State private var doneScanning: Bool = false
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            ScanRoomViewRepresentable().onAppear(perform: {
                roomController.startSession()
            })
            .ignoresSafeArea()
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    ZStack(alignment: .center){
                        Color("Grey")
                            .opacity(0.5)
                        Image("arrow-back")
                            .frame(width: 16, height: 12)
                    }
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
                }
                Spacer()
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
                }
                //                ZStack(alignment: .center){
                //                    Color("Grey")
                //                        .opacity(0.5)
                //                    Image("cross")
                //                        .resizable()
                //                        .frame(width: 16, height: 16)
                //                        .scaledToFit()
                //                }
                //                .frame(width: 32, height: 32)
                //                .cornerRadius(8)
            }
            .padding(30)
        }
        .navigationBarBackButtonHidden()
    }
}

struct GuidedTourScanRoomView: View {
    var title: String
    var instruction: String
    var nextBtnText: String = "NEXT"
    @State var player = AVPlayer(url: Bundle.main.url(forResource: "roomplan-large", withExtension: "mp4")!)
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text(self.title)
                .font(.custom("Merriweather-Regular", size: 40))
            Text(self.instruction)
                .font(.custom("Cambay-Regular", size: 16))
            ZStack(alignment: .topLeading) {
                VideoPlayer(player: player)
                    .aspectRatio(5/2, contentMode: .fill
                    )
                    .onAppear {
                        self.player.play()
                    }
                    .frame(width: 300)
                    .cornerRadius(8)
            }
            .padding(.bottom, 20)
            .clipped()
            
            HStack {
                Spacer()
                NavigationLink(destination: CameraView()) {
                    HStack(alignment: .center, spacing: 10) {
                        Image("arrow-right")
                            .frame(width: 16, height: 16)
                        
                        Text("NEXT")
                            .font(
                                Font.custom("Cambay-Regular", size: 14)
                                    .weight(.semibold)
                            )
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .padding([.top], 3)
                    }
                }
                .padding(10)
                .frame(width: 87, alignment: .center)
                .background(Color("Brown"))
                .cornerRadius(8)
            }
        }
        .padding(10)
        .padding([.leading, .trailing], 40)
        .padding(.bottom, 20)
    }
}

#Preview {
    GuidedTourScanRoomView(title: "Get Started", instruction: "Scan your room and design in an immersive experience that brings your vision to life")
}
