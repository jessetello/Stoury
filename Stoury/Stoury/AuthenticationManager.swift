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
    typealias AuthenticationHandler = (_ success:Bool) -> Void
    
    func signIn(email: String, password: String, completion: @escaping AuthenticationHandler) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if let authError = error {
                print(authError)
                completion(false)
            }
            else {
                completion(true)
            }
         })
    }
    
    func signUp(email: String, password: String, completion: @escaping AuthenticationHandler) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let authError = error {
                print(authError)
                completion(false)
            }
            else {
                completion(true)
            }
        })
    }
    
    func socialLoginWith(credential: FIRAuthCredential, completion: @escaping AuthenticationHandler)  {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let authError = error {
                print(authError)
                completion(false)
            }
            else {
                completion(true)
            }
        })
    }
    
    func logout() {
        do {
            try FIRAuth.auth()?.signOut()
            //take to sign in screen
        } catch {
                
        }
    }
    
}
