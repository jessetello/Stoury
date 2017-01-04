//
//  TSFriendsViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSMeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func logout() {
        AuthenticationManager.sharedInstance.logout()
    }

}
