//
//  Extensions.swift
//  WeatherCast
//
//  Created by yerinaoh on 07/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit
import MapKit

class Extensions: NSObject {
}

extension Int {
    func getTimeString() -> String {
        let date: Date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let result = dateFormatter.string(from: date as Date)
        
        return result
    }
    
    func getTimeStringFromSecond() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: self)
        
        return dateFormatter.string(from: Date())
    }
    
    func getShortTimeString() -> String {
        let date: Date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a HH"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let result = dateFormatter.string(from: date as Date)
        
        return result
    }
    
    func getDateString() -> String {
        let date: Date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let result = dateFormatter.string(from: date as Date)
        
        return result
    }
}

extension String {
    
    func getBackgroundImage() -> UIImage {
        
        var imageName = "sunny_bg.jpeg"
        switch self {
        case "02d", "03d", "02n", "03n":
            imageName = "cloudy_bg.jpg"
            break
        case "04d", "09d", "10d", "04n", "09n", "10n":
            imageName = "rain_bg.jpg"
            break
        case "11d","11n":
            imageName = "thunder_bg.jpg"
            break
        case "13d","13n":
            imageName = "snow_bg.jpg"
            break
        case "50d","50n":
            imageName = "mist_bg.jpg"
            break
        default:
            break
        }
        
        return UIImage.init(named: imageName) ?? UIImage.init()
    }
    
    /*icon matching (DarkSky.icon -> OpenWeatherMap.icon)
     https://openweathermap.org/weather-conditions
     https://darksky.net/dev/docs
     */
    func geticonImageCode() -> String {
        
        if self.contains("clear") {
            return "01d"
        } else if self.contains("cloudy") || self.contains("wind"){
            return "03d"
        } else if self.contains("rain") || self.contains("hail"){
            return "09d"
        } else if self.contains("thunderstorm") || self.contains("tornado"){
            return "11d"
        } else if self.contains("snow") || self.contains("sleet") {
            return "13d"
        } else if self.contains("fog") {
            return "50d"
        }
        return "01d"
    }
}

extension Array {
    func get(_ index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

extension JSONDecoder {
    public func decode<T: Decodable>(_ type: T.Type, form object: Any, options opt: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object, options: opt)
        return try decode(T.self, from: data)
    }
}

extension Double {
    func getCelsiusValue(isCelsius: Bool) -> Int? {
        if isCelsius {
            return Int((self - 32) / 1.8)
        }
        return Int(self)
    }
    func getFahrenheitValue(isFahrenheit: Bool) -> String? {
        if isFahrenheit {
            return "\(Int((self * 1.8) + 32))°"
        }
        return "\(Int(self))°"
    }
}

extension UIImageView {
    func downloadImage(iconCode: String) {
        if let url = URL.init(string: "http://openweathermap.org/img/wn/\(iconCode)@2x.png") {
            DispatchQueue.global(qos: .userInteractive).async {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() {
                        self.image = UIImage(data: data)
                    }
                    }.resume()
            }
        }
    }
}

var vSpinner : UIView?
extension UIViewController {
    func showAlert(isAction: Bool = false, title: String = "", body: String? = nil, cancel: String? = nil, buttons: [String] = ["확인"], actionHandler: ((Int) -> Void)? = nil, cancelHandler: (() -> Void)? = nil) {
        let alertController: UIAlertController = UIAlertController(title: title, message: body, preferredStyle: isAction ? .actionSheet: .alert)
        
        if let cancelText = cancel {
            let cancelAction: UIAlertAction = UIAlertAction(title: cancelText, style: UIAlertAction.Style.cancel) { (action) in
                if let handler = cancelHandler {
                    handler()
                }
            }
            alertController.addAction(cancelAction)
        }
        
        for (index, text) in buttons.enumerated() {
            let alertAction: UIAlertAction = UIAlertAction(title: text, style: UIAlertAction.Style.default) { (action) in
                if let handler = actionHandler {
                    handler(index)
                }
            }
            alertController.addAction(alertAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSpinner(onView : UIView) {
        
        if vSpinner != nil {
            return
        }
        let spinnerView = UIView.init(frame: onView.bounds)

        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        spinnerView.addSubview(ai)
        onView.addSubview(spinnerView)
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        vSpinner?.removeFromSuperview()
        vSpinner = nil
    }
}

extension MKPlacemark {
    func getAddress() -> String {
        
        let firstSpace = (self.subThoroughfare != nil && self.thoroughfare != nil) ? " " : ""
        let comma = (self.subThoroughfare != nil || self.thoroughfare != nil) && (self.subAdministrativeArea != nil || self.administrativeArea != nil) ? ", " : ""
        let secondSpace = (self.subAdministrativeArea != nil && self.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@ %@",
            // street number
            self.subThoroughfare ?? "",
            firstSpace,
            // street name
            self.thoroughfare ?? "",
            comma,
            // city
            self.locality ?? "",
            secondSpace,
            // state
            self.administrativeArea ?? ""
        )
        
        return addressLine
    }
}

extension UITableViewCell {
    func maskCell(fromTop margin: CGFloat) {
        layer.mask = visibilityMask(withLocation: margin / frame.size.height)
        layer.masksToBounds = true
    }
    
    func visibilityMask(withLocation location: CGFloat) -> CAGradientLayer {
        let mask = CAGradientLayer()
        mask.frame = bounds
        mask.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        let num = location as NSNumber
        mask.locations = [num, num]
        return mask
    }
}
