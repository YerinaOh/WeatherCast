//
//  WeatherModel.swift
//  WeatherCast
//
//  Created by yerinaoh on 10/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

// MARK: Dark api
struct DarkWeatherModel: Decodable {
    /*
     "time": 1565443370,
     "summary": "흐림",
     "icon": "cloudy",
     "nearestStormDistance": 0,
     "precipIntensity": 0,
     "precipProbability": 0,
     "temperature": 78.97,
     "apparentTemperature": 79.95,
     "dewPoint": 69.13,
     "humidity": 0.72,
     "pressure": 1008.3,
     "windSpeed": 3.65,
     "windGust": 5.98,
     "windBearing": 56,
     "cloudCover": 0.93,
     "uvIndex": 0,
     "visibility": 10,
     "temperatureHigh": 86.93,
     "temperatureLow": 70.9,
     "sunriseTime": 1565815526,
     "sunsetTime": 1565864692,
     "precipProbability": 0.54,
     "precipIntensity": 0.0049
     */

    let time: Int? //time
    let summary: String? // description
    let icon: String? //icon(state)
    let temperature: Double? //기온 
    let apparentTemperature: Double? //체감기온
    let dewPoint: Double? //이슬점
    let humidity: Double? //습도
    let pressure: Double? //기압
    let windSpeed: Double? //바람속도
    let windGust: Double? //풍량
    let windBearing: Double? //바람방향
    let cloudCover: Double? //구름 percentage
    let uvIndex: Int? //자외선지수
    let visibility: Double? //가시거리
    let temperatureHigh: Double? //최고기온
    let temperatureLow: Double? //최저기온
    let sunriseTime: Int? //일몰
    let sunsetTime: Int? //일출
    let precipProbability: Double?//비 올 확률
    let precipIntensity: Double?//강수량

    init(time: Int? = nil,
         summary: String? = nil,
         icon: String? = nil,
         temperature: Double? = nil,
         apparentTemperature: Double? = nil,
         dewPoint: Double? = nil,
         humidity: Double? = nil,
         pressure: Double? = nil,
         windSpeed: Double? = nil,
         windGust: Double? = nil,
         windBearing: Double? = nil,
         cloudCover: Double? = nil,
         uvIndex: Int? = nil,
         visibility: Double? = nil,
         temperatureHigh: Double? = nil,
         temperatureLow: Double? = nil,
         sunriseTime: Int? = nil,
         sunsetTime: Int? = nil,
         precipProbability: Double? = nil,
         precipIntensity: Double? = nil) {
        self.time = time
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.dewPoint = dewPoint
        self.humidity = humidity
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.windGust = windGust
        self.windBearing = windBearing
        self.cloudCover = cloudCover
        self.uvIndex = uvIndex
        self.visibility = visibility
        self.temperatureHigh = temperatureHigh
        self.temperatureLow = temperatureLow
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
        self.precipProbability = precipProbability
        self.precipIntensity = precipIntensity
    }
}

//struct DarkCurrentWeatherModel: Decodable {
//    /*
//     "region": RegionModel,
//     "time": 1565443370,
//     "icon": "cloudy",
//     "temperature": 78.97 */
//    var region: RegionModel?
//
//    let time: Int? //time
//    let icon: String? // icon
//    let temperature: Double? //temperature
//
//    init(region: RegionModel? = nil, time: Int? = nil, icon: String? = nil, temperature: Double? = nil) {
//        self.region = region
//        self.time = time
//        self.icon = icon
//        self.temperature = temperature
//    }
//}

struct TimelyWeatherModel: Decodable {
    /*
     "region": RegionModel,
     "time": 1565443370,
     "icon": "cloudy",
     "temperature": 78.97 */
    var region: RegionModel?
    
    let summary: String? //time
    let icon: String? // icon
    let data: [DarkWeatherModel]? //temperature

    init(summary: String? = nil, icon: String? = nil, data: [DarkWeatherModel]? = nil) {
        self.summary = summary
        self.icon = icon
        self.data = data
    }
}

struct ResultWeatherModel: Decodable {
    /*
     "hourly": TimelyWeatherModel
     "daily": TimelyWeatherModel
     */
    let hourly: TimelyWeatherModel?
    let daily: TimelyWeatherModel?
    
    init(hourly: TimelyWeatherModel? = nil, daily: TimelyWeatherModel? = nil) {
        self.hourly = hourly
        self.daily = daily
    }
}

// MARK: openweather api
struct SysModel: Decodable {
    /*
     "sunrise": 1565498348,
     "sunset": 1565551955 */
    
    let sunrise: Int?
    let sunset: Int?
    
    init(sunrise: Int? = nil, sunset: Int? = nil) {
        self.sunrise = sunrise
        self.sunset = sunset
    }
}

struct WeatherModel: Decodable {
    /*
     "main": "Clouds",
     "description": "broken clouds",
     "icon": "04d" */

    let main: String?
    let description: String?
    let icon: String?
    
    init(main: String? = nil, description: String? = nil, icon: String? = nil) {
        self.main = main
        self.description = description
        self.icon = icon
    }
}

struct WeatherMainModel: Decodable {
    /*
     "temp": 20.66,
     "pressure": 1011,
     "humidity": 53,
     "temp_min": 18.33,
     "temp_max": 22.78 */
    
    let temp: Double?
    let pressure: Double?
    let humidity: Double?
    let temp_min: Double?
    let temp_max: Double?

    init(temp: Double? = nil, pressure: Double? = nil, humidity: Double? = nil, temp_min: Double? = nil, temp_max: Double? = nil) {
        self.temp = temp
        self.pressure = pressure
        self.humidity = humidity
        self.temp_min = temp_min
        self.temp_max = temp_max
    }
}

struct GroupWeatherListModel: Decodable {
    /*
     "weather": [],
     "main": {},
     "dt": 1565525360,
     "id": 2643743 */
    var weather: [WeatherModel]?
    var main: WeatherMainModel?
    let id: Int?
    let dt: Int?
    let name: String?
    
    init(weather: [WeatherModel]? = nil, main: WeatherMainModel? = nil, id: Int? = nil, dt: Int? = nil, name: String?) {
        self.weather = weather
        self.main = main
        self.id = id
        self.dt = dt
        self.name = name
    }
}

struct GroupWeatherModel: Decodable {
    /* "cnt": 2,
     "list": []*/
    let cnt: Int?
    var list: [GroupWeatherListModel]?
    
    init(cnt: Int? = nil, list: [GroupWeatherListModel]? = nil) {
        self.cnt = cnt
        self.list = list
    }

}
