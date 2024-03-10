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
    @Published var image: UIImage?
    
    private var db = DataController.shared.db
    private var storage = DataController.shared.storage
    
    func getProduct(id: String) {
        db.collection("furnitures").document(id).getDocument { snapshot, error in
            if let error = error {
                print("Error getting product: \(error.localizedDescription)")
            } else if let snapshot = snapshot, snapshot.exists {
                do {
                    let product = try snapshot.data(as: Product.self)
                    DispatchQueue.main.async {
                        self.product = product
//                        self.downloadImage(urlString: product.imageURL ?? "")
                    }
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                }
            } else {
                print("Product document does not exist")
            }
        }
    } // getProduct
    
    private func downloadImage(urlString: String) {
        let storageRef = storage.reference(forURL: urlString)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else if let data = data {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }
    
    // Function to upload image to Firebase Storage and update imageURL
    func uploadImageToStorage(imageData: Data, completion: @escaping (String?) -> Void) {
        let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")

        // Upload the image
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let metadata = metadata, error == nil else {
                print("Error uploading image: \(error?.localizedDescription ?? "")")
                completion(nil)
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url {
                    completion(url.absoluteString)
                }
            }
        }
    }
    
    func saveProduct(product: Product, imageData: Data?, completion: @escaping (Bool) -> Void) {
        if let imageData = imageData {
            // If image data is provided, upload the image to Firebase Storage
            uploadImageToStorage(imageData: imageData) { imageURL in
                if let imageURL = imageURL {
                    var newProduct = product
//                    newProduct.imageURL = imageURL
                    self.saveProductToFirestore(product: newProduct, completion: completion)
                } else {
                    completion(false)
                }
            }
        } else {
            // If no image data is provided, save the product directly to Firestore
            saveProductToFirestore(product: product, completion: completion)
        }
    }
    
    private func saveProductToFirestore(product: Product, completion: @escaping (Bool) -> Void) {
        do {
            let _ = try db.collection("furnitures").addDocument(from: product) { error in
                if let error = error {
                    print("Error adding product to Firestore: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } catch {
            print("Error encoding product: \(error.localizedDescription)")
            completion(false)
        }
    }
}
