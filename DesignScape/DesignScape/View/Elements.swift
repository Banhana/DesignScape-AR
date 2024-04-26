//
//  Elements.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/20/24.
//

import SwiftUI

/// Enables swipe back functionality when use custom navigation bar
extension UINavigationController: UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

/// Custom Navigation Bar
extension View {
    func customNavBar(isTitleHidden: Bool = false, isCloseButtonHidden: Bool = false) -> some View {
        self.navigationTitle(isTitleHidden ? "" : "DesignScape AR")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton(), trailing: isCloseButtonHidden ? nil : CloseButton())
    }
}

/// PrimaryButton
struct PrimaryButton: View {
    /// Contents
    var text: String
    var image: String?
    var systemImage: String?
    
    /// Determines if the button will span horizontally to all its available spaces
    var willSpan: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if let image = image {
                Image(image)
                    .frame(width: 16, height: 16)
            }
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            
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
        .frame(maxWidth: willSpan ? .infinity: nil, alignment: .center)
        .background(Color("Brown"))
        .cornerRadius(8)
    }
}

/// GreyButton
struct GreyButton: View {
    /// Contents
    var text: String
    var systemImage: String?
    
    /// Determines if the button will span horizontally to all its available spaces
    var willSpan: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
            }
            
            Text(text)
                .font(
                    Font.custom("Cambay-Regular", size: 14)
                        .weight(.semibold)
                )
                .foregroundColor(.black)
                .frame(alignment: .bottom)
                .padding([.top], 3)
        }
        .padding(10)
        .frame(maxWidth: willSpan ? .infinity: nil, alignment: .center)
        .background(Color.grey.opacity(0.5))
        .cornerRadius(8)
    }
}
/// GoldButton
struct GoldButton: View {
    /// Contents
    var text: String
    var systemImage: String?
    
    /// Determines if the button will span horizontally to all its available spaces
    var willSpan: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            
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
        .frame(maxWidth: willSpan ? .infinity: nil, alignment: .center)
        .background(Color.accentColor)
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

/// Body text
struct BodyText: View {
    var text: String
    var body: some View {
        Text(text)
            .font(Font.custom("Cambay-Regular", size: 16))
    }
}

/// Image frame
struct ImageFrame: View {
    var image: String
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .background(
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
            .cornerRadius(24)
            .clipped()
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
    NavigationStack {
        VStack {
            H1Text(title: "Heading 1")
            BodyText(text: "Body")
            ImageFrame(image: "closing-door")
            PrimaryButton(text: "NEXT", image: "arrow-right")
            PrimaryButton(text: "START CAPTURE", systemImage: "camera")
            GoldButton(text: "FINISH", systemImage: "checkmark")
        }
        .padding()
        .customNavBar()
    }
}
