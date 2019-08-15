//
//  Extensions.swift
//  WeatherCast
//
//  Created by yerinaoh on 07/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

class Extensions: NSObject {
}

extension Int {
    func getTimeString() -> String {
        let date: NSDate = NSDate(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a HH:mm"
        dateFormatter.locale = Locale(identifier: "ko")
        let result = dateFormatter.string(from: date as Date)
        
        return result
    }
    
    func getDateString() -> String {
        let date: NSDate = NSDate(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "ko")
        let result = dateFormatter.string(from: date as Date)
        
        return result
    }
}

extension String {
    
    func getBackgroundImage() -> UIImage {
        
        var imageName = "sunny_bg.jpeg"
        switch self {
        case "02d", "03d", "04d":
            imageName = "cloudy_bg.jpg"
            break
        case "09d", "10d":
            imageName = "rain_bg.jpg"
            break
        case "11d":
            imageName = "thunder_bg.jpg"
            break
        case "13d":
            imageName = "snow_bg.jpg"
            break
        case "50d":
            imageName = "mist_bg.jpg"
            break
        default:
            break
        }
        
        return UIImage.init(named: imageName) ?? UIImage.init()
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
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    self.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}

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
}
