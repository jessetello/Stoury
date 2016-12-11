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
            } else {
                completion(false)
            }
    }
    
    func startBroadcast() {
       if self.goCoder?.status.state != WZState.running {
            self.goCoder?.startStreaming(self)
      }
    }
    
    func stopBroadCast() {
        self.goCoder?.endStreaming(self)
        
    }
    
    func onWZStatus(_ status: WZStatus!) {
        print(status.description)
    }
    
    func onWZError(_ status: WZStatus!) {
        print(status.description)
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
            //VideoUploadManager.sharedInstance.saveToFireBase(data: videoData)
        }
    }
}
