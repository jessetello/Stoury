//
//  ReviewViewController.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 4/4/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import AVFoundation

class ReviewViewController: UIViewController {

    var videoData:NSData?
    var avPlayerLayer = AVPlayerLayer()
    var filePath: URL?
    let avPlayer = AVPlayer()

    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var postTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location.underlined()
        postTitle.underlined()
        avPlayerLayer.player = avPlayer
        self.view.layer.insertSublayer(avPlayerLayer, at: 0)
        if let path = filePath {
            let playerItem = AVPlayerItem(url: path)
            avPlayer.replaceCurrentItem(with: playerItem)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avPlayerLayer.frame = view.bounds
    }
    
    @IBAction func post(_ sender: UIButton) {
        if let data = videoData {
            let asset = AVURLAsset(url: filePath!)
            let videoDuration = CMTimeGetSeconds(asset.duration)
            let generator = AVAssetImageGenerator.init(asset: asset)
            var cover:CGImage?
            do {
                cover = try generator.copyCGImage(at: CMTimeMake(1, 1), actualTime: nil)
            }
            catch {
                
            }
            VideoUploadManager.sharedInstance.saveToFireBase(data: data, title:postTitle.text ?? "", location: location.text ?? "Unknown", coordinates: LocationManager.sharedInstance.userLocation!, length: videoDuration)
        }
    }
    
}
