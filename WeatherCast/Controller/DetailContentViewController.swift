//
//  DetailContentViewController.swift
//  WeatherCast
//
//  Created by Yesrina__dev Oh on 09/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

class DetailContentViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var weatherTableView: UITableView!
    
    var contentRegionData: RegionModel!
    var contentWeatherData: ResultWeatherModel?
    var pageIndex: Int!
    var titleText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityLabel.text = self.titleText
        
        self.showSpinner(onView: self.view)
        loadWeather { (success) in
            self.weatherLabel.text = self.contentWeatherData?.hourly?.summary
            
            self.removeSpinner()
            self.weatherTableView.isHidden = false
            
            let tempDouble = floor(self.contentWeatherData?.hourly?.data?.get(0)?.temperature ?? 0)
            let tempInt = Int(tempDouble.getCelsiusValue(isCelsius: Celsius.isCelsius) ?? 0)
            self.degreeLabel.text = String(tempInt) + "°"
            
            self.weatherTableView.reloadData()
        }
   
        weatherTableView.backgroundColor = UIColor.clear
    }
    
    func loadWeather(completion :@escaping (Bool) -> ()) {
        
        NetworkService.shared.loadWeatherWithTimely(item: contentRegionData, successHandler: { (item) in
            if item != nil {
                DispatchQueue.main.async {
                    self.contentWeatherData = item
                    completion(true)
                }
            } else {
                completion(false)
            }
        }, errorHandler: { (error) in
            self.showAlert(body: "잠시 후 시도해 주세요 \(error.debugDescription)", cancel: "취소", buttons: ["확인"], actionHandler:nil)
            completion(false)
        })
    }
    
    func getWeatherInfoWithModel(item: DarkWeatherModel) -> [[String]] {
    
        let sunriseTime = item.sunriseTime?.getTimeString() ?? ""
        let sunsetTime = item.sunsetTime?.getTimeString() ?? ""
        
        let infoModel = [[sunriseTime, sunsetTime], [String(format: "%0.f%%", (item.precipProbability ?? 0) * 100), String(format: "%0.f%%", (item.humidity ?? 0) * 100)],
                        [String(format: "%0.fm/s", item.windSpeed ?? 0), String(format: "%0.f%%", (item.cloudCover ?? 0) * 100)],
                        [String(format: "%0.fcm", (item.precipIntensity ?? 0) * 100), String(format: "%0.fhPa", item.pressure ?? 0)],
                        [String(format: "%0.fkm", item.visibility ?? 0), "\(String(describing: item.uvIndex!))"]]
        
        return infoModel
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension DetailContentViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - HeaderInSection
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: DailySectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DailySectionTableViewCell") as! DailySectionTableViewCell
        if section == 1 {
            if let hourlyData = contentWeatherData?.hourly?.data {
                sectionView.hourlyData = hourlyData
            }
        }
        return sectionView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let count = (contentWeatherData?.daily?.data?.count ?? 0) + CastInfo.todayDescriptionCount + CastInfo.todayInfo.count - 1
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayCastTableViewCell", for: indexPath) as! TodayCastTableViewCell
        
        if let dailyData = contentWeatherData?.daily?.data {
            
            if (indexPath.section == 0) || (indexPath.row < dailyData.count - 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DailyCastTableViewCell", for: indexPath) as! DailyCastTableViewCell
                let index = indexPath.section == 0 ? indexPath.row : indexPath.row + 1
                
                let data = dailyData.get(index)
                let maxTemp = data?.temperatureHigh?.getCelsiusValue(isCelsius: Celsius.isCelsius)
                let minTemp = data?.temperatureLow?.getCelsiusValue(isCelsius: Celsius.isCelsius)
                cell.todayLabel.isHidden = indexPath.section == 0 ? false : true
                cell.indexPath = indexPath
                cell.dayLabel.text = data?.time?.getDateString()
                cell.maxTempLabel.text = String(maxTemp ?? 0)
                cell.minTempLabel.text = String(minTemp ?? 0)
                cell.iconView.downloadImage(iconCode: data?.icon?.geticonImageCode() ?? "01d")
                
                return cell
            } else if indexPath.row >= ((dailyData.count - 1) + CastInfo.todayDescriptionCount) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TodayCastInfoTableViewCell", for: indexPath) as! TodayCastInfoTableViewCell
                let index = indexPath.row - (dailyData.count - 1 + CastInfo.todayDescriptionCount)
                let data = dailyData.get(0)
                
                if data != nil {
                    let infoArray = self.getWeatherInfoWithModel(item: data!)
                    cell.leftTitleLabel.text = CastInfo.todayInfo.get(index)?.get(0)
                    cell.leftValueLabel.text = infoArray.get(index)?.get(0)
                    cell.rightTitleLabel.text = CastInfo.todayInfo.get(index)?.get(1)
                    cell.rightValueLabel.text = infoArray.get(index)?.get(1)
                }
                
                return cell
            }
            cell.infoLabel.text = String(format: "주간 날씨 : %@\n오늘 날씨 : %@", contentWeatherData?.daily?.summary ?? "평소와 동일합니다.", dailyData.get(0)?.summary ?? "평소와 동일합니다.")
        }
        
        return cell
    }
}

// MARK: Scroll
extension DetailContentViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        for cell in self.weatherTableView.visibleCells {
            let hiddenFrameHeight = scrollView.contentOffset.y + 120 - cell.frame.origin.y
            
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                if let customCell = cell as? DailyCastTableViewCell {
                    if customCell.indexPath.section == 1 {
                        customCell.maskCell(fromTop: hiddenFrameHeight)
                    }
                }
            }
        }
    }
}
