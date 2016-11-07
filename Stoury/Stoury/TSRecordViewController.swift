//
//  TSRecordViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import AVFoundation
import WowzaGoCoderSDK
import GooglePlacePicker
import Firebase
import FirebaseAuth

class TSRecordViewController: UIViewController {
   //This will eventually be custom recording view
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var seperatorLine: UIView!
    @IBOutlet weak var initializingLabel: UILabel!
    @IBOutlet weak var shareToFacebook: UIButton!
    @IBOutlet weak var startStreamButton: UIButton!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    var selectedPlace:GMSPlace?
    
//    var captureSession = AVCaptureSession()
//    var movieFileOutput: AVCaptureMovieFileOutput?
//    var audioDeviceInput: AVCaptureDeviceInput?
//    var movieDeviceInput: AVCaptureDeviceInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        NotificationCenter.default.addObserver(self, selector:#selector(TSRecordViewController.keyboardWillShow(notification:)) , name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(TSRecordViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        descriptionTextView.becomeFirstResponder()
        descriptionTextView.delegate = self;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupCamera() {
        DispatchQueue.main.async {
            StreamManager.sharedInstance.goCoder?.cameraView = self.view
            StreamManager.sharedInstance.goCoder?.config.load(WZFrameSizePreset.preset1280x720)
            StreamManager.sharedInstance.goCoder?.config.hostAddress = "live.streamingserver.com"
            StreamManager.sharedInstance.goCoder?.config.streamName = FIRAuth.auth()?.currentUser?.displayName
            
            StreamManager.sharedInstance.goCoder?.cameraPreview?.previewGravity = WZCameraPreviewGravity.resizeAspectFill
            StreamManager.sharedInstance.goCoder?.cameraPreview?.start()
            
            StreamManager.sharedInstance.initalizeBroadcast(completion: { (success) in
                if success {
                    self.initializingLabel.isHidden = true
                    self.startStreamButton.isHidden = false
                }
                else {
                    self.initializingLabel.text = "Initialization Error"
                }
            })
        }
       //  "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/WowzaGoCoderSDK.framework/strip-frameworks.sh"
    }
 
    @IBAction func closeRecorder(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startStream(_ sender: UIButton) {
        StreamManager.sharedInstance.startBroadcast()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let time = info[UIKeyboardAnimationDurationUserInfoKey]
        bottomViewConstraint.constant = keyboardFrame.size.height
        
        UIView.animate(withDuration: time as! TimeInterval, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let time = info[UIKeyboardAnimationDurationUserInfoKey]
        bottomViewConstraint.constant = 0
        
        UIView.animate(withDuration: time as! TimeInterval, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func showLocationPicker(_ sender: UIButton) {
        let locationsVC = GMSAutocompleteViewController()
        locationsVC.delegate = self
        present(locationsVC, animated: true, completion: nil)
    }
    
}

extension TSRecordViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
            if let videoData = NSData(contentsOf:outputFileURL) {
                print(videoData)
                VideoUploadManager.sharedInstance.saveToFireBase(data: videoData)
            }
            dismiss(animated: true, completion: nil)
    }
}

extension TSRecordViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}

extension TSRecordViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            selectedPlace = place
            addLocationButton.setTitle(place.name, for: .normal)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

