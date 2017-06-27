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
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.calendars = self.eventManager!.allCalendars
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        self.navigationItem.title = ""
        
    }
    
    
    
    @IBAction func goToSettingsButtonTapped(_ sender: UIButton) {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count
        }
        
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendrierTableViewCell", for: indexPath) as! CalendrierTableViewCell
//        if indexPath.row == 0 {
////            cell.tickIcon.setFAIcon(FAType.FACheck, iconSize: 12)
////            cell.tickIcon.textColor = UIColor(CGColor: calendars![indexPath.row].CGColor)
//        } else {
        cell.circle.translatesAutoresizingMaskIntoConstraints = false
        cell.circle.backgroundColor = UIColor.white
        cell.circle.layer.borderWidth = 2
        cell.circle.layer.cornerRadius = cell.circle.layer.frame.height / 2
        cell.circle.layer.borderColor = calendars![indexPath.row].cgColor
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CalendrierTableViewCell
        
        cell.tickIcon.setFAIcon(FAType.faCheck, iconSize: 12)
        cell.circle.layer.backgroundColor = calendars![indexPath.row].cgColor
        cell.tickIcon.textColor = UIColor(cgColor: calendars![indexPath.row].cgColor)
        if !isDefault{
            caller?.calendrier.text = calendars![indexPath.row].title
            eventManager!.selectedCalendarIdentifier = calendars![indexPath.row].title
        } else {
            eventManager!.setDefautCalendar(calendars![indexPath.row])
            defaultCaller!.tableView.reloadData()
        }
        
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CalendrierTableViewCell
        cell.tickIcon.text = ""
        cell.circleView.backgroundColor = UIColor.white
        
    }
    
}
