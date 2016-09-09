//
//  TypeDocumentTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 28/07/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class TypeDocumentTableViewController: UITableViewController {
    
    var patient:patients?
    var success:((sPrat:String,sPatient:String, selectedRow:Int)->Void)?
    var selectedRow = 1

    @IBOutlet var cancelButton: UIBarButtonItem!
    override func viewDidLoad() {
        var rect = self.navigationController!.view.superview!.bounds;
        rect.size.width = 605;
        rect.size.height = 350;
        self.navigationController!.view.superview!.bounds = rect;
        self.navigationController!.preferredContentSize = CGSizeMake(605, 350);
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        cancelButton.setFAIcon(FAType.FAClose, iconSize: 22)
        super.viewDidLoad()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        self.performSegueWithIdentifier("showSignatureView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationView:SignatureViewController = segue.destinationViewController as! SignatureViewController
        destinationView.patient = self.patient
        destinationView.success = self.success
        destinationView.selectedRow = self.selectedRow
    }
 
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

}
