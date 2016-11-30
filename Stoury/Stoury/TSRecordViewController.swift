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

enum StouryType {
    case live
    case nonlive
}

enum RecordingState {
    case recording
    case stopped
}

class TSRecordViewController: UIViewController {
   //This will eventually be custom recording view
    
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var seperatorLine: UIView!
    @IBOutlet weak var initializingLabel: UILabel!
    @IBOutlet weak var startStreamButton: UIButton!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var videoTypeSwitch: UISwitch!
    var selectedPlace:GMSPlace?
    var stouryType = StouryType.live
    var recordingState = RecordingState.stopped

    var captureSession = AVCaptureSession()
    var movieFileOutput: AVCaptureMovieFileOutput?
    var audioDeviceInput: AVCaptureDeviceInput?
    var movieDeviceInput: AVCaptureDeviceInput?
    
//    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
//        if let preview =  AVCaptureVideoPreviewLayer(session: self.captureSession) {
//            preview.frame = self.view.bounds
//            preview.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
//            preview.videoGravity = AVLayerVideoGravityResizeAspectFill
//            return preview
//        }
//        return nil
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nonLiveStream()
        
        NotificationCenter.default.addObserver(self, selector:#selector(TSRecordViewController.keyboardWillShow(notification:)) , name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(TSRecordViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.becomeFirstResponder()
        descriptionTextView.delegate = self;
        
        startStreamButton.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initializeLiveStream() {
        DispatchQueue.main.async {
            StreamManager.sharedInstance.goCoder?.cameraView = self.view
            StreamManager.sharedInstance.goCoder?.config.load(WZFrameSizePreset.preset1280x720)
            StreamManager.sharedInstance.goCoder?.config.hostAddress = "rtmp://ec6587.entrypoint.cloud.wowza.com"
            StreamManager.sharedInstance.goCoder?.config.portNumber = 1935
            StreamManager.sharedInstance.goCoder?.config.streamName = "e34dad1f"
            StreamManager.sharedInstance.goCoder?.config.applicationName = "app-a989"
            StreamManager.sharedInstance.goCoder?.cameraPreview?.previewGravity = WZCameraPreviewGravity.resizeAspectFill
            StreamManager.sharedInstance.goCoder?.cameraPreview?.start()
            
            StreamManager.sharedInstance.initalizeBroadcast(completion: { (success) in
                if success {
                    self.initializingLabel.isHidden = true
                    self.startStreamButton.isHidden = false
                    self.videoTypeSwitch.isEnabled = true
                }
                else {
                    self.videoTypeSwitch.isEnabled = false
                    self.initializingLabel.text = "Initialization Error"
                }
            })
        }
       //  "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/WowzaGoCoderSDK.framework/strip-frameworks.sh"
    }
    
    func nonLiveStream() {
        captureSession.sessionPreset = AVCaptureSessionPresetInputPriority
        if let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
            var error: NSError?
            do {
                movieDeviceInput = try AVCaptureDeviceInput(device: backCamera)
            } catch let error1 as NSError {
                error = error1
                movieDeviceInput = nil
                print(error!.localizedDescription)
            }
            
            captureSession.beginConfiguration()
            
            if error == nil && captureSession.canAddInput(movieDeviceInput) {
                captureSession.addInput(movieDeviceInput)
                movieFileOutput = AVCaptureMovieFileOutput()
                movieFileOutput?.maxRecordedDuration = CMTime(seconds: 180.0, preferredTimescale: CMTimeScale(30.0))
                if captureSession.canAddOutput(movieFileOutput) {
                    captureSession.addOutput(movieFileOutput)
                }
            }
            
            if let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) {
                var error: NSError?
                do {
                    audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                } catch let error2 as NSError {
                    error = error2
                    audioDeviceInput = nil
                    print(error?.description ?? "Error")
                }
                
                if error == nil && captureSession.canAddInput(audioDeviceInput) {
                    captureSession.addInput(audioDeviceInput)
                }
            }
            captureSession.commitConfiguration()
        }
        DispatchQueue.main.async {
            if let preview = AVCaptureVideoPreviewLayer(session: self.captureSession) {
                preview.frame = self.view.bounds
                preview.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
                preview.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.view.layer.insertSublayer(preview, at: 0)
                self.captureSession.startRunning()
            }
        }
    }
    
    @IBAction func toggleRecordingType(_ sender: UISwitch) {
        
        if sender.isOn {
           stouryType = .live
           initializeLiveStream()
        }
        else {
           stouryType = .nonlive
           nonLiveStream()
        }
    }
 
    @IBAction func closeRecorder(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startStream(_ sender: UIButton) {
       
        if recordingState == .stopped {
           
            switch stouryType {
            case .live:
                if StreamManager.sharedInstance.goCoder?.status.state != WZState.running {
                    descriptionTextView.resignFirstResponder()
                    startStreamButton.titleLabel?.text = "Stop Stream"
                    StreamManager.sharedInstance.startBroadcast()
                }
                else {
                    StreamManager.sharedInstance.stopBroadCast()
                }
                break
            case .nonlive:
                let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
                
                let videoFileOutput = AVCaptureMovieFileOutput()
                videoFileOutput.maxRecordedDuration = CMTime(seconds: 300, preferredTimescale: 30)
                self.captureSession.addOutput(videoFileOutput)
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filePath = documentsURL.appendingPathComponent("temp")
                
                videoFileOutput.startRecording(toOutputFileURL: filePath as URL!, recordingDelegate: recordingDelegate)
                break
            }
            
            self.videoTypeSwitch.isHidden = true
            
        }
        else {
            switch stouryType {
            case .live:
                if StreamManager.sharedInstance.goCoder?.status.state == WZState.running {
                    StreamManager.sharedInstance.stopBroadCast()
                }
                break
            case .nonlive:
               self.captureSession.stopRunning()
                break
            }
        }
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
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
}

extension TSRecordViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            selectedPlace = place
            addLocationButton.setTitle(place.name, for: .normal)
            viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

