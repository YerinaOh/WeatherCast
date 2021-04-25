//
//  MainViewController.swift
//  WeatherCast
//
//  Created by yerinaoh on 07/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var regionArray = [RegionModel]()
    var currentRegion: RegionModel?
    var mainData = [GroupWeatherListModel]()
    var transition: TransitionModel!
    
    let locationManager = CLLocationManager()
    
    var isCalledCurrent: Bool = false
    var isCurrentRegionLoading: Bool = false
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isCalledCurrent == true {
            loadData()
        }
        addTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeTimer()
    }
}

// MARK: Api Call
extension MainViewController {
    
    func loadData() {
        
        DatabaseService.shared.read { (regionArray, success) in
            if success {
                if self.regionArray.count > 0 {
                    self.regionArray.removeAll()
                }
                
                self.regionArray = regionArray
                
                if self.currentRegion != nil {
                    self.regionArray.insert(self.currentRegion!, at: 0)
                }
                self.loadWeatherDataWithIds()
            }
        }
    }
    
    func loadWeatherDataWithIds() {
        let ids = (regionArray.map{String(describing: $0.id!)}).joined(separator: ",")
        
        DispatchQueue.main.async {
            self.showSpinner(onView: self.view)
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            NetworkService.loadWeatherWithIDs(ids: ids, successHandler: { (itemArray) in
                
                DispatchQueue.main.async {
                    if itemArray != nil {
                        self.mainData = itemArray ?? []
                        self.mainTableView.reloadData()
                    }
                    self.removeSpinner()
                }
            }, errorHandler: { (error) in
                self.showAlert(body: "잠시 후 시도해 주세요 \(error.debugDescription)", cancel: "취소", buttons: ["확인"], actionHandler:nil)
                self.removeSpinner()
            })
        }
    }
    
    func addTimer() {
        let cal = NSCalendar.current
        var comps = cal.dateComponents([.era, .year, .month, .day, .hour, .minute], from: Date())
        comps.minute = comps.minute! + 1
        let nextMinute = cal.date(from: comps)
        
        timer = Timer(fire: nextMinute!, interval: 60, repeats: true) { _ in
            self.loadData()
        }
        RunLoop.current.add(timer!, forMode: .default)
    }
    func removeTimer() {
        timer?.invalidate()
    }
}

// MARK: Actions
extension MainViewController {
    private func showDetailViewController(row: Int) {
        self.performSegue(withIdentifier: "DetailSegue", sender: row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let row = sender as! Int
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.detailRegionData = regionArray
            detailViewController.selectIndex = row
            detailViewController.detailWeatherData = mainData
            detailViewController.delegate = self
        } else if segue.identifier == "SearchSegue" {
            if let controller = segue.destination as? SearchViewController {
                controller.closeClosure = {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                        self.loadData()
                    }
                }
            }
        }
    }
    
    @IBAction func degreeTypeButtonAction(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        
        if let subviews = mainTableView.tableFooterView?.subviews {
            for view in subviews {
                if let subButton = view as? UIButton {
                    subButton.isSelected = false
                }
            }
        }
        
        button.isSelected = true
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        Celsius.isCelsius = (button.tag == 0) ? true : false
        self.mainTableView.reloadData()
    }
    
    
}

// MARK: CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        if isCurrentRegionLoading == false {
            isCurrentRegionLoading = true
            
            NetworkService.loadCurrentRegion(latitude: locValue.latitude, longitude: locValue.longitude) { (region) in
                if let currentRegion = region {
                    
                    if currentRegion.city != self.regionArray.first?.city {
                        
                        NetworkService.loadWeatherWithCoordinates(item: currentRegion, successHandler: { regionModel in
                            self.currentRegion = regionModel
                            self.loadData()
                            self.isCalledCurrent = true
                            self.isCurrentRegionLoading = false
                        }) { (error) in
                            self.showAlert(body: "네트워크 연결에 실패하였습니다. 잠시 후 재시도 해 주세요. \nerror : \(error.debugDescription)", cancel: "취소", buttons: ["확인"], actionHandler:nil)
                            self.loadData()
                            self.isCalledCurrent = true
                            self.isCurrentRegionLoading = false
                        }
                    }
                    self.isCurrentRegionLoading = false
                }
                self.isCalledCurrent = true
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Get Location failed")
        self.isCalledCurrent = true
        self.loadData()
    }
}

// MARK: DetailViewDelegate
extension MainViewController: DetailViewDelegate {
    func backHome() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transition.bgView.frame = self.transition.bgViewFrame
        }) { (finished) in
            self.transition.bgView.removeFromSuperview()
        }
    }
    
    func changeTransitionInfo(index: Int, bgImage: UIImage?) {
        let originY = self.mainTableView.contentOffset.y + (CGFloat(index) * self.transition.bgViewFrame.size.height) + (self.navigationController?.navigationBar.frame.size.height ?? 20)
        
        self.transition.bgViewFrame = CGRect.init(x: 0, y: originY, width: self.transition.bgViewFrame.size.width, height: self.transition.bgViewFrame.size.height)
        self.transition.bgView.image = bgImage
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        
        if let item = self.mainData.get(indexPath.row) {
            if currentRegion != nil, indexPath.row == 0 {
                cell.currentIcon.isHidden = false
            }
            
            if regionArray.count > indexPath.row, regionArray.get(indexPath.row) != nil {
                cell.mainTitleLabel.text = regionArray.get(indexPath.row)?.city
            } else {
                cell.mainTitleLabel.text = item.name
            }
            
            cell.mainTimeLabel.text = item.sys?.timezone?.getTimeStringFromSecond()
            cell.mainTemperatureLabel.text = item.main?.temp?.getFahrenheitValue(isFahrenheit: !Celsius.isCelsius) ?? ""
            cell.mainImageView.image = item.weather?.first?.icon?.getBackgroundImage()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard indexPath.row > 0 else { return }
            
            if let cityId = self.mainData.get(indexPath.row)?.id {
                if cityId > 0 {
                    DatabaseService.shared.delete(cityId: cityId, completion: { (success) in
                        if success == true {
                            self.mainData.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    })
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard  let cell = tableView.cellForRow(at: indexPath) as? MainTableViewCell else { return }
        
        if let weather = self.mainData.get(indexPath.row) {
            let bgViewFrame = cell.mainImageView.superview?.convert(cell.mainImageView.frame, to: nil)
            let tempBGView = UIImageView(frame: bgViewFrame!)
            tempBGView.image = weather.weather?.first?.icon?.getBackgroundImage()
            tempBGView.layer.masksToBounds = true
            tempBGView.contentMode = UIImageView.ContentMode.scaleAspectFill
            view.addSubview(tempBGView)
            
            self.transition = TransitionModel(bgView: tempBGView, bgViewFrame: tempBGView.frame)
            
            UIView.animate(withDuration: 0.3, animations: {
                tempBGView.frame = self.view.frame
            }) { (success) in
                self.showDetailViewController(row: indexPath.row)
            }
        }
    }
}
