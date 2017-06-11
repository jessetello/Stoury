//
//  StouryViewController.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 6/6/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class StouryViewController: UIViewController {

    @IBOutlet var mainVideoImage: UIImageView!
    @IBOutlet var tableView: UITableView!
    var mainStoury:Stoury?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor.lightGray
        self.tableView.register(UINib(nibName: "StouryCell", bundle: nil), forCellReuseIdentifier: "StouryCell")
        self.setupMainStoury()
    }

    func setupMainStoury() {
        if let url = self.mainStoury?.url {
            self.mainVideoImage.image = self.videoPreviewUiimage(fileName:url)
        }
    }

    func videoPreviewUiimage(fileName:String) -> UIImage? {

        let vidURL = NSURL(fileURLWithPath:fileName)
        let asset = AVURLAsset(url: vidURL as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func playVideo(videoUrl:String) {
        let player = AVPlayer(url:URL(string:videoUrl)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.view.frame = self.view.bounds
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func playStoury(_ sender: UIButton) {
        if let url = self.mainStoury?.url {
            self.playVideo(videoUrl: url)
        }
    }
}

extension StouryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stoury = self.mainStoury?.comments?[indexPath.row]
        if let url = stoury?.url {
            self.playVideo(videoUrl: url)
        }
    }
    
}

extension StouryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.mainStoury?.comments!.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StouryCell", for: indexPath) as! StouryCell
        if let stoury = mainStoury?.comments?[indexPath.row] {
            cell.title.text = stoury.title
            cell.location.text = stoury.location ?? "Unknown"
            cell.stateOrCountry.text = stoury.stateOrCountry ?? ""
            cell.userName.text = stoury.userName
            cell.moreButton.addTarget(self, action: #selector(HomeViewController.moreClicked(sender:)), for: .allTouchEvents)
            let minutes = Int(stoury.length ?? 00.00) / 60 % 60
            let seconds = Int(stoury.length ?? 00.00) % 60
            cell.videoLength.text = String(format:"%02i:%02i", minutes, seconds)
            cell.videoImage.image = UIImage(named: "PlaceHolder")
            cell.tag = indexPath.row
            
            if let sid = stoury.id {
                cell.stouryID = sid
            }
            
            if let coms = stoury.comments?.count, coms > 0 {
                cell.comments.text = "\(coms) comments"
            }
            return cell
        }
        return UITableViewCell()
    }

}
