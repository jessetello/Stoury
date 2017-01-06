//
//  DataManager.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 12/11/16.
//  Copyright © 2016 jt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth

class DataManager {
    
    static let sharedInstance = DataManager()
    let ref = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    
    typealias DataHandler = (_ success:Bool, _ data:[TSStoury]) -> Void

    func getUserFeed(completion: @escaping DataHandler) {
        ref.child("posts")
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            if let posts = snapshot.value {
                print(posts)
               // completion(true, posts)
            }
        })
    }
    
    func createUser(user:FIRUser, username:String) {
        ref.child("users").child(user.uid).setValue(["username": username])
        //ref.child("users/\(user.uid)/username").setValue(username)
    }
}
