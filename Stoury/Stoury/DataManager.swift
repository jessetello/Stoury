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
                        let stoury = Stoury(userID: value["uid"] as? String, userName: value["user"] as? String, title: value["title"] as? String, location: value["location"] as? String, coordinates: value["coordinates"] as? [String:Double], stateOrCountry: value["countryOrState"] as? String, length: value["length"] as? Double, created: 0, category: "Travel", url: value["url"] as? String, id: key )
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
            if let posts = snapshot.value as? [String : [String : Any]] {
                for (key, value) in posts {
                    let stoury = Stoury(userID: value["uid"] as? String, userName: value["user"] as? String, title: value["title"] as? String, location: value["location"] as? String, coordinates: value["coordinates"] as? [String:Double], stateOrCountry: value["countryOrState"] as? String, length: value["length"] as? Double, created: 0, category: "Travel", url: value["url"] as? String, id: key )
                    self.recentPosts.append(stoury)
                }
            }
            self.recentPosts.sort { $0.created > $1.created }
            completion(true)
            
        })
    }
    
//    func getAllPosts(completion: @escaping DataHandler) {
//        postRef.queryLimited(toLast: 2).observe(FIRDataEventType.value, with: { (snapshot) in
//            if let posts = snapshot.value as? [String : [String : Any]] {
//                if let postsArray = posts["posts"] {
//                    for (key, value) in postsArray {
//                        if let dict = value as? [String:Any] {
//                            let stoury = Stoury(userID: dict["uid"] as? String, userName: dict["user"] as? String, title: dict["title"] as? String, location: dict["location"] as? String, coordinates: dict["coordinates"] as? [String:Double], stateOrCountry: dict["countryOrState"] as? String, length: dict["length"] as? Double, created: 0, category: "Travel", url: dict["url"] as? String, id: key )
//                            self.recentPosts.append(stoury)
//                        }
//                    }
//                }
//                self.recentPosts.sort { $0.created > $1.created }
//                completion(true)
//            }
//        })
//    }
    
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
