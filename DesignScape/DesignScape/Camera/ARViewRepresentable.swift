//
//  ARView Representable.swift
//  DesignScape
//
//  Created by Tony Banh on 2/1/24.
//

import SwiftUI

struct ARViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> CustomARView {
        return CustomARView()
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
        // Blank
    }
}
let modelNames = ["Acoustic_Guitar", "Antique_Phone", "Bed_06", "Bed_with_lamp"]
