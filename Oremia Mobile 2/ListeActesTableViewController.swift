//
//  ListeActesTableViewController.swift
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
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredFavoris = []
        var cpt = 0
        for _ in favorisPlus {
            let key = Array(favorisPlus[cpt].keys)[0]
            let array = favorisPlus[cpt][key]
            var i = 0
            filteredFavoris?.append(contentsOf: array!.filter { pres in
                let p = pres
                let dexcr = p.description
                let previous = i > 0 ? array?[i-1] : nil
                var prevMatch = false
                if let p = previous{
                    if dexcr.range(of: "+") != nil {
                        let index = dexcr.characters.distance(from: dexcr.startIndex, to: (dexcr.range(of: "+")?.lowerBound)!)
                        if index == 0 && p.description.lowercased().contains(searchText.lowercased()){
                            prevMatch = true
                        }
                    }
                }
                i += 1
                return dexcr.lowercased().contains(searchText.lowercased()) || prevMatch
                })
            cpt += 1
        }
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        }
        return favorisPlus.count ?? 0
    }
    
    func refresh(){
        api.getIniFile("SELECT inifile FROM config WHERE titre ='ccam_favoris' AND idpraticien = \(preference.idUser) ")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filteredFavoris?.count ?? 0
        }
        let key = Array(favorisPlus[section].keys)[0]
        let array = favorisPlus[section][key]
        return array?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prestationCell", for: indexPath) as! ListeActesTableViewCell
        var pres:Prestation
        if searchController.isActive && searchController.searchBar.text != "" {
            pres = self.filteredFavoris![indexPath.row]
        }else {
            let key = Array(favorisPlus[indexPath.section].keys)[0]
            let array = favorisPlus[indexPath.section][key]
            pres = array![indexPath.row]
        }
        var description = pres.description ?? "Aucune description disponible"
        var index = 1
        if description.range(of: "+") != nil {
            
            index = description.characters.distance(from: description.startIndex, to: (description.range(of: "+")?.lowerBound)!)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let schema = actesController?.schemaDentController{
            
            self.addActeForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema, section: indexPath.section)
            addAllActesForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema, section: indexPath.section)
            
            
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView()
        var title = Array(favorisPlus[section].keys)[0]
        title.remove(at: title.characters.index(title.startIndex, offsetBy: 0))
        view.titleLabel.text = title
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didSelectHeader(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let index = self.sectionShow.index(of: indexPath.section) {
            return 45
        }else if searchController.isActive  && searchController.searchBar.text != "" {
            return 45
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 0
        }
        return 45
    }
    
    func didSelectHeader(_ sender : UITapGestureRecognizer){
        let tapLocation = sender.location(in: self.tableView)
        let formerIndex = sectionShow.count > 0 ? sectionShow[0] : 0
        let formerIndexSet = IndexSet(integer: formerIndex)
        if let indexPath : IndexPath = self.tableView.indexPathForRow(at: tapLocation){
            let section = indexPath.section
            if formerIndex != section || sectionShow.count == 0{
                self.sectionShow = [section]
                let indexSet = IndexSet(integer: section)
                self.tableView.reloadSections(formerIndexSet, with: UITableViewRowAnimation.automatic)
                self.tableView.reloadSections(indexSet, with: UITableViewRowAnimation.automatic)
            }else{
                self.sectionShow = []
                self.tableView.reloadSections(formerIndexSet, with: UITableViewRowAnimation.automatic)
            }
        }else{
            self.sectionShow = []
            self.tableView.reloadSections(formerIndexSet, with: UITableViewRowAnimation.automatic)
        }
    }
    
    func didReceiveAPIResults(_ results: NSDictionary) {
        if let resultsArr: NSArray = results["results"] as? NSArray {
            DispatchQueue.main.async(execute: {
                let prestation = Prestation.prestationWithJSON(resultsArr)
                self.prestation = prestation.favoris
                self.favorisPlus = prestation.favorisPlus
                self.tableView.reloadData()
                if self.actesController?.finished > 1 {
                    LoadingOverlay.shared.hideOverlayView()
                } else {
                    self.actesController?.finished = (self.actesController?.finished)! + 1
                }
            })
        }
        
    }
    func handleError(_ results: Int) {
        //api.getIniFile("SELECT inifile FROM config WHERE titre ='ccam_favoris' AND idpraticien = \(preference.idUser) ")
    }
    
    func addAllActesForCell(_ indexPath:Int, selectedCell:[Int]? = nil, schema:SchemaDentaireCollectionViewController? = nil, section: Int? = nil){
        var i = indexPath + 1
        var index = 0
        var array:[Prestation] = []
        if let s = section{
            let key = Array(favorisPlus[s].keys)[0]
            array = favorisPlus[s][key] ?? []
            if searchController.isActive && searchController.searchBar.text != "" {
                array = self.filteredFavoris!
            }
            
            while index == 0 {
                index = 1
                if array.count > i {
                    if let pres = array[i] as? Prestation{
                        let description = pres.description ?? "Aucune description disponible"
                        if description.range(of: "+") != nil {
                            index = description.characters.distance(from: description.startIndex, to: (description.range(of: "+")?.lowerBound)!)
                        }
                        if index == 0{
                            addActeForCell(i, selectedCell: selectedCell, schema: schema, section:section)
                            
                            i += 1
                        }
                    }
                }
            }
            api.insertActes(self.patient!, actes: self.actesController!.saisieActesController!.prestation )
        }
    }
    
    
    func addActeForCell(_ indexPath:Int, selectedCell:[Int]? = nil, schema:SchemaDentaireCollectionViewController? = nil, section: Int? = nil){
        var selectedCell = selectedCell
        var presta:Prestation
        if let s = section{
            if searchController.isActive && searchController.searchBar.text != "" {
                presta = self.filteredFavoris![indexPath]
            }else {
                let key = Array(favorisPlus[s].keys)[0]
                let array = favorisPlus[s][key]
                presta = array![indexPath]
            }
            let date = ToolBox.getFormatedDateWithSlash(Date())
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
                        let newPresta = PrestationActe(nom: numPresta + 2, coefficient: cotation, description: descriptif, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: 0, image: image, montant: montant, numDent: localisation, dateActe: date)
                        acte.prestation.append(newPresta)
                        if image != ""{
                            self.actesController?.schemaDentController?.chart?.sql += "('\(self.patient!.id)', '\(ToolBox.getFormatedDate(Date()))', '\(localisation)', '\(image)'),"
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
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


