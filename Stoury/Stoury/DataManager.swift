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
    
    typealias DataHandler = (_ success:Bool) -> Void

    func getUserFeed(completion: @escaping DataHandler) {
        userPostRef.observe(FIRDataEventType.value, with: { (snapshot) in
            if let posts = snapshot.value as? [String : [String : Any]] {
                if let postsArray = posts["posts"] {
                    for (key, value) in postsArray {
                        print(key)
                        print(value)
                        if let dict = value as? [String:Any] {
                            let stoury = Stoury(userID: dict["uid"] as? String, userName: "", title: dict["title"] as? String, location: dict["location"] as? String, length: 02.00, date: Date.init(), category: "Test", url: dict["url"] as? String)
                            self.recentPosts.append(stoury)
                        }
                    }
                }
            }
            completion(true)
        })
    }
    
    func getRecentPosts(completion: @escaping DataHandler) {
        //search database all posts for most recent
        self.recentPosts.removeAll()
        postRef.observe(FIRDataEventType.value, with: { (snapshot) in
            if let posts = snapshot.value as? [String : [String : Any]] {
                if let postsArray = posts["posts"] {
                    for (_, value) in postsArray {
                        if let dict = value as? [String:Any] {
                            print(dict)
                            let stoury = Stoury(userID: dict["uid"] as? String, userName: dict["user"] as? String, title: dict["title"] as? String, location: dict["location"] as? String, length: dict["length"] as? Double , date: Date.init(), category: "Test", url: dict["url"] as? String)
                            self.recentPosts.append(stoury)
                        }
                    }
                }
               completion(true)
            }
        })
    }
    
    func createUser(user:FIRUser, username:String) {
        userInfoRef.child("users").child(user.uid).setValue(["username": username])
        //ref.child("users/\(user.uid)/username").setValue(username)
    }
    
    

}
