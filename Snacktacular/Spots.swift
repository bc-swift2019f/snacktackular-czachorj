//
//  Spots.swift
//  Snacktacular
//
//  Created by Jess on 11/1/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Spots {
    var spotArray = [Spot]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("spots").addSnapshotListener { (QuerySnapshot, Error) in
            guard Error == nil else {
                print("*** ERROR: adding the snapshot listener failed.")
                return completed()
            }
            self.spotArray = []
            for document in QuerySnapshot!.documents {
                let spot = Spot(dictionary: document.data())
                spot.documentID = document.documentID
                self.spotArray.append(spot)
            }
            completed()
        }
    }
}
