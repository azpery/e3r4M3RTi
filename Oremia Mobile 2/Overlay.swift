//
//  LoadingOverlay.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit
import Foundation

@objc open class Overlay:NSObject{
    
    var overlayView = UIView()
    var view = UIView()
    var messageLbl = UILabel()
    
    class var shared: Overlay {
        struct Static {
            static let instance: Overlay = Overlay()
        }
        return Static.instance
    }
    
    open func showOverlay(_ view: UIView!,text:String) {
        overlayView = UIView(frame:CGRect(x: 0, y: 0,
            width: view.bounds.size.width,
            height: view.bounds.size.height+500))
        self.view = view
        overlayView.backgroundColor = UIColor.white
        displayText(text)
        overlayView.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(overlayView)
        overlayView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        overlayView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
    }
 
    open func hideOverlayView() {
        messageLbl.removeFromSuperview()
        overlayView.removeFromSuperview()
    }
    
    open func displayText(_ text:String){
        messageLbl = UILabel( frame:CGRect(x: 0, y: 0,
            width: view.bounds.size.width,
            height: view.bounds.size.height))
        messageLbl.text = text
        messageLbl.font = UIFont(name: "Avenir Next", size: 30)
        messageLbl.textColor = ToolBox.UIColorFromRGB(0x878787)
        messageLbl.textAlignment = NSTextAlignment.center
        messageLbl.translatesAutoresizingMaskIntoConstraints = true
        overlayView.addSubview(messageLbl)
        messageLbl.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        messageLbl.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
    }
    

}
