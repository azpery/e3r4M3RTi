//
//  FavorisTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 14/07/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class FavorisTableViewController: UITableViewController {

    var listeController:ListeActesTableViewController?
    var filteredFavoris:[Prestation]?
    let searchController = UISearchController(searchResultsController: nil)
    var favorisPlus:[String:[Prestation]]?
    
    @IBOutlet var closeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        closeButton.setFAIcon(FAType.FATimes, iconSize: 24)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        super.viewDidLoad()

    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredFavoris = []
        for (_,favoris) in favorisPlus! {
            filteredFavoris?.appendContentsOf(favoris.filter { pres in
                let p = pres 
                let dexcr = p.description
                return dexcr.lowercaseString.containsString(searchText.lowercaseString)
                })
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
        let key = Array(favorisPlus!.keys)
        return key.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return self.filteredFavoris?.count ?? 0
        }
        let key = Array(favorisPlus!.keys)[section]
        let array = favorisPlus![key]
        return array?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favorisCell", forIndexPath: indexPath) as! ListeActesTableViewCell
        var pres:Prestation
        if searchController.active && searchController.searchBar.text != "" {
            pres = self.filteredFavoris![indexPath.row]
        }else {
            let key = Array(favorisPlus!.keys)[indexPath.section]
            let array = favorisPlus![key]
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
//    override func viewDidAppear(animated: Bool) {
//        //self.tableView.reloadData()
//    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let schema = self.listeController?.actesController?.schemaDentController{
            
            self.listeController?.addActeForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema, section: indexPath.section)
            self.listeController?.addAllActesForCell(indexPath.row, selectedCell: schema.selectedCell, schema: schema, section: indexPath.section)
            
            
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView()
        let key = Array(favorisPlus!.keys)
        let title = key[section]
        view.titleLabel.text = title
        return view
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.active && searchController.searchBar.text != "" {
            return 0
        }
        return 45
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

}

extension FavorisTableViewController: UISearchResultsUpdating, UISearchBarDelegate,  UISearchDisplayDelegate, UISearchControllerDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}