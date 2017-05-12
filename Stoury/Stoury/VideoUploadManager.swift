//
//  VideoUploadManager.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/20/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth
import GooglePlaces

class VideoUploadManager {
    
    static let sharedInstance = VideoUploadManager()

    func saveToFireBase(data:NSData, title:String, location:String, stateOrCountry: String?, coordinates:CLLocation, length:Double, existing:String?) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            print("Error mssing UID")
            return
        }
        
        // Create a reference to the file you want to upload
        let storageRef = DataManager.sharedInstance.storage.reference(forURL: "gs://stoury-c55b9.appspot.com")
        let vidRef = storageRef.child("/videos" + "/\(uid)" + "/\(NSTimeIntervalSince1970)" + "/\(title).MOV")
        let uploadTask = vidRef.put(data as Data, metadata: nil) { metadata, error in
        
        }
        
        uploadTask.observe(.pause) { snapshot in
            // Upload paused
        }
        
        uploadTask.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                print(percentComplete)
            }
        }
        
        uploadTask.observe(.success) { [weak self] snapshot in
            // Metadata contains file metadata such as size, content-type, and download URL.
            if let data = snapshot.metadata {
                guard let vidUrl = data.downloadURL() else {
                    print("missing params")
                    return
                }
                self?.writeNewPost(userID: uid,
                                   userName:(FIRAuth.auth()?.currentUser?.displayName) ?? "Unknown",
                                   title: title,
                                   location:location,
                                   stateOrCountry: stateOrCountry ?? "",
                                   coordinates:["lat":coordinates.coordinate.latitude,
                                             "lon":coordinates.coordinate.longitude],
                                   url:vidUrl.absoluteString,
                                   length: length,
                                   existing:existing)
            }
        }
    }
    
    func writeNewPost(userID:String, userName:String, title:String, location:String, stateOrCountry:String, coordinates:[String:Double], url:String, length:Double, existing:String?) {

        let key = DataManager.sharedInstance.newPostRef.childByAutoId().key
        let post = ["uid": userID,
                    "user": userName,
                    "title": title,
                    "length" : length,
                    "coordinates": coordinates,
                    "location": location,
                    "stateOrCountry" : stateOrCountry,
                    "created":NSDate().timeIntervalSince1970,
                    "url":url] as [String : Any]
       
        let  childUpdates = ["/posts/\(existing ?? key)": post,
                                "/user-posts/\(userID)/\(key)/": post]
        
        DataManager.sharedInstance.newPostRef.updateChildValues(childUpdates)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadComplete"), object: nil)
    }
}
