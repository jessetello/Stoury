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
    let postRef = FIRDatabase.database().reference()
    let userRef = FIRDatabase.database().reference()

    let storage = FIRStorage.storage()
    var recentPosts = [Stoury]()
    var userPosts = [Stoury]()
    
    typealias DataHandler = (_ success:Bool, _ data:[Stoury]) -> Void

    func getUserFeed(completion: @escaping DataHandler) {
//        ref.child("user-posts")
//        ref.observe(FIRDataEventType.value, with: { (snapshot) in
//            if let posts = snapshot.value {
//                print(posts)
//               // completion(true, posts)
//            }
//        })
    }
    
    func getRecentPosts(completion: @escaping DataHandler) {
        //search database all posts for most recent
        postRef.child("posts")
        postRef.observe(FIRDataEventType.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            if let posts = dict["posts"] as? [String : [String : Any]] {
                print(posts)
                for (key, value) in posts {
                    let info = value as [String: Any]
                    let stoury = Stoury(userID: key, userName: info[""] as? String, title:  info[""] as? String, location:  info[""] as? String, length:  info[""] as? Double, date:  info[""] as? Date, category:  info[""] as? String)
                    self.recentPosts.append(stoury)
                }
                completion(true, self.recentPosts)
            }
            completion(false, self.recentPosts)
        })
    }
    
    func createUser(user:FIRUser, username:String) {
        userRef.child("users").child(user.uid).setValue(["username": username])
        //ref.child("users/\(user.uid)/username").setValue(username)
    }
}
