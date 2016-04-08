//
//  StatutTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class StatutTableViewController: UITableViewController {
    var eventManager:EventManager?
    var label:UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row{
        case 1 :
            label!.text = "À l'heure"
            break
        case 2 :
            label!.text = "En retard"
            break
        case 3 :
            label!.text = "Retard important"
            break
        case 4 :
            label!.text = "Annulé avant 48 heures"
            break
        case 5 :
            label!.text = "Annulé"
            break
        default:
            label!.text = "À l'heure"
            break
        }
        eventManager!.internalEvent.statut = indexPath.row + 1
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
