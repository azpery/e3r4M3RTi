//
//  EtatCivilNavigationViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 04/06/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit

class EtatCivilNavigationViewController: UINavigationController {
    var profilePicture : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func unwindToEtatCivil(segue: UIStoryboardSegue) {
        if self.profilePicture != nil{
        let rootView = self.topViewController as! EtatCivilViewController
        rootView.profilePicture.image = profilePicture
        //showViewController(EtatCivilViewController(), sender: self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
