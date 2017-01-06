//
//  NearMeCell.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 1/5/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit

class NearMeCell: UITableViewCell {

    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var ratingNum: UILabel!
    @IBOutlet var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        placeImage.image = nil
    }
}
