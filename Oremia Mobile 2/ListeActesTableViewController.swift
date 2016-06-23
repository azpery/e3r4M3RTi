//
//  ListeActesTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 27/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class ListeActesTableViewController: UITableViewController, APIControllerProtocol {
    var prestation:NSArray? = NSArray()
    lazy var api:APIController = APIController(delegate: self)
    var patient:patients?
    var actesController:ActesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.getIniFile("SELECT inifile FROM config WHERE titre ='ccam_favoris' AND idpraticien = \(preference.idUser) ")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //    @IBAction func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
    //        if gestureRecognizer.state == UIGestureRecognizerState.Began || gestureRecognizer.state == UIGestureRecognizerState.Changed {
    //            if gestureRecognizer.locationInView(self.view).x >= 0 && gestureRecognizer.locationInView(self.view).x < 50{
    //                let translation = gestureRecognizer.translationInView(self.view)
    //                // note: 'view' is optional and need to be unwrapped
    //                self.actesController?.rightPanel.frame =  CGRect(x: self.actesController!.rightPanel.frame.origin.x, y: self.actesController!.rightPanel.frame.origin.y, width: ((self.actesController?.rightPanel.frame.width)! + translation.x), height: (self.actesController?.rightPanel.frame.height)!)
    //            }
    //        }
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.prestation!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("prestationCell", forIndexPath: indexPath) as! ListeActesTableViewCell
        let pres = self.prestation![indexPath.row] as? Prestation
        var description = pres?.description ?? "Aucune description disponible"
        var index = 1
        if description.rangeOfString("+") != nil {
            
            index = description.startIndex.distanceTo((description.rangeOfString("+")?.startIndex)!)
        }
        if description.rangeOfString("-") != nil && index != 0 {
            
            index = description.startIndex.distanceTo((description.rangeOfString("-")?.startIndex)!)
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
            if let selectedCell = schema.selectedCell{
                
                self.addActeForCell(indexPath.row, selectedCell: selectedCell, schema: schema)
                addAllActesForCell(indexPath.row, selectedCell: selectedCell, schema: schema)
                
            }else {
                if let acte = actesController{
                    self.addActeForCell(indexPath.row)
                    addAllActesForCell(indexPath.row)
                }else {
                    if let vc = UIApplication.topViewController(){
                        let alert = UIAlertController(title: "Alerte", message: "La vue a mal été chargée, veuillez redémarrer l'application. \nSi le problème persiste, veuillez contacter le service technique.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        vc.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func addAllActesForCell(indexPath:Int, selectedCell:Int? = nil, schema:SchemaDentaireCollectionViewController? = nil){
        var i = indexPath + 1
        var index = 0
        
        while index == 0 {
            index = 1
            let pres = self.prestation![i] as? Prestation
            let description = pres?.description ?? "Aucune description disponible"
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
    
    
    func addActeForCell(indexPath:Int, var selectedCell:Int? = nil, schema:SchemaDentaireCollectionViewController? = nil){
        let index = indexPath
        let presta = prestation![index] as! Prestation
        let date = ToolBox.getFormatedDateWithSlash(NSDate())
        let cotation = presta.coefficient
        let descriptif = presta.description
        let montant = presta.montant
        let lettreCle = presta.lettreCle
        let image = presta.image
        if let acte = self.actesController?.saisieActesController{
            let numPresta = acte.prestation.count ?? 1
            if selectedCell == nil{
                selectedCell = 0
            }
            let newPresta = PrestationActe(nom: "Prestation_\(numPresta + 1)", coefficient: cotation, description: descriptif, lettreCle: lettreCle, coefficientEnft: 0, image: image, montant: montant, numDent: selectedCell!, dateActe: date)
            acte.prestation.append(newPresta)
            if image != "" && schema != nil && selectedCell != nil{
                schema!.addImageToSelectedCell(image)
                api.sendInsert("INSERT INTO chart(idpatient, date, localisation, layer) VALUES('\(self.patient!.id)', '\(ToolBox.getFormatedDate(NSDate()))', '\(selectedCell!)', '\(image)') ")
                
            }
            acte.tableView.reloadData()
            
        }
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    func didReceiveAPIResults(results: NSDictionary) {
        if let resultsArr: NSArray = results["results"] as? NSArray {
            dispatch_async(dispatch_get_main_queue(), {
                self.prestation = Prestation.prestationWithJSON(resultsArr)
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
