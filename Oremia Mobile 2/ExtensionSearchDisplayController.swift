//
//  ExtensionSearchDisplayController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 10/07/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation


class MySearchDisplayController : UISearchDisplayController {
    override func setActive(visible:Bool, animated:Bool)
    {
        super.setActive(visible, animated: animated);
    
        self.searchContentsController.navigationController!.setNavigationBarHidden(false, animated: false);
    }
}