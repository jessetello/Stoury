//
//  TSSignUpViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 9/30/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSSignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signupConstraint: NSLayoutConstraint!
    var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp() {
        firstNameField.underlined()
        lastNameField.underlined()
        emailField.underlined()
        passwordField.underlined()
        confirmPasswordField.underlined()
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self

        
        NotificationCenter.default.addObserver(self, selector:#selector(TSSignUpViewController.keyboardWillShow(notification:)) , name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(TSSignUpViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func validateSignupInfo() -> Bool {
        
        
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


    @IBAction func signUp(_ sender: UIButton) {
        if validateSignupInfo() {
            activeField?.resignFirstResponder()
            if let email = emailField.text, let password = passwordField.text {
                AuthenticationManager.sharedInstance.signUp(email: email, password: password, completion: { (success) in
                    if success {
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        if let mainVC = sb.instantiateViewController(withIdentifier: "TSMainViewController") as? TSMainViewController {
                            self.navigationController?.pushViewController(mainVC, animated: true)
                        }
                    }
                    else {
                        
                    }
                })
            }
        }
        else {
            
            
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let time = info[UIKeyboardAnimationDurationUserInfoKey]
        self.signupConstraint.constant = keyboardFrame.size.height
        
        UIView.animate(withDuration: time as! TimeInterval, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let time = info[UIKeyboardAnimationDurationUserInfoKey]
        self.signupConstraint.constant = 0
        
        UIView.animate(withDuration: time as! TimeInterval, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
