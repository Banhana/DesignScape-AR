//
//  ModelView.swift
//  DesignScape
//
//  Created by Minh Huynh on 3/16/24.
//

import SwiftUI

struct ModelView: View {
    var body: some View {
        ModelViewRepresentable()
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    ScanRoomController.instance.onModelReady()
                }
            })
            .ignoresSafeArea()
    }
}

#Preview {
    ModelView()
}
