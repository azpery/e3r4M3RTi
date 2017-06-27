//
//  NoteActeTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 04/06/2017.
//  Copyright © 2017 Zumatec. All rights reserved.
//

import UIKit

class NoteActeTableViewController: UITableViewController {

    @IBOutlet var noteText: UITextView!
    
    var showDatePicker = false;
    var acte:PrestationActe?
    var callback:(String)->Bool = {defaut->Bool in return false}
    
    override func viewDidLoad() {
        redraw()
        super.viewDidLoad()
        
        if let a = acte {
            noteText.text = a.note
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150.0
        }
        return 43.0
        
    }
    
    func redraw(){
        
        var rect = self.navigationController!.view.superview?.bounds;
        
            rect!.size.width = 605;
            rect!.size.height = 205;
            self.navigationController!.view.superview!.bounds = rect!;
            self.navigationController!.preferredContentSize = CGSize(width: 605, height: 305);
            self.view.setNeedsLayout()
            self.view.setNeedsDisplay()
        
    }

    @IBAction func validerAction(_ sender: AnyObject) {
        _ = self.callback(self.noteText.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func annuler(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    

}
