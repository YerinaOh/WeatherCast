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

    var matchingItems: [RegionModel] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var searchTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false

        searchController.searchBar.setValue("취소", forKey:"_cancelButtonText")
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.black
        searchController.searchBar.backgroundColor = UIColor.darkGray
        searchController.searchBar.showsCancelButton = true
        
        searchTableView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        searchTableView.tableHeaderView = searchController.searchBar
    }
   
    private func updateFilter(searchText: String) {
        NetworkService.shared.updateSearchResults(searchController: searchController, completion: { (item) in
            self.matchingItems = item
            self.searchTableView.reloadData()
        })
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
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            self.updateFilter(searchText: searchController.searchBar.text ?? "")
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        
        cell.textLabel?.font.withSize(11)
        cell.textLabel?.text = matchingItems[indexPath.row].city ?? ""
        cell.detailTextLabel?.text = matchingItems[indexPath.row].address
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = matchingItems[indexPath.row]
        
        NetworkService.shared.loadWeatherWithCoordinates(item: item, successHandler: {  [weak self] regionModel in
            
            
            DatabaseService.shared.insert(source: regionModel!, completion: { [weak self] success in
                if success == true {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }) { (error) in
            self.showAlert(body: "네트워크 연결에 실패하였습니다. 잠시 후 재시도 해 주세요. \nerror : \(error.debugDescription)", cancel: "취소", buttons: ["확인"], actionHandler:nil)
        }
    }
}
