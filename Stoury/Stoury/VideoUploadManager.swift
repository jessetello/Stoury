//
//  VideoUploadManager.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/20/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class VideoUploadManager {
    
    static let sharedInstance = VideoUploadManager()
    private let ref = FIRDatabase.database().reference()
    private let storage = FIRStorage.storage()

    func saveToFireBase(data: NSData) {
        // Create a reference to the file you want to upload
        let storageRef = storage.reference(forURL: "gs://stoury-c55b9.appspot.com")
        let vidRef = storageRef.child("stoury/video.MOV")
        let uploadTask = vidRef.put(data as Data, metadata: nil) { metadata, error in
            if (error != nil) {
                // an error occurred!
                print(error!)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                if let data = metadata {
                    print(data.downloadURLs!)
                }
            }
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
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
        }
    }
}
