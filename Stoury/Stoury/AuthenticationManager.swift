//
//  AuthenticationManager.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 10/2/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import Firebase

class AuthenticationManager {
    
    static let sharedInstance = AuthenticationManager()
    typealias AuthenticationHandler = (_ success:Bool, _ error:Error?) -> Void
    
    func signIn(email: String, password: String, completion: @escaping AuthenticationHandler) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                completion(false, error)
            }
            else {
                completion(true, nil)
            }
         })
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping AuthenticationHandler) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let authError = error {
                completion(false, authError)
            }
            else {
                //create a user object with username,email,uid
                if let user = user {
                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.commitChanges() { (error) in
                            if error != nil {
                                completion(false, error)
                            } else {
                                DataManager.sharedInstance.createUser(user: user, userName: username)
                                completion(true, nil)
                            }
                    }
                }
            }
        })
    }
    
    func logout() {
        do {
            try FIRAuth.auth()?.signOut()
            //take to sign in screen
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let loginVC = sb.instantiateViewController(withIdentifier: "Welcome") as? UINavigationController {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.window?.rootViewController = loginVC
                }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
