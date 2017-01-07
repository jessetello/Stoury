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
import Photos

enum StouryType {
    case live
    case nonlive
}

enum RecordingState {
    case recording
    case stopped
}

class TSPostViewController: UIViewController {
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
    var stouryType = StouryType.nonlive
    var recordingState = RecordingState.stopped

    @IBOutlet var liveStreamLabel: UILabel!
    var captureSession = AVCaptureSession()
    var movieFileOutput: AVCaptureMovieFileOutput?
    var audioDeviceInput: AVCaptureDeviceInput?
    var movieDeviceInput: AVCaptureDeviceInput?
    var nonLivePreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet var timeLabel: UILabel!
    var counter = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nonLiveStream()
    
        NotificationCenter.default.addObserver(self, selector:#selector(TSPostViewController.keyboardWillShow(notification:)) , name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(TSPostViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.delegate = self;
        descriptionTextView.becomeFirstResponder()
        startStreamButton.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initializeLiveStream() {
        DispatchQueue.main.async {
            //StreamManager.sharedInstance.goCoder?.cameraView = self.view
            StreamManager.sharedInstance.goCoder?.config.load(WZFrameSizePreset.preset1280x720)
            StreamManager.sharedInstance.goCoder?.config.hostAddress = "rtmp://ec6587.entrypoint.cloud.wowza.com"
            StreamManager.sharedInstance.goCoder?.config.portNumber = 1935
            StreamManager.sharedInstance.goCoder?.config.streamName = "e34dad1f"
            StreamManager.sharedInstance.goCoder?.config.applicationName = "app-a989"
            StreamManager.sharedInstance.goCoder?.cameraPreview?.previewGravity = WZCameraPreviewGravity.resizeAspectFill
            //StreamManager.sharedInstance.goCoder?.cameraPreview?.start()
            
            StreamManager.sharedInstance.initalizeBroadcast(completion: { (success) in
                if success {
                    self.initializingLabel.isHidden = true
                    self.startStreamButton.isHidden = false
                    self.videoTypeSwitch.isEnabled = true
                    self.liveStreamLabel.textColor = UIColor.white
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
      DispatchQueue.main.async {
        self.captureSession.sessionPreset = AVCaptureSessionPresetInputPriority
        if let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
            var error: NSError?
            do {
                self.movieDeviceInput = try AVCaptureDeviceInput(device: backCamera)
            } catch let error1 as NSError {
                error = error1
                self.movieDeviceInput = nil
                print(error!.localizedDescription)
            }
            
            self.captureSession.beginConfiguration()
            
            if error == nil && self.captureSession.canAddInput(self.movieDeviceInput) {
                self.captureSession.addInput(self.movieDeviceInput)
                self.movieFileOutput = AVCaptureMovieFileOutput()
                self.movieFileOutput?.maxRecordedDuration = CMTime(seconds: 300.0, preferredTimescale: CMTimeScale(30.0))
                if self.captureSession.canAddOutput(self.movieFileOutput) {
                    self.captureSession.addOutput(self.movieFileOutput)
                }
            }
            
            if let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) {
                var error: NSError?
                do {
                    self.audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                } catch let error2 as NSError {
                    error = error2
                    self.audioDeviceInput = nil
                    print(error?.description ?? "Error")
                }
                
                if error == nil && self.captureSession.canAddInput(self.audioDeviceInput) {
                    self.captureSession.addInput(self.audioDeviceInput)
                }
            }
            self.captureSession.commitConfiguration()
        }
        
        if let preview = AVCaptureVideoPreviewLayer(session: self.captureSession) {
                self.nonLivePreviewLayer = preview
                self.nonLivePreviewLayer?.frame = self.view.bounds
                self.nonLivePreviewLayer?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
                self.nonLivePreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.view.layer.insertSublayer(self.nonLivePreviewLayer!, at: 0)
                self.captureSession.startRunning()
        }
        
        }
    }
    
    @IBAction func toggleRecordingType(_ sender: UISwitch) {
        
        if sender.isOn {
            self.captureSession.stopRunning()
            self.nonLivePreviewLayer?.removeFromSuperlayer()
            self.nonLivePreviewLayer = nil
            StreamManager.sharedInstance.goCoder?.cameraView = self.view
            StreamManager.sharedInstance.goCoder?.cameraPreview?.start()
            stouryType = .live
        }
        else {
            StreamManager.sharedInstance.goCoder?.cameraPreview?.stop()
            StreamManager.sharedInstance.goCoder?.cameraView = nil
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
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filePath = documentsURL.appendingPathComponent("temp")
                self.movieFileOutput?.startRecording(toOutputFileURL: filePath as URL!, recordingDelegate: recordingDelegate)
                break
            }
            
            timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(TSPostViewController.updateCounter), userInfo: nil, repeats: true)
            timeLabel.isHidden = false
            videoTypeSwitch.isHidden = true
            liveStreamLabel.isHidden = true
            descriptionTextView.isHidden = true
            descriptionTextView.resignFirstResponder()
            startStreamButton.setTitle("Stop Recording", for: .normal)
            startStreamButton.backgroundColor = UIColor.red
            
            recordingState = .recording
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
            timer.invalidate()
        }
    }
    
    func updateCounter() {
        counter += 1
        
        let seconds = UInt8(counter)
        let minutes = UInt8(counter / 60)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        timeLabel.text = "\(strMinutes):\(strSeconds)"
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

extension TSPostViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("Recording")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
            if let videoData = NSData(contentsOf:outputFileURL) {
//                PHPhotoLibrary.shared().performChanges({
//                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
//                }) { saved, error in
//                    if saved && self.stouryType == .nonlive {
                        let alertController = UIAlertController(title: "Would you like to post this video?", message: nil, preferredStyle: .alert)
                        let yes = UIAlertAction(title: "YES", style: .default, handler: { (action) in
                            print(videoData.bytes)
                            let compressed = NSData.compress(fileURL: outputFileURL as NSURL, action: .Compress)
                            print(compressed.bytes)
                            VideoUploadManager.sharedInstance.saveToFireBase(data: compressed, title: self.descriptionTextView.text, place: self.selectedPlace, coordinate: LocationManager.sharedInstance.userLocation!)
                                self.dismiss(animated: true, completion: nil)
                        })
                        
                        let no = UIAlertAction(title: "NO", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        })

                        alertController.addAction(yes)
                        alertController.addAction(no)
                        self.present(alertController, animated: true, completion: nil)
//                    }
                }
            }
//    }
}

extension TSPostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
}

extension TSPostViewController: GMSAutocompleteViewControllerDelegate {
    
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

