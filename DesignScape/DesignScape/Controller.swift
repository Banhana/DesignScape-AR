import Firebase

class Controller{
    let db = Firestore.firestore()
    
    init(){
    }
    
    func fetchData(){
        db.collection("testing").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
}
