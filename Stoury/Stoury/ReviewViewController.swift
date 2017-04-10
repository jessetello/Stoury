//
//  ReviewViewController.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 4/4/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import AVFoundation
import GooglePlacePicker

class ReviewViewController: UIViewController, UITextFieldDelegate {

    var avPlayerLayer = AVPlayerLayer()
    var filePath: URL?
    let avPlayer = AVPlayer()
    var selectedPlace:GMSPlace?

    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var postTitle: UITextField!
    
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var addLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location.delegate = self
        postTitle.delegate = self
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
        if selectedPlace != nil {
            self.addLocationButton.setTitle(selectedPlace?.name, for: .normal)
        }
        self.view.bringSubview(toFront: self.overlay)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avPlayerLayer.frame = view.bounds
    }
    
    @IBAction func closeReview(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
 
    
    @IBAction func post(_ sender: UIButton) {
        if let file = filePath {
            let asset = AVURLAsset(url: file)
            let videoDuration = CMTimeGetSeconds(asset.duration)
            do {
                let dataToCompress = try NSData(contentsOf: file, options: .alwaysMapped)
//                let compressed = NSData.compress(data:dataToCompress, action: .Compress)
                VideoUploadManager.sharedInstance.saveToFireBase(data: dataToCompress, title:postTitle.text ?? "", location: selectedPlace?.name ?? "",  stateOrCountry:selectedPlace?.formattedAddress ?? "", coordinates: LocationManager.sharedInstance.userLocation!, length: videoDuration)
            }
            catch {
                
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addLocation(_ sender: UIButton) {
        let locationsVC = GMSAutocompleteViewController()
        locationsVC.delegate = self
        present(locationsVC, animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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


extension ReviewViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        selectedPlace = place
        self.addLocationButton.setTitle(place.name, for: .normal)
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
