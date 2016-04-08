//
//  ImageScrollViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 01/06/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit

class ImageScrollViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var tapped: UITapGestureRecognizer!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet var bottomLayout: UIView!
    var lastZoomScale: CGFloat = -1
    var imageScrollLargeImageName:UIImage?
    var pageIndex: Int?
    var navigationHeight : CGFloat = 0
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        imageView.image = imageScrollLargeImageName
        scrollView.delegate = self
        updateZoom()
        updateConstraints()
        tapped.addTarget(self, action: "handleTap")
        let TapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap")
        TapRecognizer.numberOfTapsRequired = 1
        TapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(TapRecognizer)
    }
    
    // Update zoom scale and constraints
    // It will also animate because willAnimateRotationToInterfaceOrientation
    // is called from within an animation block
    //
    // DEPRECATION NOTICE: This method is said to be deprecated in iOS 8.0. But it still works.
    override func willAnimateRotationToInterfaceOrientation(
        toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
            
            super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
            updateZoom()
            updateConstraints()

    }
    
    func handleTap() {
        if self.navigationController?.navigationBarHidden == false{
            self.navigationController?.setNavigationBarHidden(true, animated: true)
           // setTabBarVisible(true, animated: true)
        }else{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
           // setTabBarVisible(false, animated: true)
        }

    }
    func updateConstraints() {
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = view.bounds.size.width
            let viewHeight = view.bounds.size.height
            let scrollViewScale = scrollView.zoomScale
            // center image if it is smaller than screen
            var hPadding = ((viewWidth - scrollViewScale * imageWidth) / 2) + 20
            if hPadding < 0 { hPadding = 0 }
            
            var vPadding = (viewHeight - scrollViewScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            
            imageConstraintTop.constant = vPadding
            imageConstraintBottom.constant = vPadding
            
            // Makes zoom out animation smooth and starting from the right point not from (0, 0)
            view.layoutIfNeeded()
        }
    }
    
    // Zoom to show as much image as possible unless image is smaller than screen
    private func updateZoom() {
        if let image = imageView.image {
            var minZoom = min(view.bounds.size.width / image.size.width,
                view.bounds.size.height / image.size.height)
            
            //if minZoom > 1 { minZoom = 1 }
            
            scrollView.minimumZoomScale = minZoom
            
            // Force scrollViewDidZoom fire if zoom did not change
            if minZoom == lastZoomScale { minZoom += 0.000001 }
            
            scrollView.zoomScale = minZoom
            lastZoomScale = minZoom
        }
    }
    
    // UIScrollViewDelegate
    // -----------------------
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
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
