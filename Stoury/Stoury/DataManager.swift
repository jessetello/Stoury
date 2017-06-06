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
    let newPostRef = FIRDatabase.database().reference(withPath: "posts")
    let postRef = FIRDatabase.database().reference(withPath: "posts").child("posts")
    let userPostRef = FIRDatabase.database().reference(withPath: "posts").child("user-posts/\(FIRAuth.auth()?.currentUser?.uid ?? "")")
    let userInfoRef = FIRDatabase.database().reference(withPath: "users")
    
    let storage = FIRStorage.storage()
    
    var recentPosts = [Stoury]()
    var userPosts = [Stoury]()
    
    typealias DataHandler = (_ success:Bool) -> Void

    func getUserFeed(completion: @escaping DataHandler) {
        self.userPosts.removeAll()
        userPostRef.observe(FIRDataEventType.value, with: { (snapshot) in
            if let posts = snapshot.value as? [String : [String : Any]] {
                print(posts)
                    for (key, value) in posts {
                        let stoury = Stoury(userID: value["uid"] as? String, userName: value["user"] as? String, title: value["title"] as? String, location: value["location"] as? String, coordinates: value["coordinates"] as? [String:Double], stateOrCountry: value["countryOrState"] as? String, length: value["length"] as? Double, created: 0, category: "Travel", url: value["url"] as? String, id: key, comments: nil)
                            self.userPosts.append(stoury)
                    }
            }
            self.userPosts.sort { $0.created > $1.created }
            completion(true)
        })
    }
    
    func getRecentPosts(completion: @escaping DataHandler) {
        self.recentPosts.removeAll()
        postRef.queryLimited(toFirst: 25).observe(FIRDataEventType.value, with: { (snapshot) in
            self.recentPosts.removeAll()
            if let posts = snapshot.value as? [String : [String : Any]] {
                for (key, value) in posts {
                    var comments = [Stoury]()
                    if let commentValue = value["comments"] as? [String : [String : Any]] {
                        for (commentKey, commentValue) in commentValue {
                            let com = Stoury(userID: commentValue["uid"] as? String, userName: commentValue["user"] as? String, title: commentValue["title"] as? String, location: commentValue["location"] as? String, coordinates: commentValue["coordinates"] as? [String:Double], stateOrCountry: commentValue["countryOrState"] as? String, length: commentValue["length"] as? Double, created: 0, category: "Travel", url: commentValue["url"] as? String, id: commentKey, comments: nil)
                                comments.append(com)
                        }
                    }
                    let stoury = Stoury(userID: value["uid"] as? String, userName: value["user"] as? String, title: value["title"] as? String, location: value["location"] as? String, coordinates: value["coordinates"] as? [String:Double], stateOrCountry: value["countryOrState"] as? String, length: value["length"] as? Double, created: 0, category: "Travel", url: value["url"] as? String, id: key, comments: comments)
                    self.recentPosts.append(stoury)
                }
            }
            self.recentPosts.sort { $0.created > $1.created }
            completion(true)
            
        })
    }

    func createUser(user:FIRUser, userName:String) {
        let key = self.userInfoRef.child("user-names").child(userName).key
        self.userInfoRef.updateChildValues(["user-names/\(key)":""])
    }
    
    func checkUserNames(userName:String, completion:@escaping DataHandler) {
        userInfoRef.child("user-names").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(userName) {
                completion(false)
            }
            else {
                completion(true)
            }
        })
    }
    
    func flagStouryPost(stoury:Stoury) {
        newPostRef.child("flaggedPosts").childByAutoId().setValue(["stouryID":stoury.id,"userName":stoury.userName,"userID":stoury.userID,"videoURL":stoury.url])
    }
}
