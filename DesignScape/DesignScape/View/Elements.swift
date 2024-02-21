//
//  Elements.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/20/24.
//

import SwiftUI

/// PrimaryButton
struct PrimaryButton: View {
    var image: String
    var text: String
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(image)
                .frame(width: 16, height: 16)
            
            Text(text)
                .font(
                    Font.custom("Cambay-Regular", size: 14)
                        .weight(.semibold)
                )
                .foregroundColor(.white)
                .frame(alignment: .bottom)
                .padding([.top], 3)
        }
        .padding(10)
        .frame(alignment: .center)
        .background(Color("Brown"))
        .cornerRadius(8)
    }
}

/// Heading 1
struct H1Text: View {
    var title: String
    var body: some View {
        Text(self.title)
            .font(.custom("Merriweather-Regular", size: 40))
    }
}

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
    VStack {
        H1Text(title: "Heading 1")
        PrimaryButton(image: "arrow-right", text: "NEXT")
        HStack {
            BackButton()
            CloseButton()
        }
    }
}
