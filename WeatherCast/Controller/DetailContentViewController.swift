//
//  DetailContentViewController.swift
//  WeatherCast
//
//  Created by Yesrina__dev Oh on 09/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

class DetailContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var pageIndex: Int!
    var titleText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.titleText
    }

}
