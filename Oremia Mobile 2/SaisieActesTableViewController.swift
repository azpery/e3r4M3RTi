//
//  SaisieActesTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 27/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SaisieActesTableViewController: UITableViewController, APIControllerProtocol{
    var prestation = [PrestationActe]()
    lazy var api:APIController = APIController(delegate: self)
    var patient:patients?
    var actesController:ActesViewController?
    var selectedActe:PrestationActe?
    override func viewDidLoad() {
        super.viewDidLoad()
        api.getIniFile("SELECT inifile FROM fses WHERE idPatient = \((self.patient?.id)!) AND idpraticien = \(preference.idUser) ")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ToolBox.setDefaultBackgroundMessage(self.tableView, elements: self.prestation.count, message: "Cette FSE est vide.")
        return self.prestation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saisieActesCell", for: indexPath) as! SaisieActesTableViewCell
        let pres = self.prestation[indexPath.row]
        cell.descriptif.text = pres.description
        cell.date.text = pres.dateActe
        cell.localisation.text = "\(pres.numDent )"
        cell.lettre.text = "\(pres.lettreCle)"
        cell.cotation.text = "\(pres.coefficient)"
        cell.depense.text = "\(pres.qualificatif)"
        cell.montant.text = "\(pres.montant) €"
        if pres.note != ""{
            cell.noteImage.isHidden = false
        }else{
            cell.noteImage.isHidden = true
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.prestation.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            _ = api.insertActes(self.patient!, actes: prestation, success: {defaut->Bool in return true} )
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedActe = self.prestation[indexPath.row]
        self.actesController!.performSegue(withIdentifier: "showNoteActe", sender: self.actesController)
    }
    
    func callback(_ text:String)->Bool{
        selectedActe?.note = text
        _ = api.insertActes(self.patient!, actes: self.actesController!.saisieActesController!.prestation, success: {defaut->Bool in return true} )
        return false
    }
    
    func refresh()
    {
        api.getIniFile("SELECT inifile FROM fses WHERE idPatient = \((self.patient?.id)!) AND idpraticien = \(preference.idUser) ")
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "saisieActesHeader") as! HeaderActesTableViewCell
        
        return headerCell
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        DispatchQueue.main.async(execute: {
                let prestation = PrestationActe.prestationActesWithJSON(resultsArr)
                self.prestation = prestation.sorted(by: {$0.nom > $1.nom})
                self.actesController?.schemaDentController?.chart?.addLayersFromPrestation(self.prestation)
                self.actesController?.schemaDentController?.collectionView?.reloadData()
                self.actesController?.listeActesController?.prestation.sort(by: {$0.nom < $1.nom})
                self.tableView.reloadData()
                if self.actesController?.finished > 1 {
                    LoadingOverlay.shared.hideOverlayView()
                } else {
                    self.actesController?.finished = (self.actesController?.finished)! + 1
                }
        })
    }
    func handleError(_ results: Int) {
        api.getIniFile("SELECT inifile FROM config WHERE titre ='favoris' AND idpraticien = 500 ")
    }

    
}
