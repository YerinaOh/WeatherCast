//
//  MainViewController.swift
//  WeatherCast
//
//  Created by yerinaoh on 07/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    var regionArray = [RegionModel]()
    var mainData = [GroupWeatherListModel]()
    var selectIndexPath: IndexPath? = nil
    var transition: TransitionModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        DatabaseService.shared.read { (regionArray, success) in
            if success {
                self.regionArray = regionArray
                self.loadWeatherDataWithIds()
            }
        }
    }
    
    func loadWeatherDataWithIds() {
        let ids = (regionArray.map{String(describing: $0.id!)}).joined(separator: ",")
        NetworkService.shared.loadWeatherWithIDs(ids: ids, successHandler: { (itemArray) in
            if itemArray != nil {
                DispatchQueue.main.async {
                    self.mainData = itemArray ?? []
                    self.mainTableView.reloadData()
                }
            }
        }, errorHandler: { (error) in
            self.showAlert(body: "잠시 후 시도해 주세요 \(error.debugDescription)", cancel: "취소", buttons: ["확인"], actionHandler:nil)
        })
    }
    
    private func showDetailViewController(row: Int) {
        self.performSegue(withIdentifier: "DetailSegue", sender: row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            let row = sender as! Int
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.regionArray = regionArray
            detailViewController.selectIndex = row
            detailViewController.groupWeatherView = mainData
            detailViewController.delegate = self
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

// MARK: DetailViewDelegate
extension MainViewController: DetailViewDelegate {
    func backHome() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transition?.bgView.frame = self.transition?.bgViewFrame ?? CGRect.zero
        }) { (finished) in
            self.transition?.bgView.removeFromSuperview()
        }
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
        
        if let weather = self.mainData.get(indexPath.row) {
            if regionArray.count > indexPath.row, regionArray.get(indexPath.row) != nil {
                cell.mainTitleLabel.text = regionArray.get(indexPath.row)?.city
            } else {
                cell.mainTitleLabel.text = weather.name
            }
            
            cell.mainTimeLabel.text = weather.dt?.getTimeString()
            cell.mainTemperatureLabel.text = weather.main?.temp?.getFahrenheitValue(isFahrenheit: !Celsius.isCelsius) ?? ""
            cell.mainImageView.image = weather.weather?.first?.icon?.getBackgroundImage()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
        
        if self.selectIndexPath != indexPath {
            self.selectIndexPath = indexPath
        }
        
        if let weather = self.mainData.get(indexPath.row) {
            let bgViewFrame = cell.mainImageView.superview?.convert(cell.mainImageView.frame, to: nil)
            let tempBGView = UIImageView(frame: bgViewFrame!)
            tempBGView.image = weather.weather?.first?.icon?.getBackgroundImage()
            tempBGView.layer.masksToBounds = true
            tempBGView.contentMode = UIImageView.ContentMode.scaleAspectFill
            view.addSubview(tempBGView)
            
            self.transition = TransitionModel(bgView: tempBGView, bgViewFrame: tempBGView.frame)
            
            UIView.animate(withDuration: 0.2, animations: {
                tempBGView.frame = self.view.frame
            }) { (success) in
                self.showDetailViewController(row: indexPath.row)
            }
        }
    }
}
