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

    var avPlayerLayer = AVPlayerLayer()
    var filePath: URL?
    let avPlayer = AVPlayer()

    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var postTitle: UITextField!
    
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location.underlined(color: .lightGray)
        postTitle.underlined(color: .lightGray)
        avPlayerLayer.player = avPlayer
        self.view.layer.addSublayer(avPlayerLayer)
        if let path = filePath {
            let playerItem = AVPlayerItem(url: path)
            avPlayer.replaceCurrentItem(with: playerItem)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play()
        self.view.bringSubview(toFront: self.overlay)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avPlayerLayer.frame = view.bounds
    }
    
    @IBAction func post(_ sender: UIButton) {
        if let file = filePath {
            let asset = AVURLAsset(url: file)
            let videoDuration = CMTimeGetSeconds(asset.duration)
            do {
                let dataToCompress = try NSData(contentsOf: file, options: .alwaysMapped)
                let compressed = NSData.compress(data:dataToCompress, action: .Compress)
                VideoUploadManager.sharedInstance.saveToFireBase(data: compressed, title:postTitle.text ?? "", location: location.text ?? "Unknown", coordinates: LocationManager.sharedInstance.userLocation!, length: videoDuration)
            }
            catch {
                
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func coverImageConvert() {
//        let generator = AVAssetImageGenerator.init(asset: asset)
//        var cover:CGImage?
//        do {
//            cover = try generator.copyCGImage(at: CMTimeMake(1, 1), actualTime: nil)
//        }
//        catch {
//            
//        }
    }
    
}
