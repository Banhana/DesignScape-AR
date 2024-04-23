//
//  CreateScanView.swift
//  DesignScape
//
//  Created by Minh Huynh on 1/30/24.
//

import SwiftUI

/// Create Design View allows scanning a new room for a model or live furniture placement
struct CreateDesignView: View {
    @State var isActive = false
    var body: some View {
        VStack(alignment: .leading) {
            /// Heading
            H1Text(title: "Create a new design")
            
            /// Main image
            ZStack(alignment: .topLeading) {
                ImageFrame(image: "create-new-image")
                BodyText(text: "Start by scanning your room or picking a template")
                    .padding(30)
            }
            .padding(.bottom, 30)
            
            /// Create Room button
            HStack(alignment: .center, spacing: 10) {
//                NavigationLink(isActive: $isActive, destination: GuidedTourScanRoomView(title: "Get Started", instruction: "Scan your room and design in an immersive experience that brings your vision to life", nextDestinationView: 1, isActive: $isActive)) {
//                    PrimaryButton(text: "CREATE ROOM", willSpan: true)
//                }
                NavigationLink(destination: GuidedTourScanRoomView(title: "Get Started", instruction: "Scan your room and design in an immersive experience that brings your vision to life", nextDestinationView: 1, isActive: $isActive), isActive: $isActive) {
                    PrimaryButton(text: "CREATE ROOM", willSpan: true)
                }
            }
            
            /// Live Scan button
            HStack(alignment: .center, spacing: 10) {
                NavigationLink(destination: CameraView()){
                    PrimaryButton(text: "LIVE SCAN", willSpan: true)
                }
            }
            
            /// Object Detection button
            HStack(alignment: .center, spacing: 10) {
                NavigationLink(destination: ObjectDectectionView()){
                    PrimaryButton(text: "OBJECT DETECTION", willSpan: true)
                }
            }
            
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
