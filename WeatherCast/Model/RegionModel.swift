//
//  RegionModel.swift
//  WeatherCast
//
//  Created by yerinaoh on 11/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit
import MapKit

struct RegionModel: Decodable {
/*
 "city": "강남구",
 "address": "대한민국 서울특별시 강남구",
 "time": 1565443370,
 "icon": "cloudy",
 "latitude": 37.8650725,
 "longitude": 127.7202456,
 "temperature": 78.97 */
    let city: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    var id: Int?
    
    init(mkItem: MKMapItem) {
        
        var cityName = ""
        if let street = mkItem.placemark.thoroughfare {
            cityName = street
        } else {
            if let name = mkItem.placemark.name {
                cityName = name
            }
        }
        
        self.city = cityName
        self.address = mkItem.placemark.getAddress()
        self.latitude = mkItem.placemark.location?.coordinate.latitude
        self.longitude = mkItem.placemark.location?.coordinate.longitude
        self.id = 0
    }
    
    init(city: String? = nil, address: String? = nil, latitude: Double? = nil, longitude: Double? = nil, id: Int) {
        self.city = city
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
    }
}
