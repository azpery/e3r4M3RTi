//
//  TabBarViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 18/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    var patient:patients?
    var fromCal = false
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // set red as selected background color
        let tabBarItemSize = CGSize(width: tabBar.frame.width , height: tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(ToolBox.UIColorFromRGB(0xE86A0E), size: tabBarItemSize).resizableImage(withCapInsets: UIEdgeInsets.zero)
        
        // remove default border
        tabBar.frame.size.width = self.view.frame.width + 4
        tabBar.frame.origin.x = -2
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor.white).withRenderingMode(.alwaysOriginal)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let radioCollectionViewController: RadioCollectionViewController = segue.destination as! RadioCollectionViewController
        radioCollectionViewController.patient = patient!
    }
    //Write your code here

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
