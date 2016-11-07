//
//  StreamManager.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 11/5/16.
//  Copyright © 2016 jt. All rights reserved.
//

import Foundation
import WowzaGoCoderSDK

class StreamManager: NSObject, WZStatusCallback, AVCaptureFileOutputRecordingDelegate, WZVideoEncoderSink {
   
    typealias BrodcastIntializationHandler = (_ success:Bool) -> Void
    static let sharedInstance = StreamManager()
    let WowzaLicenseKey = "GOSK-F342-0103-9224-C83B-C91D"

    var captureSession = AVCaptureSession()
    var movieFileOutput: AVCaptureMovieFileOutput?
    var movieDeviceInput: AVCaptureInput?

    var goCoder: WowzaGoCoder?
    
    override init() {
        
        if WowzaGoCoder.registerLicenseKey(WowzaLicenseKey) == nil {
            goCoder = WowzaGoCoder.sharedInstance()
            WowzaGoCoder.requestPermission(for: .camera, response: { (permission) in
                print("Camera permission is: \(permission == .authorized ? "authorized" : "denied")")                
            })
            
            WowzaGoCoder.requestPermission(for: .microphone, response: { (permission) in
                print("Microphone permission is: \(permission == .authorized ? "authorized" : "denied")")
            })
        }
    }
    
    func initalizeBroadcast(completion: @escaping BrodcastIntializationHandler) {
            if self.goCoder?.config.validateForBroadcast() == nil {
                completion(true)
            }
            completion(false)
    }
    
    func startBroadcast() {
        let error = self.goCoder?.config.validateForBroadcast()
        
        if error != nil {
            //show error
        } else if self.goCoder?.status.state != WZState.running {
            self.goCoder?.startStreaming(self)
        }
        
        //        let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
        //
        //        let videoFileOutput = AVCaptureMovieFileOutput()
        //        self.captureSession.addOutput(videoFileOutput)
        //
        //        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //        let filePath = documentsURL.appendingPathComponent("temp")
        //
        //        videoFileOutput.startRecording(toOutputFileURL: filePath as URL!, recordingDelegate: recordingDelegate)

    }
    
    func stopBroadCast() {
        self.goCoder?.endStreaming(self)
    }
    
    func onWZStatus(_ status: WZStatus!) {
        
    }
    
    func onWZError(_ status: WZStatus!) {
        
    }
    
    func videoFrameWasEncoded(_ data: CMSampleBuffer) {
        //Upload to firebase?
        print("Data logging \(data)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if let videoData = NSData(contentsOf:outputFileURL) {
            print(videoData)
            VideoUploadManager.sharedInstance.saveToFireBase(data: videoData)
        }
    }
}
