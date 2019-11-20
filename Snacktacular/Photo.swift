//
//  Photo.swift
//  Snacktacular
//
//  Created by Jess on 11/11/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String // universal unique identifier
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        // convert a photo.image to a data type so it can be saved
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("*** ERROR: could not convert image to data format")
            return completed(false)
        }
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        documentUUID = UUID().uuidString //generate unique ID to use for photo image's name
        // create a red to upload storage to spot.documentID's folder.
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        storageRef.putData(photoData)
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetadata) { metadata, error in
            guard error == nil else {
                print("ANGRY! ERROR during .putData storage upload!")
                return
            }
            print("HAPPY! No issue with .putData storage upload!")
        }
        
        uploadTask.observe(.success) { (snapshot) in
            // create dictionary using the data we want to save
            let dataToSave = self.dictionary
            // either create new doc at docUUID or updat ethe existing doc with that name.
                let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
                ref.setData(dataToSave) { (error) in
                    if let error = error {
                        print("ERROR Updating document.")
                        return completed(false)
                    } else {
                        print("--- Documented updated with document ID.")
                        completed(true)
                    }
                }
            }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("** ERROR: upload task for file \(self.documentUUID) failed in spit \(spot.documentID)")
            }
            return completed(false)
        }

    }

}
