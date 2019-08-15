//
//  DetailViewController.swift
//  WeatherCast
//
//  Created by yerinaoh on 07/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit

protocol DetailViewDelegate {
    func backHome()
}

class DetailViewController: UIViewController {

    @IBOutlet weak var detailBGImageView: UIImageView!
    @IBOutlet weak var homeButton: UIButton!
    var pageViewController: UIPageViewController!
    
    var detailRegionData = [RegionModel]()
    var detailWeatherData = [GroupWeatherListModel]()
    var selectIndex: Int = 0
    var delegate: DetailViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationItem.hidesBackButton = true
        
        detailBGImageView.image = detailWeatherData.get(selectIndex)?.weather?.first?.icon?.getBackgroundImage()

        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        self.pageViewController.dataSource = self
        if self.pageViewController.viewControllers?.count ?? 0 > 0 {
            self.pageViewController.setViewControllers([], direction: .forward, animated: true, completion: nil)
        }
        
        let startController = self.viewControllerAtIndex(index: self.selectIndex) as DetailContentViewController
        let viewControllers = NSArray(object: startController)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController] , direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = self.view.frame
        
        self.addChild(self.pageViewController)
        self.view.insertSubview(self.pageViewController.view, belowSubview: homeButton)
    }
    
    func viewControllerAtIndex(index: Int) -> DetailContentViewController {
        
        let detailController: DetailContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailContentViewController") as! DetailContentViewController
        
        detailController.pageIndex = index
        detailController.titleText = self.detailRegionData[index].city
        detailController.contentRegionData = self.detailRegionData[index]
        detailBGImageView.image = detailWeatherData.get(index)?.weather?.first?.icon?.getBackgroundImage()
             
        return detailController
    } 
}

// MARK: Action
extension DetailViewController {
    @IBAction func backHomeAction(_ sender: Any) {
        guard let delegate = delegate else { return }
        delegate.backHome()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIPageViewControllerDataSource
extension DetailViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! DetailContentViewController
        var index = contentViewController.pageIndex as Int
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        index = index - 1
        
       return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! DetailContentViewController
        var index = contentViewController.pageIndex as Int
        
        if index == NSNotFound || index + 1 == self.detailRegionData.count {
            return nil
        }
        index = index + 1
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.detailRegionData.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return selectIndex
    }
}
