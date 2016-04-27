//
//  ActesViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 20/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class ActesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(SchemaDentaireCollectionViewController){
            let destinationView: SchemaDentaireCollectionViewController = segue.destinationViewController as! SchemaDentaireCollectionViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            destinationView.patient = tb.patient!
            destinationView.sourceViewNavigationBar = self.navigationController
            destinationView.sourceViewTabBar = self.tabBarController
        }
    }
            
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
