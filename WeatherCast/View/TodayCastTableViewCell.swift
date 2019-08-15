//
//  TodayCastTableViewCell.swift
//  WeatherCast
//
//  Created by yerinaoh on 13/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

class TodayCastTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
