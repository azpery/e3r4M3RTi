//
//  DevBlogViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 28/01/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class DevBlogViewController: UIViewController {

    @IBOutlet var barButton: UIBarButtonItem!
    @IBOutlet var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let leDocument = NSURL(string : "http://rdelaporte.alwaysdata.net/OM/")
        webView.loadRequest(NSURLRequest(URL: leDocument!))
        // Do any additional setup after loading the view.
        barButton.setFAIcon(FAType.FABars, iconSize: 24)
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            barButton.target = self.revealViewController()
            barButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
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
