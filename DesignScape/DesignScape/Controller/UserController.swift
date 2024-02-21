//
//  UserController.swift
//  DesignScape
//
//  Created by Y Nguyen on 2/20/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserController{
    func createNewUser(auth: AuthDataResultModel){
        var userData: [String: Any] = {
            "user_id" = userId
        }
        Firestore.firestore().collection("users").document(userId).setData(<#T##documentData: [String : Any]##[String : Any]#>)
    }
}
