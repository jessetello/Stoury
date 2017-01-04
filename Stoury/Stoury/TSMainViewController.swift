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

class TSMainViewController: UITabBarController, UINavigationControllerDelegate, UITabBarControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(TSMainViewController.logout))
        self.delegate = self
        LocationManager.sharedInstance.getLocation()    
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 99 {
            authorizeRecordingView()
            return false
        }
        return true
    }
    
    private func presentCamera() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Record") as? TSPostViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func authorizeRecordingView() {
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
    
    func logout() {
        AuthenticationManager.sharedInstance.logout()
    }
}

extension TSMainViewController: UIImagePickerControllerDelegate {
    
    // Finished recording a video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            if let videoData = NSData(contentsOf: pickedVideo as URL) {
                print(pickedVideo)
                print(videoData)
//                VideoUploadManager.sharedInstance.saveToFireBase(data: videoData, title: , place: <#T##GMSPlace?#>, coordinate: <#T##CLLocationCoordinate2D#>)
            }
            self.dismiss(animated: true, completion: nil)
            
        }
        
        self.imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an video
        })
    }
}



