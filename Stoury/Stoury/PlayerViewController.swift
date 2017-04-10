//
//  PlayerViewController.swift
//  Stoury
//
//  Created by Jesse Tello on 4/10/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController {

    var stouryURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let player = AVPlayer(url: stouryURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.view.frame = self.view.bounds
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
