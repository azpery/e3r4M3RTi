//
//  CalendarsTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 08/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit
import EventKit

class CalendarsTableViewController: UITableViewController {

    
    let eventStore = EKEventStore()
    var eventManager:EventManager?
    var caller:NewEventTableViewController?
    var defaultCaller:CalendarPreferenceTableViewController?
    var isDefault:Bool = false

    
    var calendars: [EKCalendar]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            self.calendars = self.eventManager!.allCalendars
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        self.navigationItem.title = ""
        
    }
    
    
    
    @IBAction func goToSettingsButtonTapped(sender: UIButton) {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count
        }
        
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CalendrierTableViewCell", forIndexPath: indexPath) as! CalendrierTableViewCell
//        if indexPath.row == 0 {
////            cell.tickIcon.setFAIcon(FAType.FACheck, iconSize: 12)
////            cell.tickIcon.textColor = UIColor(CGColor: calendars![indexPath.row].CGColor)
//        } else {
        cell.circle.translatesAutoresizingMaskIntoConstraints = false
        cell.circle.backgroundColor = UIColor.whiteColor()
        cell.circle.layer.borderWidth = 2
        cell.circle.layer.cornerRadius = cell.circle.layer.frame.height / 2
        cell.circle.layer.borderColor = calendars![indexPath.row].CGColor
             cell.tickIcon.text = ""
//        }
        if let calendars = self.calendars {
            let calendarName = calendars[indexPath.row].title
            cell.calendarLabel.text = calendarName
        } else {
            cell.calendarLabel.text = "Unknown Calendar Name"
        }
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CalendrierTableViewCell
        
        cell.tickIcon.setFAIcon(FAType.FACheck, iconSize: 12)
        cell.circle.layer.backgroundColor = calendars![indexPath.row].CGColor
        cell.tickIcon.textColor = UIColor(CGColor: calendars![indexPath.row].CGColor)
        if !isDefault{
            caller?.calendrier.text = calendars![indexPath.row].title
            eventManager!.selectedCalendarIdentifier = calendars![indexPath.row].title
        } else {
            eventManager!.setDefautCalendar(calendars![indexPath.row])
            defaultCaller!.tableView.reloadData()
        }
        
    }
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CalendrierTableViewCell
        cell.tickIcon.text = ""
        cell.circleView.backgroundColor = UIColor.whiteColor()
        
    }
    
}
