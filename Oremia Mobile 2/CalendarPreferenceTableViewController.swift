//
//  CalendarPreferenceTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 28/01/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit
import EventKit


class CalendarPreferenceTableViewController: UITableViewController, APIControllerProtocol {
    let eventStore = EKEventStore()
    var eventManager = EventManager()
    var selectedCalendar = [String]()
    var caller:MSCalendarViewController?
    lazy var api:APIController = APIController(delegate: self)
    var myCalendar:[String] = []
    var calDavName:String = ""
    
    
    
    var calendars: [EKCalendar]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let alert = SCLAlertView()
        alert.showCloseButton = false
        alert.addButton("J'ai compris"){
            
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.async {
            self.api.sendRequest("select inifile from config where titre = 'calendarNamesForUsers'", success: {results->Bool in
                do{
                    let res = results["results"] as! NSArray
                    if(res.count > 0){
                        let value = res[0] as! NSDictionary
                        let calName = value["inifile"] as! NSString
                        let jsonResult = try JSONSerialization.jsonObject(with: calName.data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        if let calendarName = jsonResult!["\(preference.idUser)"] as? String {
                            self.calDavName = calendarName
                            self.api.addPref("calendrierpardefaut\(preference.idUser)", prefs: [calendarName])
                            self.api.addPref("calendrier\(preference.idUser)", prefs: [calendarName])
                            self.eventManager.loadCalendars()
                            
                        }else{
                            DispatchQueue.main.async(execute: {
                                alert.showInfo("Calendrier introuvable", subTitle: "Le calendrier de l'agenda 2 n'a pas été configuré pour ce praticien. \n Veuillez sélectionner un calendrier dans les préférences du calendrier dans Oremia pour le Dr \(preference.nomUser).")
                            })
                        }
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                    return true
                }catch{
                    return true
                }
                
            })
            self.calendars = self.eventManager.allCalendars
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        self.navigationItem.title = "Configuration"
        self.myCalendar = api.getPref("calendrier\(preference.idUser)")
        self.selectedCalendar = myCalendar
        
    }
    
    @IBAction func validerTapped(_ sender: AnyObject) {
        api.addPref("calendrier\(preference.idUser)", prefs: selectedCalendar)
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PreferenceTableViewCell
        let heureDebut = Int(cell.heureDebut.text!)
        let heureFin = Int(cell.heureFin.text!)
        if(heureDebut != nil && heureFin != nil && cell.heureDebut.text! != "" && cell.heureFin.text! != "" && heureDebut! >= 0 && heureDebut! <= 11 && heureFin! > 0 && heureFin! <= 23){
            api.addPref("time\(preference.idUser)", prefs: [cell.heureDebut.text!, cell.heureFin.text!])
            
            self.dismiss(animated: true, completion: ({
                self.caller?.iSaidReloadit()
            }))
        } else {
            ToolBox.shakeIt(self.view)
        }
    }
    
    @IBAction func annulerTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: ({
            
        }))
    }
    
    @IBAction func goToSettingsButtonTapped(_ sender: UIButton) {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count + 2
        }
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if(indexPath.row == 0){
            
            let preferenceCell = tableView.dequeueReusableCell(withIdentifier: "PreferenceTableViewCell", for: indexPath) as! PreferenceTableViewCell
            var heure = api.getPref("time\(preference.idUser)")
            if(heure.count == 0){
                heure = ["8","20"]
                api.addPref("time\(preference.idUser)", prefs: heure)
            }
            preferenceCell.heureDebut.text = heure[0]
            preferenceCell.heureFin.text = heure[1]
            
            cell = preferenceCell
        } else if indexPath.row != calendars!.count + 1{
            let calendarCell = tableView.dequeueReusableCell(withIdentifier: "CalendrierPreferenceTableViewCell", for: indexPath) as! CalendrierTableViewCell
            //        if indexPath.row == 0 {
            ////            cell.tickIcon.setFAIcon(FAType.FACheck, iconSize: 12)
            ////            cell.tickIcon.textColor = UIColor(CGColor: calendars![indexPath.row].CGColor)
            //        } else {
            
            calendarCell.circle.translatesAutoresizingMaskIntoConstraints = false
            calendarCell.circle.backgroundColor = UIColor.white
            calendarCell.circle.layer.borderWidth = 2
            calendarCell.circle.layer.cornerRadius = calendarCell.circle.layer.frame.height / 2
            calendarCell.circle.layer.borderColor = calendars![indexPath.row - 1].cgColor
            calendarCell.tickIcon.text = ""
            //        }
            if let calendars = self.calendars {
                let calendarName = calendars[indexPath.row - 1].title
                calendarCell.calendarLabel.text = calendarName == self.calDavName ? "\(calendarName) - Oremia" : calendarName
                for k in myCalendar {
                    if k == calendarName {
                        calendarCell.tickIcon.setFAIcon(FAType.faCheck, iconSize: 12)
                        calendarCell.tickIcon.textColor = UIColor(cgColor: calendars[indexPath.row - 1].cgColor)
                    }
                }
            } else {
                calendarCell.calendarLabel.text = "Unknown Calendar Name"
            }
            cell = calendarCell
        }else {
            let calendarCell = tableView.dequeueReusableCell(withIdentifier: "CalendrierDefautTableViewCell", for: indexPath) as! CalendrierDefautTableViewCell
            calendarCell.calendrierLabel.text = eventManager.defaultCalendar!.title
            cell = calendarCell
        }
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 && indexPath.row != (calendars?.count)! + 1 {
            let cell = tableView.cellForRow(at: indexPath) as! CalendrierTableViewCell
            if cell.tickIcon.text == ""{
                cell.isSelected = false
                cell.tickIcon.setFAIcon(FAType.faCheck, iconSize: 12)
                cell.tickIcon.textColor = UIColor(cgColor: calendars![indexPath.row - 1].cgColor)
                selectedCalendar.append(calendars![indexPath.row - 1].title)
                cell.circle.layer.backgroundColor = calendars![indexPath.row - 1].cgColor

            } else {
                cell.isSelected = false
                cell.tickIcon.text = ""
                cell.circleView.backgroundColor = UIColor.white
                var v = 0
                for k in selectedCalendar {
                    if k == calendars![indexPath.row - 1].title{
                        selectedCalendar.remove(at: v)
                    }
                    v += 1
                }
                
            }
            
            eventManager.selectedCalendarIdentifier = calendars![indexPath.row - 1].title
        }
        
    }
    override func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0{
            return 84
        }
        if indexPath.row == (calendars?.count)! + 1{
            return 82
        }
        return 44
    }
    //    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    //        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CalendrierTableViewCell
    //        cell.tickIcon.text = ""
    //
    //    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        
    }
    func handleError(_ results: Int) {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: CalendarsTableViewController.self){
            let  destination = segue.destination as! CalendarsTableViewController
            destination.eventManager = eventManager
            destination.isDefault = true
            destination.defaultCaller = self
            
        }
    }
}
