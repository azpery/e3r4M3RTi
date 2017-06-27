//
//  TypeRDVTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class TypeRDVTableViewController: UITableViewController, APIControllerProtocol{
    lazy var api:APIController = APIController(delegate: self)
    var eventManager:EventManager?
    var lesTypeRDV:NSArray?
    var label:UILabel?
    var caller:NewEventTableViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        api.sendRequest("select * from calendar_events_modeles")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lesTypeRDV?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeRDV", for: indexPath) as! TypeRDVTableViewCell
        let lesTypeRDVDict = lesTypeRDV![indexPath.row] as! NSDictionary
        cell.typeRDVLabel.text = lesTypeRDVDict["description"] as? String ?? "Bizarre, erreur"
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lesTypeRDVDict = lesTypeRDV![indexPath.row] as? NSDictionary
        eventManager!.internalEvent.modele = lesTypeRDVDict?["id"] as? Int ?? 0
        eventManager!.internalEvent.descriptionModele = lesTypeRDVDict?["description"] as? String ?? "Bizarre, erreur"
        label?.text = lesTypeRDVDict?["description"] as? String ?? "Bizarre, erreur"
        caller?.majDuree(lesTypeRDVDict?["duree"] as! Double)
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popToRootViewController(animated: true)
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
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        self.lesTypeRDV = resultsArr
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    func handleError(_ results: Int) {
        if results == 1{
            api.sendRequest("select * from calendar_events_modeles")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
}
