//
//  CameraViewModel.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 6/11/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import AVFoundation
import GooglePlaces

class CameraViewModel {

    var authorized = false
    
    func presentCamera(viewController: UIViewController, selectedPlace:GMSPlace?, existingStouryID:String?) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        if let vc = story.instantiateViewController(withIdentifier: "RecordNav") as? UINavigationController {
            let rc = vc.childViewControllers[0] as? RecordViewController
            if selectedPlace != nil {
                rc?.selectedPlace = selectedPlace
            } else if existingStouryID != nil {
                rc?.existingID = existingStouryID
            }
            viewController.present(vc, animated: true, completion: nil)
        }
    }
    
    func authorizeRecordingView() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined ||  AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (videoGranted: Bool) -> Void in
                if (videoGranted) {
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (audioGranted: Bool) -> Void in
                        if (audioGranted) {
                            self.authorized = true
                        } else {
                            // Rejected audio
                            self.authorized = false
                        }
                    })
                } else {
                    // Rejected video
                    self.authorized = false
                }
            })
        } else {
            authorized = true
        }
    }
}
