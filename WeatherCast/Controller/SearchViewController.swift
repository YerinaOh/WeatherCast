//
//  SearchViewController.swift
//  WeatherCast
//
//  Created by Yesrina__dev Oh on 08/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchData = [RegionModel]()
    private var searchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("취소", forKey:"_cancelButtonText")
        searchController.searchBar.tintColor = UIColor.gray
        searchController.searchBar.barTintColor = UIColor.black
        searchController.searchBar.showsCancelButton = true
        
        searchTableView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        searchTableView.tableHeaderView = searchController.searchBar
    }
   
    func updateFilter(searchText: String) {
        
        if searchText.count > 0 {
            DispatchQueue.global(qos: .userInteractive).async {
                NetworkService.updateSearchResults(searchText: searchText, completion: { (item) in
                    DispatchQueue.main.async {
                        self.searchData = item
                        self.searchTableView.reloadData()
                    }
                })
            }
        } else {
            self.searchData = []
            self.searchTableView.reloadData()
        }
    }
}

// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    
    //(MKErrorDomain error 3.) 에러 핸들링을 위한 Timer 추가. 190809 https://stackoverflow.com/questions/47688976/why-do-i-get-an-mkerrordomain-error-when-doing-a-local-search
    func updateSearchResults(for searchController: UISearchController) {
        if let searchTimer = searchTimer {
            searchTimer.invalidate()
        }
         searchTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(timerDidFire(_:)), userInfo: nil, repeats: false)
    }
   
    @objc func timerDidFire(_ sender: Any) {
        guard let query = searchController.searchBar.text else { return }
        updateFilter(searchText: query)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        
        cell.textLabel?.font.withSize(11)
        cell.textLabel?.text = searchData[indexPath.row].city ?? ""
        cell.detailTextLabel?.text = searchData[indexPath.row].address
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = searchData[indexPath.row]
        
        NetworkService.loadWeatherWithCoordinates(item: item, successHandler: { regionModel in
            guard  regionModel?.id ?? 0 > 0 else {
                DispatchQueue.main.async {
                    self.searchController.dismiss(animated: true, completion: nil)
                    self.showAlert(body: "해당 데이터는 준비중이에요 조금만 기다려주세요 ㅜ.ㅜ", cancel: nil, buttons: ["확인"], actionHandler:nil)
                }
                return
            }
            DatabaseService.shared.insert(source: regionModel!, completion: { success in
                if success == true {
                    DispatchQueue.main.async {
                        self.searchController.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }) { (error) in
            self.showAlert(body: "네트워크 연결에 실패하였습니다. 잠시 후 재시도 해 주세요. \nerror : \(error.debugDescription)", cancel: "취소", buttons: ["확인"], actionHandler:nil)
        }
    }
}
