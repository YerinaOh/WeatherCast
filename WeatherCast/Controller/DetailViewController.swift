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
    var regionArray = [RegionModel]()
    var detailData : ResultWeatherModel?
    
    var bgImage: UIImage!
    var selectIndex : Int = 0
    var delegate : DetailViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationItem.hidesBackButton = true
        detailBGImageView.image = bgImage
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        self.pageViewController.dataSource = self
        
        let startController = self.viewControllerAtIndex(index: selectIndex) as DetailContentViewController
        let viewControllers = NSArray(object: startController)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController] , direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = self.view.frame
        
        self.addChild(self.pageViewController)
        self.view.insertSubview(self.pageViewController.view, belowSubview: homeButton)
        
        loadWeather()
    }
    
    func loadWeather() {
        let item = regionArray[selectIndex]
        
        NetworkService.shared.loadWeatherWithTimely(item: item, successHandler: { (item) in
            if item != nil {
                DispatchQueue.main.async {
                    self.detailData = item
                    // self.mainTableView.reloadData()
                }
            }
        }, errorHandler: { (error) in
            self.showAlert(body: "잠시 후 시도해 주세요 \(error.debugDescription)", cancel: "취소", buttons: ["확인"], actionHandler:nil)
        })
    }
    
    func viewControllerAtIndex(index: Int) -> DetailContentViewController {
        
        let detailController: DetailContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailContentViewController") as! DetailContentViewController
        
        detailController.pageIndex = index
        detailController.titleText = self.regionArray[index].city

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
        
        if index == NSNotFound || index + 1 == self.regionArray.count {
            return nil
        }
        index = index + 1
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.regionArray.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return selectIndex
    }
}
