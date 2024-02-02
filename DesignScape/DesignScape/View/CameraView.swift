//
//  CameraView.swift
//  DesignScape
//
//  Created by Tony Banh on 2/1/24.
//

import SwiftUI

struct CameraView: View{
    var body: some View{
        ARViewRepresentable()
            .ignoresSafeArea()
    }
}

struct CameraView_Preview: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
