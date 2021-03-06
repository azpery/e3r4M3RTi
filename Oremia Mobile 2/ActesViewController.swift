//
//  ActesViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 20/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class ActesViewController: UIViewController {
    var schemaDentController:SchemaDentaireCollectionViewController?
    var saisieActesController:SaisieActesTableViewController?
    var listeActesController:ListeActesTableViewController?
    let scl = SCLAlertView()
    var activityIndicator = DTIActivityIndicatorView()
    var finished = 0
    @IBOutlet var leftPanel: UIView!
    @IBOutlet var bottomPanel: UIView!
    @IBOutlet var rightPanel: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.indicatorColor = UIColor.blackColor()
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
        
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
            destinationView.actesController = self
            self.schemaDentController = destinationView
        }else
        if segue.destinationViewController.isKindOfClass(SaisieActesTableViewController){
            let destinationView: SaisieActesTableViewController = segue.destinationViewController as! SaisieActesTableViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            destinationView.patient = tb.patient!
            destinationView.actesController = self
            self.saisieActesController = destinationView
        }else if segue.destinationViewController.isKindOfClass(ListeActesTableViewController){
            let destinationView: ListeActesTableViewController = segue.destinationViewController as! ListeActesTableViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            destinationView.patient = tb.patient!
            destinationView.actesController = self
            self.listeActesController = destinationView
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
