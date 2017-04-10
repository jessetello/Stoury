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
import Firebase
import FirebaseAuth
import Photos
import GooglePlaces

enum StouryType {
    case live
    case nonlive
}

enum RecordingState {
    case recording
    case stopped
}

class RecordViewController: UIViewController {
   //This will eventually be custom recording view
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var seperatorLine: UIView!
    @IBOutlet weak var initializingLabel: UILabel!
    @IBOutlet weak var startStreamButton: UIButton!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet var timeLabel: UILabel!
    var selectedPlace:GMSPlace?

    var stouryType = StouryType.nonlive
    var recordingState = RecordingState.stopped

    var captureSession = AVCaptureSession()
    var movieFileOutput: AVCaptureMovieFileOutput?
    var audioDeviceInput: AVCaptureDeviceInput?
    var movieDeviceInput: AVCaptureDeviceInput?
    var nonLivePreviewLayer: AVCaptureVideoPreviewLayer?
    
    var counter = 0
    var timer = Timer()
    
    var video: NSData?
    var filePath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecorder()
    
        NotificationCenter.default.addObserver(self, selector:#selector(RecordViewController.keyboardWillShow(notification:)) , name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(RecordViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

        startStreamButton.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupRecorder() {
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
    
    @IBAction func closeRecorder(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startStream(_ sender: UIButton) {
       
        if recordingState == .stopped {
           
            let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsURL.appendingPathComponent("vid.MOV")
            self.movieFileOutput?.startRecording(toOutputFileURL: filePath as URL!, recordingDelegate: recordingDelegate)
            
            timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(RecordViewController.updateCounter), userInfo: nil, repeats: true)
            timeLabel.isHidden = false
            startStreamButton.setTitle("Stop Recording", for: .normal)
            startStreamButton.backgroundColor = UIColor.red
            
            recordingState = .recording
        }
        else {
            self.captureSession.stopRunning()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Review" {
            DispatchQueue.main.async {
                if let review = segue.destination as? ReviewViewController {
                    review.selectedPlace = self.selectedPlace
                    review.filePath = self.filePath
                }
            }
        }
    }
    
}

extension RecordViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
   
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
            self.filePath = outputFileURL
            self.performSegue(withIdentifier: "Review", sender: self)
    }
}


extension RecordViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
}
