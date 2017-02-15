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

    func saveToFireBase(data:NSData, title:String, place:GMSPlace?, coordinate:CLLocation) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            print("Error mssing UID")
            return
        }
        // Create a reference to the file you want to upload
        let storageRef = DataManager.sharedInstance.storage.reference(forURL: "gs://stoury-c55b9.appspot.com")
        let vidRef = storageRef.child("/videos" + "\(title)" + "/stoury.MOV")
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
                //let name = FIRAuth.auth()?.currentUser?.displayName
                guard let vidUrl = data.downloadURL() else {
                    print("missing params")
                    return
                }
                self?.writeNewPost(userID: uid,
                                   userName: "JOE",//(FIRAuth.auth()?.currentUser?.displayName)!,
                                   title: title,
                                   location:"",
                                   coordinates:["lat":coordinate.coordinate.latitude,
                                             "lon":coordinate.coordinate.longitude],
                                   url:vidUrl.absoluteString)
            }
        }
    }
    
    func writeNewPost(userID:String, userName:String, title:String, location:String, coordinates:[String:Double], url:String) {
        
        let key = DataManager.sharedInstance.ref.child("posts").childByAutoId().key
        
        let post = ["uid": userID,
                    "user": userName,
                    "title": title,
                    "coordinates": coordinates,
                    "location": location,
                    "url":url] as [String : Any]
        
        let childUpdates = ["/posts/\(key)": post,
                            "/user-posts/\(userID)/\(key)/": post]
        DataManager.sharedInstance.ref.updateChildValues(childUpdates)
    }
    
}
