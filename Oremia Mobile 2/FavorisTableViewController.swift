//
//  FavorisTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 14/07/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class FavorisTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var listeController:ListeActesTableViewController?
    var filteredFavoris:[Prestation]?
    let searchController = UISearchController(searchResultsController: nil)
    var favorisPlus:[String:[Prestation]]?
    var sectionShow = [Int]()
    var selectedCell = [Int]()
    
    @IBOutlet var closeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        closeButton.setFAIcon(FAType.faTimes, iconSize: 24)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        super.viewDidLoad()
        
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredFavoris = []
        for (_,favoris) in favorisPlus! {
            filteredFavoris?.append(contentsOf: favoris.filter { pres in
                let p = pres
                let dexcr = p.description
                return dexcr.lowercased().contains(searchText.lowercased())
                })
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
        let key = Array(favorisPlus!.keys)
        return key.count 
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filteredFavoris?.count ?? 0
        }
        let key = Array(favorisPlus!.keys)[section]
        let array = favorisPlus![key]
        return array?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favorisCell", for: indexPath) as! ListeActesTableViewCell
        var pres:Prestation
        if searchController.isActive && searchController.searchBar.text != "" {
            pres = self.filteredFavoris![indexPath.row]
        }else {
            let key = Array(favorisPlus!.keys)[indexPath.section]
            let array = favorisPlus![key]
            pres = array![indexPath.row]
        }
        var description = pres.description 
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
        if let schema = self.listeController?.actesController?.schemaDentController{
            
            self.listeController?.addActeForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema, section: indexPath.section)
            self.listeController?.addAllActesForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema, section: indexPath.section)
            
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.sectionShow.index(of: indexPath.section) != nil {
            return 45
        }else if searchController.isActive  && searchController.searchBar.text != "" {
            return 45
        }
        return 0
        
        
    }
    
    func didSelectHeader(_ sender : UITapGestureRecognizer){
        let tapLocation = sender.location(in: self.tableView)
        let formerIndex = sectionShow.count > 0 ? sectionShow[0] : 1
        let formerIndexSet = IndexSet(integer: formerIndex)
        if let indexPath : IndexPath = self.tableView.indexPathForRow(at: tapLocation){
            let section = indexPath.section
            if formerIndex != section{
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView()
        let key = Array(favorisPlus!.keys)
        var title = key[section]
        title.remove(at: title.characters.index(title.startIndex, offsetBy: 0))
        view.titleLabel.text = title
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didSelectHeader(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        return view
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 0
        }
        return 45
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
    }
    
}

extension FavorisTableViewController: UISearchResultsUpdating, UISearchBarDelegate,  UISearchDisplayDelegate, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
