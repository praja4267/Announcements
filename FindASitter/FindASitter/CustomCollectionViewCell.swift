//
//  CustomCollectionViewCell.swift
//  FindASitter
//
//  Created by Active Mac05 on 14/10/16.
//  Copyright © 2016 techactive. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var ratingView: TPFloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
