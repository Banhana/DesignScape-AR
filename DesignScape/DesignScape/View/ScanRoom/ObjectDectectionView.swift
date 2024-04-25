//
//  ObjectDectectionView.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/29/24.
//

import SwiftUI

/// Object Detection View
struct ObjectDectectionView: View {
    var body: some View {
        ObjectDetectionViewRepresentable()
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
    }
}

#Preview {
    ObjectDectectionView()
}
