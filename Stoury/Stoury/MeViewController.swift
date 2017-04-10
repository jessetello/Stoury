//
//  TSFriendsViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import FirebaseAuth
class MeViewController: UITableViewController {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = FIRAuth.auth()?.currentUser?.displayName
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(MeViewController.logout))
    }
    
    func logout() {
        AuthenticationManager.sharedInstance.logout()
    }

}


