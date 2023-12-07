import Firebase

class DataController: ObservableObject {
    @Published var items: [Item] = []
    
    let db = Firestore.firestore()
    
    /// Fetch data from Firebase
    func fetchData(){
        db.collection("testing").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let documents = querySnapshot?.documents {
                    self.items = documents.compactMap { document in
                        let id = document.documentID
                        let name = document.data()["name"] as? String ?? ""
                        return Item(id: id, name: name)
                    }
                }
                print("Fetch completed!")
            }
        }
    }
    
    /// Add new data to Firebase
    func addData(name: String) {
        db.collection("testing").addDocument(data: [
            "name": name
        ]) { err in
          if let err = err {
            print("Error adding document: \(err)")
          } else {
            print("Document added")
          }
        }
    }
}
