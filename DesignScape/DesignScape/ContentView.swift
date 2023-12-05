//
//  ContentView.swift
//  DesignScape
//
//  Created by Tony Banh on 12/4/23.
//

import SwiftUI
import Firebase
//import FirebaseFirestore

struct ContentView: View {
    @State private var inputText: String = ""
//    @State private var displayedText: String = ""
//    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Text("DesignScape")
            DataTableView()
            TextField("Enter data here", text: $inputText)
            Button("Submit") {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }
            .padding()
            Button("Refresh") {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }
        }
//        .onAppear(){
//            FirebaseApp.configure()
//        }
    }
}

#Preview {
    ContentView()
}
