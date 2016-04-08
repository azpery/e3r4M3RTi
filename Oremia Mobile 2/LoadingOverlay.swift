//
//  LoadingOverlay.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit
import Foundation

@objc public class LoadingOverlay:NSObject{
    
    var overlayView = UIView()
    var activityIndicator = DTIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView!) {
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor(patternImage: UIImage(named: "sprite")!)
        
//        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
//        activityIndicator.center = overlayView.center
//        overlayView.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
        LoadingOverlay.updateBlur(overlayView)
        view.addSubview(overlayView)
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.blackColor()
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
    }
    static func updateBlur(view: UIView!) {


        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        // 2
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        // 3
        blurView.translatesAutoresizingMaskIntoConstraints = false
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        // 2
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        // 3
//        vibrancyView.contentView.addSubview(superView)
        // 4
        blurView.contentView.addSubview(vibrancyView)
        view.insertSubview(blurView, atIndex: 0)
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .Height, relatedBy: .Equal, toItem: view,
            attribute: .Height, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .Width, relatedBy: .Equal, toItem: view,
            attribute: .Width, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: vibrancyView,
            attribute: .Height, relatedBy: .Equal,
            toItem: view, attribute: .Height,
            multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: vibrancyView,
            attribute: .Width, relatedBy: .Equal,
            toItem: view, attribute: .Width,
            multiplier: 1, constant: 0))
        view.addConstraints(constraints)
    }
    public func hideOverlayView() {
        activityIndicator.stopActivity()
        overlayView.removeFromSuperview()
    }
}