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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
