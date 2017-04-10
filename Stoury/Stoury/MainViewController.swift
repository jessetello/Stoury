//
//  ViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import BRYXBanner

class MainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.displayBanner), name: NSNotification.Name(rawValue: "UploadComplete"), object: nil)
    }
    
    func displayBanner() {
        let banner = Banner(title: "Post Uploaded!", subtitle: "Your Stoury had completed uploading", backgroundColor: UIColor.blue)
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }

}



