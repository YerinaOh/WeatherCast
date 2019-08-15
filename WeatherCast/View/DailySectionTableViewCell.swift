//
//  DailySectionTableViewCell.swift
//  WeatherCast
//
//  Created by yerinaoh on 14/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

class DailySectionTableViewCell: UITableViewCell {

    @IBOutlet weak var hourlyCollectionView: UICollectionView!

    var hourlyData = [DarkWeatherModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hourlyCollectionView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension DailySectionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.hourlyData.count > 10 {
            return 10
        }
        return self.hourlyData.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HourlyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCollectionViewCell", for: indexPath) as! HourlyCollectionViewCell
        
        if let data = self.hourlyData.get(indexPath.row) {
            
            let tempDouble = floor(data.temperature ?? 0)
            let tempInt = Int(tempDouble.getCelsiusValue(isCelsius: Celsius.isCelsius) ?? 0)
            cell.hourlyDegreeLabel.text = String(tempInt) + "°"
            let time: String = data.time?.getShortTimeString() ?? "오전 0"
            cell.hourlyTitleLabel.text = time + "시"
            let iconCode = data.icon?.geticonImageCode()
            cell.hourlyIconImageView.downloadImage(iconCode: iconCode ?? "01d")
            
            if iconCode == "09d" {
                cell.hourlyPercentLabel.isHidden = false
                cell.hourlyPercentLabel.text = String(format: "%0.f%%", (data.precipProbability ?? 0) * 100)
            } else {
                cell.hourlyPercentLabel.isHidden = true
            }
        }
        
        return cell
    }
}
