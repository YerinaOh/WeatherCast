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
    func changeTransitionInfo(index: Int, bgImage: UIImage?)
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
        self.pageViewController.delegate = self
        
        let startController = self.viewControllerAtIndex(index: self.selectIndex) as DetailContentViewController
        let viewControllers = NSArray(object: startController)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController] , direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = self.view.frame
        
        self.addChild(self.pageViewController)
        self.view.insertSubview(self.pageViewController.view, belowSubview: homeButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let delegate = delegate {
            delegate.changeTransitionInfo(index: selectIndex, bgImage: detailBGImageView.image)
        }
    }
    
    func viewControllerAtIndex(index: Int) -> DetailContentViewController {
        
        let detailController: DetailContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailContentViewController") as! DetailContentViewController
        
        detailController.pageIndex = index
        detailController.titleText = self.detailRegionData[index].city
        detailController.contentRegionData = self.detailRegionData[index]
        
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
extension DetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentViewController = pageViewController.viewControllers![0] as? DetailContentViewController {
                selectIndex = currentViewController.pageIndex
                
                DispatchQueue.main.async {
                    UIView.transition(with: self.detailBGImageView,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve,
                                      animations: { self.detailBGImageView.image = self.detailWeatherData.get(self.selectIndex)?.weather?.first?.icon?.getBackgroundImage() },
                                      completion: nil)
                }
            }
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.detailRegionData.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return selectIndex
    }
}
