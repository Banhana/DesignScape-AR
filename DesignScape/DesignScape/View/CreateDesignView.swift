//
//  CreateScanView.swift
//  DesignScape
//
//  Created by Minh Huynh on 1/30/24.
//

import SwiftUI

/// Create Design View allows scanning a new room for a model or live furniture placement
struct CreateDesignView: View {
    var body: some View {
        VStack(alignment: .leading) {
            /// Heading
            Text("Create a new design")
                .font(.custom("Merriweather-Regular", size: 40))
            
            /// Main image
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(
                        Image("create-new-image")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    )
                    .cornerRadius(8)
                    .padding(.bottom, 20)
                Text("Start by scanning your room or picking a template")
                    .font(Font.custom("Cambay-Regular", size: 16))
                    .frame(width: 200, alignment: .topLeading)
                    .padding(30)
            }
            
            /// Create Room button
            HStack(alignment: .center, spacing: 10) {
                NavigationLink(destination: GuidedTourScanRoomView(title: "Get Started", instruction: "Scan your room and design in an immersive experience that brings your vision to life", nextDestinationView: 1)) {
                    Text("CREATE ROOM")
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
            .background(Color("Brown"))
            .cornerRadius(8)
            
            /// Live Scan button
            HStack(alignment: .center, spacing: 10) {
                NavigationLink(destination: CameraView()){
                    Text("LIVE SCAN")
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
            .background(Color("Brown"))
            .cornerRadius(8)
            
        }
        .padding(10)
        .padding([.leading, .trailing], 40)
        .padding(.bottom, 20)
    }
}

struct CreateScanView_Previews: PreviewProvider {
    static var previews: some View {
        CreateDesignView()
            .environment(\.font, Font.custom("Merriweather-Regular", size: 14))
    }
}
