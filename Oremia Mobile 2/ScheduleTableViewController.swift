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
        
        self.menuButton.setFAIcon(FAType.faBars, iconSize: 24)
        
        self.tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.separatorStyle = .none
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        DispatchQueue.main.async(execute: {
            LoadingOverlay.shared.showOverlay(self.view)
        })
        DispatchQueue.main.async {
            self.uniqueEventsArray = self.eventManager.getEventsOfSelectedCalendar(self.tableView)
            self.events = self.eventManager.sortEventsByDay(self.uniqueEventsArray) as! [NSDictionary]
            DispatchQueue.main.async {
                self.tableView.reloadData()
                LoadingOverlay.shared.hideOverlayView()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {


    }
	
	override func numberOfSections(in tableView: UITableView) -> Int {
        return self.events.count
	}

    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
		let day = events[section]
		let items = day["lesDates"] as! NSArray
		return items.count

    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
		let day = events[indexPath.section]
		let items = day["lesDates"] as! NSArray
		let item = items[indexPath.row] as! EKEvent
		let dateFormat = DateFormatter()
        dateFormat.timeStyle = .short
		cell.titleLabel.text = item.title
		cell.timeLabel.text = "de "+dateFormat.string(from: item.startDate)+" à "+dateFormat.string(from: item.endDate)
		print( dateFormat.string(from: item.startDate))
			cell.minor = false
        cell.circleView.layer.borderColor = item.calendar.cgColor

		return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let day = events[section]
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .full
		return dateFormat.string(from: day["date"] as! Date)
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let day = events[section] 
		let view = SectionHeaderView()
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .full
		view.titleLabel.text = (dateFormat.string(from: (day["date"] as! NSDate) as Date) ).uppercased()
		return view
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 45
	}
}
