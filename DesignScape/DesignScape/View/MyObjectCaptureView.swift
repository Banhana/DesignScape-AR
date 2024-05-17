//
//  ObjectCaptureView.swift
//  DesignScape
//
//  Created by Tony Banh on 4/27/24.
//

import RealityKit
import SwiftUI
#if !targetEnvironment(simulator)
import USDZScanner
#endif

@available(iOS 17.0, *)
struct MyObjectCaptureView: View {
    @State var isScanObjectPresenting = true
    @State var url: URL?
    
    var body: some View {
    #if !targetEnvironment(simulator)
        VStack {
            if let url {
                Text(url.absoluteString)
            }
        }
        
        .sheet(isPresented: $isScanObjectPresenting, content: {
            USDZScanner { url in
                self.url = url
                isScanObjectPresenting = false
            }
        })
    #endif
    }
}
