//
//  ListeActesTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 27/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class ListeActesTableViewController: UITableViewController, APIControllerProtocol {
    var prestation = NSArray()
    lazy var api:APIController = APIController(delegate: self)
    var patient:patients?
    var actesController:ActesViewController?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPrestations = [Prestation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.getIniFile("SELECT inifile FROM config WHERE titre ='ccam_favoris' AND idpraticien = \(preference.idUser) ")
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredPrestations = prestation.filter { pres in
            let p = pres as! Prestation
            let dexcr = p.description
            return dexcr.lowercaseString.containsString(searchText.lowercaseString)
            } as! [Prestation]
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func refresh(){
        api.getIniFile("SELECT inifile FROM config WHERE titre ='ccam_favoris' AND idpraticien = \(preference.idUser) ")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredPrestations.count
        }
        return self.prestation.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("prestationCell", forIndexPath: indexPath) as! ListeActesTableViewCell
        var pres:Prestation?
        if searchController.active && searchController.searchBar.text != "" {
            pres = self.filteredPrestations[indexPath.row] as? Prestation
        } else {
            pres = self.prestation[indexPath.row] as? Prestation
        }
        var description = pres?.description ?? "Aucune description disponible"
        var index = 1
        if description.rangeOfString("+") != nil {
            
            index = description.startIndex.distanceTo((description.rangeOfString("+")?.startIndex)!)
        }
        if description.rangeOfString("-") != nil && index != 0 {
            
            index = description.startIndex.distanceTo((description.rangeOfString("-")?.startIndex)!)
        }
        
        if index == 0{
            if !searchController.active && searchController.searchBar.text == ""{
                description = "      \(description)"
                cell.descriptifLabel.textColor = ToolBox.UIColorFromRGB(0x878787)
            }
        }else {
            cell.descriptifLabel.textColor = ToolBox.UIColorFromRGB(0x000000)
        }
        cell.descriptifLabel.text = description
        return cell
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView()
        let title = "Liste des actes favoris"
        view.titleLabel.text = title
        return view
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let schema = actesController?.schemaDentController{
            self.addActeForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema)
            addAllActesForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema)
            
            
        }
    }
    
    func addAllActesForCell(indexPath:Int, selectedCell:[Int]? = nil, schema:SchemaDentaireCollectionViewController? = nil){
        var i = indexPath + 1
        var index = 0
        if searchController.active && searchController.searchBar.text != "" && filteredPrestations.count > i || prestation.count > i {
            while index == 0 {
                index = 1
                var pres:Prestation
                if searchController.active && searchController.searchBar.text != "" {
                    pres = filteredPrestations[i]
                }else{
                    pres = prestation[i] as! Prestation
                }
                let description = pres.description ?? "Aucune description disponible"
                if description.rangeOfString("+") != nil {
                    index = description.startIndex.distanceTo((description.rangeOfString("+")?.startIndex)!)
                }
                if index == 0{
                    addActeForCell(i, selectedCell: selectedCell, schema: schema)
                    
                    i++
                }
            }
            api.insertActes(self.patient!, actes: self.actesController!.saisieActesController!.prestation )
        }
        
    }
    
    
    func addActeForCell(indexPath:Int, var selectedCell:[Int]? = nil, schema:SchemaDentaireCollectionViewController? = nil){
        let index = indexPath
        var presta:Prestation
        if searchController.active && searchController.searchBar.text != "" {
            presta = filteredPrestations[index]
        }else{
            presta = prestation[index] as! Prestation
        }
        let date = ToolBox.getFormatedDateWithSlash(NSDate())
        let cotation = presta.coefficient
        let descriptif = presta.description
        let montant = presta.montant
        let qualificatif = presta.qualificatif
        let lettreCle = presta.lettreCle
        let image = presta.image
        if let acte = self.actesController?.saisieActesController{
            let numPresta = acte.prestation.count ?? 1
            if selectedCell == nil{
                selectedCell = [0]
            }
            if schema != nil && selectedCell != nil{
                var query = ""
                for cell in selectedCell! {
                    let localisation = schema?.chart?.localisationFromIndexPath(cell)
                    let newPresta = PrestationActe(nom: numPresta + 1, coefficient: cotation, description: descriptif, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: 0, image: image, montant: montant, numDent: cell, dateActe: date)
                    acte.prestation.append(newPresta)
                    if image != ""{
                        api.sendInsert("INSERT INTO chart(idpatient, date, localisation, layer) VALUES('\(self.patient!.id)', '\(ToolBox.getFormatedDate(NSDate()))', '\(localisation)', '\(image)');")
                    }
                    
                }
                if image != ""{
                    schema!.addImageToSelectedCell(image)
                }
                
            }
            schema?.reloadSelectedCell()
            acte.tableView.reloadData()
            
        }
    }
    
    
    func didReceiveAPIResults(results: NSDictionary) {
        if let resultsArr: NSArray = results["results"] as? NSArray {
            dispatch_async(dispatch_get_main_queue(), {
                let prestation = Prestation.prestationWithJSON(resultsArr)
                self.prestation = prestation.sort({$0.nom < $1.nom})
                self.tableView.reloadData()
                if self.actesController?.finished > 1 {
                    self.actesController?.activityIndicator.stopActivity(true)
                    self.actesController?.activityIndicator.removeFromSuperview()
                } else {
                    self.actesController?.finished++
                }
            })
        }
        
    }
    func handleError(results: Int) {
        //api.getIniFile("SELECT inifile FROM config WHERE titre ='ccam_favoris' AND idpraticien = \(preference.idUser) ")
    }
    
}

extension ListeActesTableViewController: UISearchResultsUpdating, UISearchBarDelegate,  UISearchDisplayDelegate, UISearchControllerDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


