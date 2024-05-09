//
//  Blur+View.swift
//  DesignScape
//
//  Created by Y Nguyen on 5/6/24.
//

import SwiftUI

extension View{
    /// Custom View Modifier
    func blurredSheet<Content: View> (_ style: AnyShapeStyle, show: Binding<Bool>, onDismiss: @escaping ()->(), @ViewBuilder content: @escaping ()->Content)->some View{
        self
            .sheet(isPresented: show, onDismiss: onDismiss) {
                content()
                    .background(RemoveBackgroundColor())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background{
                        Rectangle()
                            .fill(style)
                            .ignoresSafeArea(.container, edges: .all)
                    }
            }
    }
}

/// Helper View
fileprivate struct RemoveBackgroundColor: UIViewRepresentable{
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async{
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
}
