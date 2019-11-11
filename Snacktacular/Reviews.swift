//
//  Reviews.swift
//  Snacktacular
//
//  Created by Jess on 11/11/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray: [Review] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentID != "" else {
            return
        }
        
        db.collection("spots").document(spot.documentID).collection("reviews").addSnapshotListener { (QuerySnapshot, Error) in
            guard Error == nil else {
                print("*** ERROR: adding the snapshot listener failed.")
                return completed()
            }
            self.reviewArray = []
            for document in QuerySnapshot!.documents {
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewArray.append(review)
            }
            completed()
        }
    }
}
