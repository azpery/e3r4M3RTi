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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0 :
            label!.text = "À l'heure"
            break
        case 1 :
            label!.text = "En retard"
            break
        case 2 :
            label!.text = "Retard important"
            break
        case 3 :
            label!.text = "Annulé avant 48 heures"
            break
        case 4 :
            label!.text = "Absence"
            break
        case 5 :
            label!.text = "Annulé"
            break
        
        default:
            label!.text = "À l'heure"
            break
        }
        eventManager!.internalEvent.statut = indexPath.row + 1
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
}
