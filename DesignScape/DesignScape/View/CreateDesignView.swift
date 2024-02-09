//
//  CreateScanView.swift
//  DesignScape
//
//  Created by Minh Huynh on 1/30/24.
//

import SwiftUI

struct CreateDesignView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Create a new design")
                .font(.custom("Merriweather-Regular", size: 40))
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
            HStack(alignment: .center, spacing: 10) {
                NavigationLink(destination: ScanRoomView()) {
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
                HStack(alignment: .center, spacing: 10) {
                    Text("LIVE SCAN")
                        .font(
                            Font.custom("Cambay-Regular", size: 14)
                                .weight(.semibold)
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .padding([.top], 3)
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
