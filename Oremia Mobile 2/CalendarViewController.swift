//
//  CalendarViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 27/05/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {


    @IBOutlet weak var calendarView: UIWebView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        let request = URL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/calendrier/")
        calendarView.loadRequest(URLRequest(url: request!))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
