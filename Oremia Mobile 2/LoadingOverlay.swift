//
//  LoadingOverlay.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit
import Foundation

@objc open class LoadingOverlay:NSObject{
    
    var overlayView = UIView()
    var activityIndicator = DTIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    open func showOverlay(_ view: UIView!) {
        overlayView = UIView(frame: view.frame)
        overlayView.backgroundColor = UIColor.white
        
//        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
//        activityIndicator.center = overlayView.center
//        overlayView.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
        LoadingOverlay.updateBlur(overlayView)
        view.addSubview(overlayView)
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.black
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
    }
    static func updateBlur(_ view: UIView!) {


        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        // 2
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        // 3
        blurView.translatesAutoresizingMaskIntoConstraints = false
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        // 2
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        // 3
//        vibrancyView.contentView.addSubview(superView)
        // 4
        blurView.contentView.addSubview(vibrancyView)
        view.insertSubview(blurView, at: 0)
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .height, relatedBy: .equal, toItem: view,
            attribute: .height, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .width, relatedBy: .equal, toItem: view,
            attribute: .width, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: vibrancyView,
            attribute: .height, relatedBy: .equal,
            toItem: view, attribute: .height,
            multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: vibrancyView,
            attribute: .width, relatedBy: .equal,
            toItem: view, attribute: .width,
            multiplier: 1, constant: 0))
        view.addConstraints(constraints)
    }
    open func hideOverlayView() {
        activityIndicator.stopActivity()
        activityIndicator.removeFromSuperview()
        overlayView.removeFromSuperview()
    }
}
