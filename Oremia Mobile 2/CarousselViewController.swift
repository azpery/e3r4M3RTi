//
//  CarousselViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class CarousselViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var pageViews: [UIImageView?] = []

    var imageCache = [UIImage]()
    var count = 0
    var pageViewController : UIPageViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.initScroll()
//        self.loadVisiblePages()
        reset()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func swipeLeft(_ sender: AnyObject) {
        print("SWipe left")
    }
    @IBAction func swiped(_ sender: AnyObject) {
        
        self.pageViewController.view .removeFromSuperview()
        self.pageViewController.removeFromParentViewController()
        reset()
    }
    override func viewWillDisappear(_ animated: Bool) {
        setTabBarVisible(true, animated: true)
    }

    func reset() {
        /* Getting the page View controller */
        setTabBarVisible(false, animated: true)
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        self.pageViewController.view.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.layer.frame.height)!, width: self.view.frame.width, height: self.view.frame.height  )
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
    }
    
    @IBAction func start(_ sender: AnyObject) {
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! ImageScrollViewController).pageIndex!
    index += 1
    if(index == self.imageCache.count){
    return nil
    }
    return self.viewControllerAtIndex(index)
    
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! ImageScrollViewController).pageIndex!
    if(index == 0){
    return nil
    }
    index -= 1
    return self.viewControllerAtIndex(index)
    
    }
    
    func viewControllerAtIndex(_ index : Int) -> UIViewController? {
    if((self.imageCache.count == 0) || (index >= self.imageCache.count)) {
    return nil
    }
    let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewController")as! ImageScrollViewController
    pageContentViewController.navigationHeight = (self.navigationController?.navigationBar.frame.height)!
    pageContentViewController.imageScrollLargeImageName = self.imageCache[index]
//    pageContentViewController.titleText = self.pageTitles[index]
         
    pageContentViewController.pageIndex = index
    return pageContentViewController
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return imageCache.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return 0
    }
    func setTabBarVisible(_ visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animate(withDuration: duration, animations: {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }) 
        }
    }
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < self.view.frame.maxY
    }


}
