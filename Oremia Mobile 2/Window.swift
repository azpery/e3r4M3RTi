//
//  Window.swift
//  OremiaMobile2
//
//  Created by Zumatec on 17/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
public extension UIApplication {
            class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
            
            if let nav = base as? UINavigationController {
                return topViewController(nav.visibleViewController)
            }
            
            if let tab = base as? UITabBarController {
                let moreNavigationController = tab.moreNavigationController
                
                if let top = moreNavigationController.topViewController where top.view.window != nil {
                    return topViewController(top)
                } else if let selected = tab.selectedViewController {
                    return topViewController(selected)
                }
            }
            
            if let presented = base?.presentedViewController {
                return topViewController(presented)
            }
            
            return base
        }

}