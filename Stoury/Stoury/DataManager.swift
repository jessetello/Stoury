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
    
    let postRef = FIRDatabase.database().reference(withPath: "posts")
    let userPostRef = FIRDatabase.database().reference(withPath: "user-posts")
    let userInfoRef = FIRDatabase.database().reference(withPath: "users")

    let storage = FIRStorage.storage()
    
    
    
    var recentPosts = [Stoury]()
    var userPosts = [Stoury]()
    
    typealias DataHandler = (_ success:Bool, _ data:[Stoury]) -> Void

    func getUserFeed(completion: @escaping DataHandler) {
//        userRef.observe(FIRDataEventType.value, with: { (snapshot) in
//            if let userPosts = snapshot.value {
//                print(posts)
//                completion(true, posts)
//            }
//        })
    }
    
    func getRecentPosts(completion: @escaping DataHandler) {
        //search database all posts for most recent
        postRef.observe(FIRDataEventType.value, with: { (snapshot) in
            if let posts = snapshot.value as? [String : [String : Any]] {
                if let postsArray = posts["posts"] {
                    for (key, value) in postsArray {
                        print(key)
                        print(value)
//                        self.recentPosts.append(stoury)
                    }
                }
                
            }
        })
    }
    
    func createUser(user:FIRUser, username:String) {
        userInfoRef.child("users").child(user.uid).setValue(["username": username])
        //ref.child("users/\(user.uid)/username").setValue(username)
    }
    
    

}
