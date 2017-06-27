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
        
        patient.setFAIcon(FAType.faUser, forState: UIControlState())
        agenda.setFAIcon(FAType.faCalendar, forState: UIControlState())
//        reglage.setFAIcon(FAType.FACogs, forState: .Normal)
        deco.setFAIcon(FAType.faSignOut, forState: UIControlState())
        devBlog.setFAIcon(FAType.faCode, forState: UIControlState())
        assistance.setFAIcon(FAType.faMedkit, forState: UIControlState())

    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
    }

    @IBAction func buttonPatientpressed(_ sender: AnyObject) {
        homeView!.performSegue(withIdentifier: "showPatient", sender:homeView!)
    }

    @IBAction func buttonCalendarPressed(_ sender: AnyObject) {
        let  calendarViewController  = MSCalendarViewController.init()
        self.show(calendarViewController, sender: homeView!)

    }
    @IBAction func buttonReglagePressed(_ sender: AnyObject) {
        homeView!.performSegue(withIdentifier: "showReglage", sender:homeView!)
    }

    @IBAction func buttonDecoPressed(_ sender: AnyObject) {
        homeView!.performSegue(withIdentifier: "showSelect", sender:homeView!)
    }
    @IBAction func buttonDevPressed(_ sender: AnyObject) {
        homeView!.performSegue(withIdentifier: "showDevBlog", sender:homeView!)
    }
    @IBAction func buttonAssistancePressed(_ sender: AnyObject) {
        homeView!.performSegue(withIdentifier: "showAssistance", sender:homeView!)
    }
}
