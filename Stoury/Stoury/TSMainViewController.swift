//
//  ViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TSMainViewController: UITabBarController, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    private let sb = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
    }
    
    func presentCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                self.imagePicker.sourceType = .camera
                if let cam = UIImagePickerController.availableMediaTypes(for: .camera) {
                    self.imagePicker.mediaTypes = cam
                }
                self.imagePicker.allowsEditing = false
                present(self.imagePicker, animated: true, completion:nil)
            } else {
                // postAlert("Rear camera doesn't exist", message: "Application cannot access the camera.")
            }
        } else {
            // postAlert("Camera inaccessable", message: "Application cannot access the camera.")
        }
    }
    
    func authorizeRecordingView() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined ||  AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (videoGranted: Bool) -> Void in
                if (videoGranted) {
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (audioGranted: Bool) -> Void in
                        if (audioGranted) {
                            DispatchQueue.main.async {
                                // Both video & audio granted
                                self.presentCamera()
                            }
                        } else {
                            // Rejected audio
                            print("rejected audio")
                        }
                    })
                } else {
                    // Rejected video
                    print("rejected video")
                }
            })
        } else {
            DispatchQueue.main.async {
                self.presentCamera()
            }
        }
    }
    
   override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 99 {
            authorizeRecordingView()
        }
    }
}

extension TSMainViewController: UIImagePickerControllerDelegate {
    
    // Finished recording a video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            if let videoData = NSData(contentsOf: pickedVideo as URL) {
                print(pickedVideo)
                print(videoData)
                VideoUploadManager.sharedInstance.saveToFireBase(data: videoData)
            }
            self.dismiss(animated: true, completion: nil)
            
        }
        
        self.imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an video
        })
    }
}



