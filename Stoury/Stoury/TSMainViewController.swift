//
//  ViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSMainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func logout() {
        AuthenticationManager.sharedInstance.logout()
    }
}



