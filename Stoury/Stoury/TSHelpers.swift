//
//  TSHelpers.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 10/2/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import Foundation

extension UITextField {
    func underlined(){
        self.borderStyle = .none

        let border = CALayer()
        let width = CGFloat(1.0)

        border.borderColor = UIColor.white.cgColor
        self.borderStyle = .none
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width

        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}
