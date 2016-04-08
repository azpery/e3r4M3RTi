//
//  HelpViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 06/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        let leDocument = NSURL(string : "https://go.crisp.im/chat/embed/?website_id=-K4sfPrIMy3qckUKycQD&no_delay")
        webView.loadRequest(NSURLRequest(URL: leDocument!))
        // Do any additional setup after loading the view.
        self.parentViewController!.preferredContentSize = CGSizeMake(200, 200);
        
        if self.revealViewController() != nil {
            menuButton.setFAIcon(FAType.FABars, iconSize: 24)
            closeButton.title = ""
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }else {
            menuButton.title = ""
            closeButton.setFAIcon(FAType.FAClose, iconSize: 24)
        }
    }

    @IBAction func closeIt(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//            webView.scrollView.contentOffset = CGPoint(x: 0, y: 0 - (self.navigationController?.navigationBar.frame.size.height)!)
//        }
//        
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//            webView.scrollView.scrollsToTop = true
//        }
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
