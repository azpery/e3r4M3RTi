//
//  ListeActesTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 27/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class ListeActesTableViewController: UITableViewController, APIControllerProtocol, UIGestureRecognizerDelegate {
    var prestation = [Prestation]()
    lazy var api:APIController = APIController(delegate: self)
    var patient:patients?
    var actesController:ActesViewController?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredFavoris:[Prestation]?
    var favorisPlus = [[String:[Prestation]]]()
    var favorisViewController:FavorisTableViewController?
    var sectionShow = [Int]()
    var selectedCell = [Int]()
    
    
    
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
        filteredFavoris = []
        var cpt = 0
        for favoris in favorisPlus {
            let key = Array(favorisPlus[cpt].keys)[0]
            let array = favorisPlus[cpt][key]
            filteredFavoris?.appendContentsOf(array!.filter { pres in
                let p = pres
                let dexcr = p.description
                return dexcr.lowercaseString.containsString(searchText.lowercaseString)
                })
            cpt++
        }
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return 1
        }
        return favorisPlus.count ?? 0
    }
    
    func refresh(){
        api.getIniFile("SELECT inifile FROM config WHERE titre ='ccam_favoris' AND idpraticien = \(preference.idUser) ")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return self.filteredFavoris?.count ?? 0
        }
        let key = Array(favorisPlus[section].keys)[0]
        let array = favorisPlus[section][key]
        return array?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("prestationCell", forIndexPath: indexPath) as! ListeActesTableViewCell
        var pres:Prestation
        if searchController.active && searchController.searchBar.text != "" {
            pres = self.filteredFavoris![indexPath.row]
        }else {
            let key = Array(favorisPlus[indexPath.section].keys)[0]
            let array = favorisPlus[indexPath.section][key]
            pres = array![indexPath.row]
        }
        var description = pres.description ?? "Aucune description disponible"
        var index = 1
        if description.rangeOfString("+") != nil {
            
            index = description.startIndex.distanceTo((description.rangeOfString("+")?.startIndex)!)
        }
        
        if index == 0{
            description = "      \(description)"
            cell.descriptifLabel.textColor = ToolBox.UIColorFromRGB(0x878787)
        }else {
            cell.descriptifLabel.textColor = ToolBox.UIColorFromRGB(0x000000)
        }
        cell.descriptifLabel.text = description
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let schema = actesController?.schemaDentController{
            
            self.addActeForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema, section: indexPath.section)
            addAllActesForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema, section: indexPath.section)
            
            
        }
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView()
        var title = Array(favorisPlus[section].keys)[0]
        title.removeAtIndex(title.startIndex.advancedBy(0))
        view.titleLabel.text = title
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didSelectHeader(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        return view
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let index = self.sectionShow.indexOf(indexPath.section) {
            return 45
        }else if searchController.active  && searchController.searchBar.text != "" {
            return 45
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.active && searchController.searchBar.text != "" {
            return 0
        }
        return 45
    }
    
    func didSelectHeader(sender : UITapGestureRecognizer){
        let tapLocation = sender.locationInView(self.tableView)
        let formerIndex = sectionShow.count > 0 ? sectionShow[0] : 0
        let formerIndexSet = NSIndexSet(index: formerIndex)
        if let indexPath : NSIndexPath = self.tableView.indexPathForRowAtPoint(tapLocation){
            let section = indexPath.section
            if formerIndex != section || sectionShow.count == 0{
                self.sectionShow = [section]
                let indexSet = NSIndexSet(index: section)
                self.tableView.reloadSections(formerIndexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
            }else{
                self.sectionShow = []
                self.tableView.reloadSections(formerIndexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }else{
            self.sectionShow = []
            self.tableView.reloadSections(formerIndexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        if let resultsArr: NSArray = results["results"] as? NSArray {
            dispatch_async(dispatch_get_main_queue(), {
                let prestation = Prestation.prestationWithJSON(resultsArr)
                self.prestation = prestation.favoris
                self.favorisPlus = prestation.favorisPlus
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
    
    func addAllActesForCell(indexPath:Int, selectedCell:[Int]? = nil, schema:SchemaDentaireCollectionViewController? = nil, section: Int? = nil){
        var i = indexPath + 1
        var index = 0
        var array = []
        if let s = section{
            let key = Array(favorisPlus[s].keys)[0]
            array = favorisPlus[s][key]!
            if !searchController.active && section != nil && array.count > i {
                while index == 0 {
                    index = 1
                    var pres:Prestation
                    pres = array[i] as! Prestation
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
    }
    
    
    func addActeForCell(indexPath:Int, var selectedCell:[Int]? = nil, schema:SchemaDentaireCollectionViewController? = nil, section: Int? = nil){
        var presta:Prestation
        if let s = section{
            if searchController.active && searchController.searchBar.text != "" {
                presta = self.filteredFavoris![indexPath]
            }else {
                let key = Array(favorisPlus[s].keys)[0]
                let array = favorisPlus[s][key]
                presta = array![indexPath]
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
                    for cell in selectedCell! {
                        let localisation = schema?.chart?.localisationFromIndexPath(cell) ?? 0
                        let newPresta = PrestationActe(nom: numPresta + 2, coefficient: cotation, description: descriptif, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: 0, image: image, montant: montant, numDent: cell, dateActe: date)
                        acte.prestation.append(newPresta)
                        if image != ""{
                            self.actesController?.schemaDentController?.chart?.sql += "('\(self.patient!.id)', '\(ToolBox.getFormatedDate(NSDate()))', '\(localisation)', '\(image)'),"
                        }
                        
                    }
                    if(selectedCell?.count == 0){
                        let localisation = 0
                        let newPresta = PrestationActe(nom: numPresta + 2, coefficient: cotation, description: descriptif, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: 0, image: image, montant: montant, numDent: localisation, dateActe: date)
                        acte.prestation.append(newPresta)
                    }
                    if image != ""{
                        schema!.addImageToSelectedCell(image)
                    }
                    
                }else{
                    let localisation = 0
                    let newPresta = PrestationActe(nom: numPresta + 2, coefficient: cotation, description: descriptif, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: 0, image: image, montant: montant, numDent: localisation, dateActe: date)
                    acte.prestation.append(newPresta)
                }
                schema?.reloadSelectedCell()
                acte.tableView.reloadData()
                
            }
        }
    }
    
    
}

extension ListeActesTableViewController: UISearchResultsUpdating, UISearchBarDelegate,  UISearchDisplayDelegate, UISearchControllerDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


