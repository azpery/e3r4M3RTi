//
//  NotesTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 27/02/2017.
//  Copyright © 2017 Zumatec. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {
    @IBOutlet var dateText: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var localisationText: UITextField!
    @IBOutlet var noteText: UITextView!
    
    var showDatePicker = false;
    var acte = Actes()

    override func viewDidLoad() {
        super.viewDidLoad()
        redraw()
        let date = ToolBox.getDateFromString(acte.date) ?? Date()
        dateText.text = ToolBox.getFormatedDateWithSlash(date)
        datePicker.date = date
        localisationText.text = "\(acte.localisation)"
        noteText.text = acte.descriptif
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            showDatePicker = !showDatePicker
            tableView.beginUpdates()
            tableView.endUpdates()
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && !showDatePicker{
            return 0.0
        } else if indexPath.row == 1 && showDatePicker{
            return 100.0
        }else if indexPath.row == 3 {
            return 150.0
        }
        return 43.0
        
    }
    
    func redraw(){
        
        var rect = self.navigationController!.view.superview!.bounds;
        rect.size.width = 605;
        rect.size.height = 305;
        self.navigationController!.view.superview!.bounds = rect;
        self.navigationController!.preferredContentSize = CGSize(width: 605, height: 305);
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
    }
    
    @IBAction func validerAction(_ sender: AnyObject) {
        let api = APIController()
        var query = "UPDATE Actes SET date='\(ToolBox.getFormatedDate(datePicker.date))' ,localisation='\(localisationText.text ?? "")' , description='\(noteText.text.replace("'", withString: "''"))' WHERE id=\(acte.id)"
        if acte.id == 0 {
            query = "INSERT INTO actes(\"idpatient\", \"idpraticien\", \"iddocument\", \"date\", \"lettre\", \"description\") VALUES('\(acte.idPatient)', '\(preference.idUser)', '0', '\(ToolBox.getFormatedDate(datePicker.date))', '\(acte.lettre)', '\(noteText.text.replace("'", withString: "''"))')"
        }
        api.sendRequest(query, success: {defaut->Bool in
            
            return true})
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func annulerAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func dateChanged(_ sender: UIDatePicker) {
        dateText.text = ToolBox.getFormatedDateWithSlash(sender.date)
    }
}
