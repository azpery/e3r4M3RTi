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
    var success:((_ sPrat:String,_ sPatient:String, _ selectedRow:Int)->Void)?
    var selectedRow = 1

    @IBOutlet var cancelButton: UIBarButtonItem!
    override func viewDidLoad() {
        var rect = self.navigationController!.view.superview!.bounds;
        rect.size.width = 605;
        rect.size.height = 350;
        self.navigationController!.view.superview!.bounds = rect;
        self.navigationController!.preferredContentSize = CGSize(width: 605, height: 350);
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        cancelButton.setFAIcon(FAType.faClose, iconSize: 22)
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        self.performSegue(withIdentifier: "showSignatureView", sender: self)
//        let VC1 = self.storyboard!.instantiateViewControllerWithIdentifier("SignatureViewController") as! SignatureViewController
//        self.navigationController!.pushViewController(VC1, animated: true)
//        VC1.selectedRow = selectedRow
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationView:SignatureViewController = segue.destination as! SignatureViewController
        destinationView.patient = self.patient
        destinationView.success = self.success
        destinationView.selectedRow = self.selectedRow
    }
 
    @IBAction func close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
    }

}
