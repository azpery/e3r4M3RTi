//
//  ScheduleTableViewController.swift
//  Valio
//
//  Created by Sam Soffes on 6/5/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//
import Foundation
import UIKit
import EventKit

class ScheduleTableViewController: UITableViewController {
    var eventManager = EventManager()
    var uniqueEventsArray: [EKEvent] = []
    var events:[NSDictionary] = []
    
    @IBOutlet weak var menuButton: UIBarButtonItem!



    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuButton.setFAIcon(FAType.FABars, iconSize: 24)
        
        self.tableView.registerClass(ItemTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorStyle = .None
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        dispatch_async(dispatch_get_main_queue(), {
            LoadingOverlay.shared.showOverlay(self.view)
        })
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)) {
            self.uniqueEventsArray = self.eventManager.getEventsOfSelectedCalendar(self.tableView)
            self.events = self.eventManager.sortEventsByDay(self.uniqueEventsArray) as! [NSDictionary]
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                LoadingOverlay.shared.hideOverlayView()
            }
        }
    }
    override func viewDidAppear(animated: Bool) {


    }
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.events.count
	}

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		let day = events[section]
		let items = day["lesDates"] as! NSArray
		return items.count

    }

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ItemTableViewCell
		let day = events[indexPath.section]
		let items = day["lesDates"] as! NSArray
		let item = items[indexPath.row] as! EKEvent
		let dateFormat = NSDateFormatter()
        dateFormat.timeStyle = .ShortStyle
		cell.titleLabel.text = item.title
		cell.timeLabel.text = "de "+dateFormat.stringFromDate(item.startDate)+" à "+dateFormat.stringFromDate(item.endDate)
		print( dateFormat.stringFromDate(item.startDate))
			cell.minor = false
        cell.circleView.layer.borderColor = item.calendar.CGColor

		return cell
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let day = events[section]
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .FullStyle
		return dateFormat.stringFromDate(day["date"] as! NSDate)
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let day = events[section] 
		let view = SectionHeaderView()
        let dateFormat = NSDateFormatter()
        dateFormat.dateStyle = .FullStyle
		view.titleLabel.text = (dateFormat.stringFromDate(day["date"] as! NSDate) ).uppercaseString
		return view
	}
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 45
	}
}
