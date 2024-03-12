//
//  Product.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/21/24.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var price: Double
    var description: String
//    var imageURL: String
}
