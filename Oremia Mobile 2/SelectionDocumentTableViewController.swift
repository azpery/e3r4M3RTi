//
//  SelectionDocumentTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 09/05/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class SelectionDocumentTableViewController: UITableViewController {
    var callback:((index:Int)->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let call = self.callback {
            self.dismissViewControllerAnimated(true, completion: {call(index: indexPath.row)})
            
        }
    }
}
