//
//  ViewModel.swift
//  DesignScape
//
//  Created by Y Nguyen on 12/5/23.
//

import Foundation

class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []

    func addSampleItem() {
            let newItem = Item(id: "1", name: "Sample Item")
            // Add the new item to the local array
            items.append(newItem)
        }
    
    func fetchDataFromFirebase() {
        // Fetch data from Firebase and populate 'items'
    }
    
    
}
