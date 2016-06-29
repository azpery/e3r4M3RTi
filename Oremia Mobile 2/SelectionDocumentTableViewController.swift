//
//  SelectionDocumentTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 09/05/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class SelectionDocumentTableViewController: UITableViewController, APIControllerProtocol {
    var callback:((index:Int)->Void)?
    lazy var api : APIController = APIController(delegate: self)
    var typeDocuments:[TypeModeleDocument] = []
    var detailview:ModeleDocumentEditorViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        api.sendRequest("SELECT idtype, nomtype FROM typedocument;")
    }
    
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.typeDocuments.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectionModeleCell", forIndexPath: indexPath) as! ModeleDocumentEditorTableViewCell
        cell.nomModeleLabel.text = self.typeDocuments[indexPath.row].nomType ?? "Nom du type de modèle non renseigné"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let call = self.callback {
            self.dismissViewControllerAnimated(true, completion: {call(index: self.typeDocuments[indexPath.row].idType)})
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.typeDocuments = TypeModeleDocument.typeDocumentWithJSON(resultsArr)
            self.tableView.reloadData()
        })
    }
    func handleError(results: Int) {
        self.tableView.reloadData()
        
    }
}
