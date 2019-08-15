//
//  MainCollectionViewCell.swift
//  WeatherCast
//
//  Created by yerinaoh on 07/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var mainTimeLabel: UILabel!
    @IBOutlet weak var mainTemperatureLabel: UILabel!
    @IBOutlet weak var currentIcon: UIImageView!
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
        showView()
    }
    
    private func showView() {
        let bgView = UIImageView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.layer.masksToBounds = true
        bgView.contentMode = UIImageView.ContentMode.scaleAspectFill
        
        self.mainImageView = bgView
        
        self.contentView.insertSubview(bgView, belowSubview: mainTitleLabel)
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgView.topAnchor.constraint(equalTo: self.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
