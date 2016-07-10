//
//  MenuTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 07/10/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    @IBOutlet weak var Accueil: UILabel!
    @IBOutlet weak var Patients: UILabel!
    @IBOutlet weak var Agenda: UILabel!
    @IBOutlet weak var logout: UILabel!
    @IBOutlet var devBlog: UILabel!
    @IBOutlet var assistance: UILabel!
   // @IBOutlet var modele: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        Accueil.setFAIcon(FAType.FAHome, iconSize: 22)
        Patients.setFAIcon(FAType.FAUser, iconSize: 22)
        Agenda.setFAIcon(FAType.FACalendar, iconSize: 22)
        //Reglage.setFAIcon(FAType.FACogs, iconSize: 22)
        logout.setFAIcon(FAType.FASignOut, iconSize: 22)
        devBlog.setFAIcon(FAType.FACode, iconSize: 21)
        assistance.setFAIcon(FAType.FAMedkit, iconSize: 22)
        //modele.setFAIcon(FAType.FAFile, iconSize: 21)


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
