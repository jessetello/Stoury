//
//  StreamManager.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 11/5/16.
//  Copyright © 2016 jt. All rights reserved.
//

import Foundation
import WowzaGoCoderSDK


class StreamManager: NSObject, WZStatusCallback, AVCaptureFileOutputRecordingDelegate {
   
    typealias BrodcastIntializationHandler = (_ success:Bool) -> Void
    static let sharedInstance = StreamManager()
    var goCoder: WowzaGoCoder?
    
    override init() {
        if WowzaGoCoder.registerLicenseKey("GOSK-F342-0103-9224-C83B-C91D") == nil {
            goCoder = WowzaGoCoder.sharedInstance()
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
    }
    
    func stopBroadCast() {
        
    }
    
    func onWZStatus(_ status: WZStatus!) {
        
    }
    
    func onWZError(_ status: WZStatus!) {
        
        
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
