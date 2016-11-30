//
//  ViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 9/21/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class TSWelcomeViewController: UIViewController {

    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    private let dataURL = "gs://tripstori-59fb9.appspot.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func facebookLogin(_ sender: FBSDKLoginButton) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email","public_profile","user_friends"], from: self) { loginResult, error in
            let cred = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            AuthenticationManager.sharedInstance.socialLoginWith(credential: cred, completion: { (success) in
                if success {
                   self.loadMain()
                }
                else {
                    
                    
                }
            })
        }
    }
    
    func loadMain() {
        if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "TSMainViewController") as? TSMainViewController {
            self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }
}

extension NSString {
    public var isPhone: Bool {
        get {
            if self.range(of: "^(\\(?\\+?[0-9]*\\)?)?[0-9_\\- \\(\\)]*$", options: NSString.CompareOptions.regularExpression).location != NSNotFound {
                return true
            }
            return false
        }
    }
    
    public var isEmail: Bool {
        get {
            if self.range(of: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", options: NSString.CompareOptions.regularExpression).location != NSNotFound && self.length > 5 && self.length <= 254 {
                return true
            }
            return false
        }
    }
    public var isName: Bool {
        get {
            if self.range(of: "^[A-Za-z0-9-' ]+$", options: NSString.CompareOptions.regularExpression).location != NSNotFound {
                return true
            }
            return false
        }
    }
}


