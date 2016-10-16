//
//  TSRecordViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSRecordViewController: UIViewController {
   //This will eventually be custom recording view
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var seperatorLine: UIView!
    @IBOutlet weak var initializingLabel: UILabel!
    @IBOutlet weak var shareToFacebook: UIButton!
    @IBOutlet weak var startStreamButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    func setupCamera() {
        
    }
}
