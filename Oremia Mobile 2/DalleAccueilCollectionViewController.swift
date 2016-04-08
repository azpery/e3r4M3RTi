//
//  DalleAccueilCollectionViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 16/10/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class DalleAccueilCollectionViewController: UITableViewController {

    @IBOutlet var assistance: UIButton!
    @IBOutlet weak var patient: UIButton!
    @IBOutlet weak var agenda: UIButton!
    @IBOutlet weak var reglage: UIButton!
    @IBOutlet weak var deco: UIButton!
    @IBOutlet var devBlog: UIButton!
    var homeView : HomeViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patient.setFAIcon(FAType.FAUser, forState: .Normal)
        agenda.setFAIcon(FAType.FACalendar, forState: .Normal)
//        reglage.setFAIcon(FAType.FACogs, forState: .Normal)
        deco.setFAIcon(FAType.FASignOut, forState: .Normal)
        devBlog.setFAIcon(FAType.FACode, forState: .Normal)
        assistance.setFAIcon(FAType.FAMedkit, forState: .Normal)

    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
    }

    @IBAction func buttonPatientpressed(sender: AnyObject) {
        homeView!.performSegueWithIdentifier("showPatient", sender:homeView!)
    }

    @IBAction func buttonCalendarPressed(sender: AnyObject) {
        let  calendarViewController  = MSCalendarViewController.init()
        self.showViewController(calendarViewController, sender: homeView!)

    }
    @IBAction func buttonReglagePressed(sender: AnyObject) {
        homeView!.performSegueWithIdentifier("showReglage", sender:homeView!)
    }

    @IBAction func buttonDecoPressed(sender: AnyObject) {
        homeView!.performSegueWithIdentifier("showSelect", sender:homeView!)
    }
    @IBAction func buttonDevPressed(sender: AnyObject) {
        homeView!.performSegueWithIdentifier("showDevBlog", sender:homeView!)
    }
    @IBAction func buttonAssistancePressed(sender: AnyObject) {
        homeView!.performSegueWithIdentifier("showAssistance", sender:homeView!)
    }
}
