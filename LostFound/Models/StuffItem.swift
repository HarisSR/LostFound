import Foundation
import Firebase

struct StuffItem {
    let ref: DatabaseReference?
    let key: String
    let stuffName: String
    let stuffImage: String
    let stuffDescription: String
    let postDate: String
    let storedIn: String
    let addedByUser: String
    var completed: Bool
    var takenBy : String
    let stuffURL: String
    
    init(stuffName: String, stuffImage: String = "", postDate: String, storedIn: String, stuffDescription: String ,addedByUser: String, completed: Bool, key: String = "", stuffURL: String, takenBy: String = "") {
        self.ref = nil
        self.key = key
        self.stuffName = stuffName
        self.stuffImage = stuffImage
        self.postDate = postDate
        self.storedIn = storedIn
        self.stuffDescription = stuffDescription
        self.addedByUser = addedByUser
        self.completed = completed
        self.stuffURL = stuffURL
        self.takenBy = takenBy
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let stuffName = value["stuffName"] as? String,
            let stuffImage = value["stuffImage"] as? String,
            let postDate = value["postDate"] as? String,
            let storedIn = value["storedIn"] as? String,
            let stuffDescription = value["stuffDescription"] as? String,
            let addedByUser = value["addedByUser"] as? String,
            let completed = value["completed"] as? Bool,
            let stuffURL = value["stuffURL"] as? String,
            let takenBy = value["takenBy"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.stuffName = stuffName
        self.stuffImage = stuffImage
        self.postDate = postDate
        self.storedIn = storedIn
        self.stuffDescription = stuffDescription
        self.addedByUser = addedByUser
        self.completed = completed
        self.stuffURL = stuffURL
        self.takenBy = takenBy
    }
    
    func toAnyObject() -> Any {
        return [
            "stuffName": stuffName,
            "stuffImage": stuffImage,
            "stuffDescription": stuffDescription,
            "postDate": postDate,
            "storedIn": storedIn,
            "addedByUser": addedByUser,
            "completed": completed,
            "takenBy" : takenBy,
            "stuffURL" : stuffURL
            
        ]
    }
}
