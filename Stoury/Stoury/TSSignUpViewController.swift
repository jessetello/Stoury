//
//  TSSignUpViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 9/30/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSSignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var termsAndConditions: UISwitch!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet var userName: UITextField!
    @IBOutlet weak var signupConstraint: NSLayoutConstraint!
    var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp() {
        
        firstNameField.underlined(color: .black)
        lastNameField.underlined(color: .black)
        emailField.underlined(color: .black)
        passwordField.underlined(color: .black)
        confirmPasswordField.underlined(color: .black)
        userName.underlined(color: .black)
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        userName.delegate = self

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
        
        if !termsAndConditions.isOn {
            return false
        }
        
        return true
    }


    @IBAction func signUp(_ sender: UIButton) {
        if validateSignupInfo() {
            activeField?.resignFirstResponder()
            if let email = emailField.text, let password = passwordField.text, let username = userName.text {
                TSSpinner.show("Signing Up...")
                DataManager.sharedInstance.checkUserNames(userName: username) { (success) in
                    if !success {
                        TSSpinner.hide()
                        let nameExist = UIAlertController(title: "User Name Exists", message: "That username already exists please select another name", preferredStyle: .alert)
                        nameExist.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(nameExist, animated: true, completion: nil)
                    }
                    else {
                        AuthenticationManager.sharedInstance.signUp(email: email, password: password, username: username, completion: { (success, error) in
                            TSSpinner.hide()
                            if success {
                                let sb = UIStoryboard(name: "Main", bundle: nil)
                                if let mainVC = sb.instantiateViewController(withIdentifier: "TSMainViewController") as? MainViewController {
                                    self.navigationController?.pushViewController(mainVC, animated: true)
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                                    let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    })
                                    self.present(alertController, animated: false, completion: nil)
                                    alertController.addAction(OK)
                                }
                            }
                        })
                    }
                }
            }
        }
        else {
            
        
        }
    }
    
    
    @IBAction func terms(_ sender: UIButton) {
        
        
        
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
