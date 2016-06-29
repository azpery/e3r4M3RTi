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
    
    
    var calendars: [EKCalendar]?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            self.calendars = self.eventManager.allCalendars
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        self.navigationItem.title = ""
        self.myCalendar = api.getPref("calendrier\(preference.idUser)")
        self.selectedCalendar = myCalendar
        
    }
    
    @IBAction func validerTapped(sender: AnyObject) {
        api.addPref("calendrier\(preference.idUser)", prefs: selectedCalendar)
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! PreferenceTableViewCell
        let heureDebut = Int(cell.heureDebut.text!)
        let heureFin = Int(cell.heureFin.text!)
        if(heureDebut != nil && heureFin != nil && cell.heureDebut.text! != "" && cell.heureFin.text! != "" && heureDebut! >= 0 && heureDebut! <= 11 && heureFin! > 0 && heureFin! <= 23){
            api.addPref("time\(preference.idUser)", prefs: [cell.heureDebut.text!, cell.heureFin.text!])
            
            self.dismissViewControllerAnimated(true, completion: ({
                self.caller?.iSaidReloadit()
            }))
        } else {
            ToolBox.shakeIt(self.view)
        }
    }
    
    @IBAction func annulerTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: ({
            
        }))
    }
    
    @IBAction func goToSettingsButtonTapped(sender: UIButton) {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count + 2
        }
        
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if(indexPath.row == 0){
            
            let preferenceCell = tableView.dequeueReusableCellWithIdentifier("PreferenceTableViewCell", forIndexPath: indexPath) as! PreferenceTableViewCell
            var heure = api.getPref("time\(preference.idUser)")
            if(heure.count == 0){
                heure = ["8","20"]
                api.addPref("time\(preference.idUser)", prefs: heure)
            }
            preferenceCell.heureDebut.text = heure[0]
            preferenceCell.heureFin.text = heure[1]
            
            cell = preferenceCell
        } else if indexPath.row != calendars!.count + 1{
            let calendarCell = tableView.dequeueReusableCellWithIdentifier("CalendrierPreferenceTableViewCell", forIndexPath: indexPath) as! CalendrierTableViewCell
            //        if indexPath.row == 0 {
            ////            cell.tickIcon.setFAIcon(FAType.FACheck, iconSize: 12)
            ////            cell.tickIcon.textColor = UIColor(CGColor: calendars![indexPath.row].CGColor)
            //        } else {
            
            calendarCell.circle.translatesAutoresizingMaskIntoConstraints = false
            calendarCell.circle.backgroundColor = UIColor.whiteColor()
            calendarCell.circle.layer.borderWidth = 2
            calendarCell.circle.layer.cornerRadius = calendarCell.circle.layer.frame.height / 2
            calendarCell.circle.layer.borderColor = calendars![indexPath.row - 1].CGColor
            calendarCell.tickIcon.text = ""
            //        }
            if let calendars = self.calendars {
                let calendarName = calendars[indexPath.row - 1].title
                calendarCell.calendarLabel.text = calendarName
                for k in myCalendar {
                    if k == calendarName {
                        calendarCell.tickIcon.setFAIcon(FAType.FACheck, iconSize: 12)
                        calendarCell.tickIcon.textColor = UIColor(CGColor: calendars[indexPath.row - 1].CGColor)
                    }
                }
            } else {
                calendarCell.calendarLabel.text = "Unknown Calendar Name"
            }
            cell = calendarCell
        }else {
            let calendarCell = tableView.dequeueReusableCellWithIdentifier("CalendrierDefautTableViewCell", forIndexPath: indexPath) as! CalendrierDefautTableViewCell
            calendarCell.calendrierLabel.text = eventManager.defaultCalendar!.title
            cell = calendarCell
        }
        
        return cell!
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 0 && indexPath.row != (calendars?.count)! + 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! CalendrierTableViewCell
            if cell.tickIcon.text == ""{
                cell.selected = false
                cell.tickIcon.setFAIcon(FAType.FACheck, iconSize: 12)
                cell.tickIcon.textColor = UIColor(CGColor: calendars![indexPath.row - 1].CGColor)
                selectedCalendar.append(calendars![indexPath.row - 1].title)
                cell.circle.layer.backgroundColor = calendars![indexPath.row - 1].CGColor

            } else {
                cell.selected = false
                cell.tickIcon.text = ""
                cell.circleView.backgroundColor = UIColor.whiteColor()
                var v = 0
                for k in selectedCalendar {
                    if k == calendars![indexPath.row - 1].title{
                        selectedCalendar.removeAtIndex(v)
                    }
                    v++
                }
                
            }
            
            eventManager.selectedCalendarIdentifier = calendars![indexPath.row - 1].title
        }
        
    }
    override func tableView(tableView: UITableView,heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
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
    func didReceiveAPIResults(results: NSDictionary) {
        
    }
    func handleError(results: Int) {
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(CalendarsTableViewController){
            let  destination = segue.destinationViewController as! CalendarsTableViewController
            destination.eventManager = eventManager
            destination.isDefault = true
            destination.defaultCaller = self
            
        }
    }
}
