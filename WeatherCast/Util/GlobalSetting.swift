//
//  GlobalSetting.swift
//  WeatherCast
//
//  Created by yerinaoh on 12/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

struct Celsius {
    static var isCelsius: Bool = true
}

struct WeatherAPI {
    static let baseURL: String = "http://api.openweathermap.org/data/2.5"
    static let category_weather: String = "/weather"
    static let category_group: String = "/group"
    static let category_daily: String = "/forecast/daily"
    static let category_hourly: String = "/forecast/hourly"
    
    static let appid: String = "cd0f31cb992882e8ac660df8a5f61f66"
}

struct DarkWeatherAPI {
    static let baseURL: String = "https://api.darksky.net/forecast"
    
    static let appid: String = "04a30a306192ba304f05e686e10634c0"
}

struct CastInfo {
    static let todayInfo: [[String]] = [["일출", "일몰"], ["비 올 확률", "습도"], ["바람", "구름량"], ["강수량", "기압"], ["가시거리", "자외선 지수"]]
    
    static let todayDescriptionCount: Int = 1
}
