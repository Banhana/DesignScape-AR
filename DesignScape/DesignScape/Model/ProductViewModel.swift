//
//  ProductViewModel.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/21/24.
//

import SwiftUI
import FirebaseFirestore

class ProductViewModel: ObservableObject {
    @Published var product: Product?
    
    private var db = Firestore.firestore()
    
    func getProduct(productId: String) {
        db.collection("products").document(productId).getDocument { snapshot, error in
            if let error = error {
                print("Error getting product: \(error.localizedDescription)")
            } else if let snapshot = snapshot, snapshot.exists {
                do {
                    let product = try snapshot.data(as: Product.self)
                    DispatchQueue.main.async {
                        self.product = product
                    }
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                }
            } else {
                print("Product document does not exist")
            }
        }
    }
}
