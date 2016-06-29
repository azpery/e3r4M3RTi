//
//  ActesTableViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 22/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class ActesTableViewController: UITableViewController, APIControllerProtocol {

    @IBOutlet var actesTableView: UITableView!
    var sortedActes = [String:[Actes]]()
    var lesActes = [Actes]()
    var patient = patients?()
    var api = APIController?()
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        self.clearsSelectionOnViewWillAppear = true
        api = APIController(delegate: self)
        let tb : TabBarViewController = self.tabBarController as! TabBarViewController
        patient = tb.patient!
        api!.sendRequest("SELECT * FROM actes WHERE idpatient = \(patient!.id) ORDER BY date")
        menuButton.setFAIcon(FAType.FASearch, iconSize: 24)
        quitButton.setFAIcon(FAType.FATimes, iconSize: 24)
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "\(title.title!) -  Dr \(preference.nomUser) - \(patient!.nom) \(patient!.prenom.capitalizedString)"

        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        ToolBox.setDefaultBackgroundMessage(self.tableView, elements: sortedActes.count, message: "Aucun acte n'a été appliqué à ce jour")
        return sortedActes.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
                let index = sortedActes.startIndex.advancedBy(section)
        return sortedActes[sortedActes.keys[index]]!.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("actesCell", forIndexPath: indexPath) as! ActesTableViewCell
        let index = sortedActes.startIndex.advancedBy(indexPath.section)
        let lActe = sortedActes[sortedActes.keys[index]]![indexPath.row]
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let ddate = dateFormat.dateFromString(lActe.date)
        dateFormat.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        cell.date.text = dateFormat.stringFromDate(ddate!)
        cell.cotation.text = "\(lActe.cotation)"
        cell.descriptif.text = lActe.descriptif
        cell.montant.text = "\(lActe.montant)"
        switch sortedActes.keys[index] {
        case "C":
            cell.icon.setFAIcon(FAType.FAEye, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0x0099CC)
            break
        case "BDC":
            cell.icon.setFAIcon(FAType.FAExclamationCircle, iconSize: 17)
            break
        case "Z":
            cell.icon.setFAIcon(FAType.FAPictureO, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xCCCCCC)
            break
        case "#REG":
            cell.icon.setFAIcon(FAType.FACalculator, iconSize: 17)
             cell.backgroundColor = ToolBox.UIColorFromRGB(0xA2B2AD)
            break
        case "#COM":
            cell.icon.setFAIcon(FAType.FAPencilSquareO, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xFEEE87)
            break
        case "#FSE":
            cell.icon.setFAIcon(FAType.FAFilePdfO, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0x2EB49C)
            break
        case "#DOC":
            cell.icon.setFAIcon(FAType.FAFileText, iconSize: 17)
            break
        case "#MDT":
            cell.icon.setFAIcon(FAType.FABarcode, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xF7CB31)
            break
        case "#TODO":
            cell.icon.setFAIcon(FAType.FACheckCircle, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xFC6674)
            break
        default :
            cell.icon.setFAIcon(FAType.FAEuro, iconSize: 17)
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView()
         let index = sortedActes.startIndex.advancedBy(section)
        var title = ""
        switch sortedActes.keys[index] {
        case "C":
            title = "Consultation"
            break
        case "BDC":
            title = "Bilan"
            break
        case "Z":
            title = "Radiographie"
            break
        case "#REG":
            title = "Réglement"
            break
        case "#COM":
            title = "A faire "
            break
        case "#FSE":
            title = "Création FSE"
            break
        case "#DOC":
            title = "Création document"
            break
        case "#MDT":
            title = "Traçabilité"
            break
        default :
            title = sortedActes.keys[index]
            break
        }
        view.titleLabel.text = title
        return view
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.lesActes = Actes.actesWithJSON(resultsArr)
            self.sortedActes = Actes.sortInDict(self.lesActes)
            self.actesTableView.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if let a = self.refreshControl {
                if a.refreshing {
                    a.endRefreshing()
                }
            }
        })
    }
    
    func handleRefresh(refreshControl:UIRefreshControl){
        api!.sendRequest("SELECT * FROM actes WHERE idpatient = \(patient!.id)")
        
    }
    
    func handleError(results: Int) {
        if results == 1{
            
            api!.sendRequest("SELECT * FROM actes WHERE idpatient = \(patient!.id)")
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }

}
