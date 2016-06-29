//
//  SplitViewExtension.swift
//  OremiaMobile2
//
//  Created by Zumatec on 29/06/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
extension UISplitViewController {
    var xx_primaryViewController: UIViewController? {
        get {
            return (self.viewControllers.first ?? UIViewController() as UIViewController) ?? nil
        }
    }
    
    var xx_secondaryViewController: UIViewController? {
        get {
            if self.viewControllers.count > 1 {
                return self.viewControllers[1]
            }
            return nil
        }
    }
}