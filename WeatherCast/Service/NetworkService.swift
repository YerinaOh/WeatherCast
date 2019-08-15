//
//  NetworkService.swift
//  WeatherCast
//
//  Created by Yesrina__dev Oh on 10/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit
import MapKit

class NetworkService: NSObject {

    static let shared = NetworkService()
    
    func updateSearchResults(searchController: UISearchController, completion:@escaping ([RegionModel]) -> Void){
        guard let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            guard let response = response else {
                return
            }
            var regionItem = [RegionModel]()
            regionItem = response.mapItems.compactMap(RegionModel.init)
            completion(regionItem)
        }
    }
    
    //API : Location 에 따른 Weather 값 Call - http://api.openweathermap.org/data/2.5/weather?lat=37.8650725&lon=127.7202456&appid=cd0f31cb992882e8ac660df8a5f61f66
    func loadWeatherWithCoordinates(item: RegionModel, successHandler: @escaping (RegionModel?) -> Void, errorHandler: @escaping (Error?) -> Void) {
        let latitude: String = String(item.latitude ?? 0)
        let longitude: String = String(item.longitude ?? 0)
        
        let param: String = "lat=\(latitude)&lon=\(longitude)&lan=ko&appid=\(WeatherAPI.appid)" //current data call
        let strUrl: String = "\(WeatherAPI.baseURL)\(WeatherAPI.category_weather)?\(param)"
        let url: URL = URL.init(string: strUrl)!
        
        loadWeatherData(url: url, successHandler: { (data) in
            if let data = data {
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                let result = json as! [String:Any]
                let id: Int = result["id"] as! Int
                var returnItem: RegionModel = item
                
                returnItem.id = id
                successHandler(returnItem)
            }
        }) { (error) in
            errorHandler(error)
        }
    }
    
    //API : Location 에 따른 Weather 값 Call - https://api.openweathermap.org/data/2.5/group?id=1845136,2643743&units=metric&appid=cd0f31cb992882e8ac660df8a5f61f66
    func loadWeatherWithIDs(ids: String, successHandler: @escaping ([GroupWeatherListModel]?) -> Void, errorHandler: @escaping (Error?) -> Void) {
        
        let param: String = "id=\(ids)&units=metric&lan=ko&appid=\(WeatherAPI.appid)" //current data call
        let strUrl: String = "\(WeatherAPI.baseURL)\(WeatherAPI.category_group)?\(param)"
        let url: URL = URL.init(string: strUrl)!
        
        loadWeatherData(url: url, successHandler: { (data) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(GroupWeatherModel.self, from: data)
                    successHandler(jsonData.list)
                } catch {
                    errorHandler(error)
                }
            }
        }) { (error) in
            errorHandler(error)
        }
    }
    
    //API : Location 에 따른 hourly, daily Weather 값 Call - Dark API 활용 https://api.darksky.net/forecast/04a30a306192ba304f05e686e10634c0/37.8650725,127.7202456?lang=ko&exclude=minutely,currently
    func loadWeatherWithTimely(item: RegionModel, successHandler: @escaping (ResultWeatherModel?) -> Void, errorHandler: @escaping (Error?) -> Void) {
        
        let param: String = "lang=ko&exclude=minutely,currently"
        let strUrl: String = "\(DarkWeatherAPI.baseURL)/\(DarkWeatherAPI.appid)/\(String(describing: item.latitude!)),\(String(describing: item.longitude!))?\(param)"
        let url: URL = URL.init(string: strUrl)!
        
        loadWeatherData(url: url, successHandler: { (data) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(ResultWeatherModel.self, from: data)
                    successHandler(jsonData)
                } catch {
                    errorHandler(error)
                }
            }
        }) { (error) in
            errorHandler(error)
        }
    }
    
    private func loadWeatherData(url: URL, successHandler: @escaping (Data?) -> Void, errorHandler: @escaping (Error?) -> Void) {

        URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                errorHandler(error)
                return
            }
            successHandler(data)
        }.resume()
    }
}


