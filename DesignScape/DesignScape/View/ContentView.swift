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
        VStack {
            Text("DesignScape")
            DataTableView(items: dataController.items)
                .onAppear() {
                    dataController.fetchData()
                }
            TextField("Enter data here", text: $inputText)
                .padding()
            Button("Submit") {
                dataController.addData(name: inputText)
            }
            .padding()
            Button("Refresh") {
                dataController.fetchData()
            }
        }
    }
}

struct ContentView_Preview: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
