//
//  TSRecordViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    var captureSession = AVCaptureSession()
    var movieFileOutput: AVCaptureMovieFileOutput?
    var audioDeviceInput: AVCaptureDeviceInput?
    var movieDeviceInput: AVCaptureDeviceInput?
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
            if let preview =  AVCaptureVideoPreviewLayer(session: self.captureSession) {
                preview.frame = self.cameraView.bounds
                preview.position = CGPoint(x: self.cameraView.bounds.midX, y: self.cameraView.bounds.midY)
                preview.videoGravity = AVLayerVideoGravityResizeAspectFill
            return preview
            }
        return nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.setupCamera()
        }
        NotificationCenter.default.addObserver(self, selector:#selector(TSRecordViewController.keyboardWillShow(notification:)) , name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(TSRecordViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        descriptionTextView.becomeFirstResponder()  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setupCamera() {
        
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
                    print(error?.localizedDescription)
                }
                
                if error == nil && captureSession.canAddInput(audioDeviceInput) {
                    captureSession.addInput(audioDeviceInput)
                }
            }
            captureSession.commitConfiguration()
        }
        if let preview = previewLayer {
            cameraView.layer.addSublayer(preview)
            captureSession.startRunning()
        }
    }
    
    @IBAction func closeRecorder(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startStream(_ sender: UIButton) {
       
        let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
        
        let videoFileOutput = AVCaptureMovieFileOutput()
        self.captureSession.addOutput(videoFileOutput)
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("temp")
        
        videoFileOutput.startRecording(toOutputFileURL: filePath as URL!, recordingDelegate: recordingDelegate)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let time = info[UIKeyboardAnimationDurationUserInfoKey]
        self.bottomViewConstraint.constant = keyboardFrame.size.height
        
        UIView.animate(withDuration: time as! TimeInterval, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let time = info[UIKeyboardAnimationDurationUserInfoKey]
        self.bottomViewConstraint.constant = 0
        
        UIView.animate(withDuration: time as! TimeInterval, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}

extension TSRecordViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
    }
}
