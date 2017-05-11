//
//  TSMainFeedCell.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 11/29/16.
//  Copyright © 2016 jt. All rights reserved.
//

import UIKit

class StouryCell: UITableViewCell {

    @IBOutlet var videoImage: UIImageView!
    @IBOutlet var videoLength: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet var stateOrCountry: UILabel!
    @IBOutlet var location: UILabel!
    
    @IBOutlet weak var comment: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.comment.layer.cornerRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addComment(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PresentCamera"), object: nil)
    }

}
