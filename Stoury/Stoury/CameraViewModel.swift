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
    
    func videoPreviewUiimage(fileName:String) -> UIImage? {
        
            let vidURL = NSURL(string: fileName)
            let asset = AVURLAsset(url: vidURL! as URL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
            
            do {
                let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
                return UIImage(cgImage: imageRef)
            }
            catch let error as NSError
            {
                print("Image generation failed with error \(error)")
                return nil
            }
    }
}
