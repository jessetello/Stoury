//
//  TSLogInViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 9/30/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSLogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginConstraint: NSLayoutConstraint!
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.underlined(color: .black)
        passwordField.underlined(color: .black)
        emailField.delegate = self
        passwordField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector:#selector(TSLogInViewController.keyboardWillShow(notification:)) , name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(TSLogInViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func validateLogInInfo() -> Bool {
        
        if emailField.text?.isEmpty == true || passwordField.text?.isEmpty == true {
            return false
        }
        
        if let  password = passwordField.text?.characters.count, let email = emailField.text?.characters.count {
            if password <= 3 || email <= 5 {
                return false
            }
        }
        
        return true
    }

    @IBAction func login(_ sender: UIButton) {
        if validateLogInInfo() {
            activeField?.resignFirstResponder()
            TSSpinner.show("Logging In...")
            if let email = emailField.text, let password = passwordField.text {
                AuthenticationManager.sharedInstance.signIn(email: email, password: password) { (success, error) in
                    if success {
                        TSSpinner.hide()
                        self.loadMain()
                    }
                    else {
                        TSSpinner.show(duration: 1, title: "Login Failed")
                    }
                }
            }
        }
        else {
            TSSpinner.show(duration: 3, title: "Invalid Credentials")
        }
    }
    
    func loadMain() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = sb.instantiateViewController(withIdentifier: "TSMainViewController") as? MainViewController {
            self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let time = info[UIKeyboardAnimationDurationUserInfoKey]
        self.loginConstraint.constant = keyboardFrame.size.height

        UIView.animate(withDuration: time as! TimeInterval, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let time = info[UIKeyboardAnimationDurationUserInfoKey]
        self.loginConstraint.constant = 0

        UIView.animate(withDuration: time as! TimeInterval, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
