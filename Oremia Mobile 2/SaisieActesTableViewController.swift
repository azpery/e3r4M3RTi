//
//  SaisieActesTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 27/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class SaisieActesTableViewController: UITableViewController, APIControllerProtocol{
    var prestation = [PrestationActe]()
    lazy var api:APIController = APIController(delegate: self)
    var patient:patients?
    var actesController:ActesViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        api.getIniFile("SELECT inifile FROM fses WHERE idPatient = \((self.patient?.id)!) AND idpraticien = \(preference.idUser) ")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ToolBox.setDefaultBackgroundMessage(self.tableView, elements: self.prestation.count, message: "Cette FSE est vide.")
        return self.prestation.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("saisieActesCell", forIndexPath: indexPath) as! SaisieActesTableViewCell
        let pres = self.prestation[indexPath.row]
        cell.descriptif.text = pres.description
        cell.date.text = pres.dateActe
        cell.localisation.text = "\(pres.numDent )"
        cell.lettre.text = "\(pres.lettreCle)"
        cell.cotation.text = "\(pres.coefficient)"
        cell.depense.text = "\(pres.qualificatif)"
        cell.montant.text = "\(pres.montant)E"
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.prestation.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            api.insertActes(self.patient!, actes: prestation, success: {defaut->Bool in return true} )
        }
    }
    
    func refresh()
    {
        api.getIniFile("SELECT inifile FROM fses WHERE idPatient = \((self.patient?.id)!) AND idpraticien = \(preference.idUser) ")
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("saisieActesHeader") as! HeaderActesTableViewCell
        
        return headerCell
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
                let prestation = PrestationActe.prestationActesWithJSON(resultsArr)
                self.prestation = prestation.sort({$0.nom > $1.nom})
                self.actesController?.schemaDentController?.chart?.addLayersFromPrestation(self.prestation)
                self.actesController?.schemaDentController?.collectionView?.reloadData()
                self.actesController?.listeActesController?.prestation.sortInPlace({$0.nom < $1.nom})
                self.tableView.reloadData()
                if self.actesController?.finished > 1 {
                    self.actesController?.activityIndicator.stopActivity(true)
                    self.actesController?.activityIndicator.removeFromSuperview()
                } else {
                    self.actesController?.finished++
                }
        })
    }
    func handleError(results: Int) {
        api.getIniFile("SELECT inifile FROM config WHERE titre ='favoris' AND idpraticien = 500 ")
    }

    
}
