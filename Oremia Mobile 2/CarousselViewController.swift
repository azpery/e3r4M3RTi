//
//  CarousselViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

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
    @IBAction func swipeLeft(sender: AnyObject) {
        print("SWipe left")
    }
    @IBAction func swiped(sender: AnyObject) {
        
        self.pageViewController.view .removeFromSuperview()
        self.pageViewController.removeFromParentViewController()
        reset()
    }
    override func viewWillDisappear(animated: Bool) {
        setTabBarVisible(true, animated: true)
    }

    func reset() {
        /* Getting the page View controller */
        setTabBarVisible(false, animated: true)
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        self.pageViewController.view.frame = CGRectMake(0, (self.navigationController?.navigationBar.layer.frame.height)!, self.view.frame.width, self.view.frame.height  )
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    @IBAction func start(sender: AnyObject) {
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! ImageScrollViewController).pageIndex!
    index++
    if(index == self.imageCache.count){
    return nil
    }
    return self.viewControllerAtIndex(index)
    
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! ImageScrollViewController).pageIndex!
    if(index == 0){
    return nil
    }
    index--
    return self.viewControllerAtIndex(index)
    
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
    if((self.imageCache.count == 0) || (index >= self.imageCache.count)) {
    return nil
    }
    let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController")as! ImageScrollViewController
    pageContentViewController.navigationHeight = (self.navigationController?.navigationBar.frame.height)!
    pageContentViewController.imageScrollLargeImageName = self.imageCache[index]
//    pageContentViewController.titleText = self.pageTitles[index]
         
    pageContentViewController.pageIndex = index
    return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return imageCache.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
    }
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }


}
