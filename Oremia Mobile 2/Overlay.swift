//
//  LoadingOverlay.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit
import Foundation

@objc public class Overlay:NSObject{
    
    var overlayView = UIView()
    var view = UIView()
    var messageLbl = UILabel()
    
    class var shared: Overlay {
        struct Static {
            static let instance: Overlay = Overlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView!,text:String) {
        overlayView = UIView(frame:CGRectMake(0, 0,
            view.bounds.size.width,
            view.bounds.size.height+500))
        self.view = view
        overlayView.backgroundColor = UIColor.whiteColor()
        displayText(text)
        overlayView.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(overlayView)
        overlayView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        overlayView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
    }
 
    public func hideOverlayView() {
        messageLbl.removeFromSuperview()
        overlayView.removeFromSuperview()
    }
    
    public func displayText(text:String){
        messageLbl = UILabel( frame:CGRectMake(0, 0,
            view.bounds.size.width,
            view.bounds.size.height))
        messageLbl.text = text
        messageLbl.font = UIFont(name: "Avenir Next", size: 30)
        messageLbl.textColor = ToolBox.UIColorFromRGB(0x878787)
        messageLbl.textAlignment = NSTextAlignment.Center
        messageLbl.translatesAutoresizingMaskIntoConstraints = true
        overlayView.addSubview(messageLbl)
        messageLbl.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        messageLbl.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
    }
    

}