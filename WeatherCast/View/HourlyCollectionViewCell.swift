//
//  HourlyCollectionViewCell.swift
//  WeatherCast
//
//  Created by yerinaoh on 15/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hourlyTitleLabel: UILabel!
    @IBOutlet weak var hourlyPercentLabel: UILabel!
    @IBOutlet weak var hourlyIconImageView: UIImageView!
    @IBOutlet weak var hourlyDegreeLabel: UILabel!
    
   
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        self.hourlyTitleLabel.text = ""
//        self.hourlyPercentLabel.text = ""
//        self.hourlyDegreeLabel.text = ""
//        self.hourlyIconImageView.image = UIImage.init()
//    }
}
