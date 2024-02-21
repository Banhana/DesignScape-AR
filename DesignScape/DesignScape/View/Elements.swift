//
//  Elements.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/20/24.
//

import SwiftUI

/// Custom Close Button
struct CloseButton: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        /// Close button
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }){
            ZStack(alignment: .center){
                Color("Grey")
                    .opacity(0.5)
                Image("cross")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .scaledToFit()
            }
            .frame(width: 32, height: 32)
            .cornerRadius(8)
        }
        .padding(.trailing)
    }
}

/// Custom Back Button
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
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
        .padding(.leading)
    }
}

#Preview {
    BackButton()
}
