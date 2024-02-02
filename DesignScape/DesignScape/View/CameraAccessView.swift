//
//  ContentView.swift
//  DesignScape
//
//  Created by Tony Banh on 12/4/23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State private var inputText: String = ""
    
    @ObservedObject var dataController = DataController()
    
    var body: some View {
        ARViewRepresentable()
            .ignoresSafeArea()
    }
}

struct ContentView_Preview: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
