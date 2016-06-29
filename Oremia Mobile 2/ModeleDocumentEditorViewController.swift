//
//  ModeleDocumentEditorViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 29/06/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit
import WebKit

class ModeleDocumentEditorViewController: UIViewController {
//    let urlrequest = NSURLRequest(URL: url,
//                                  cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData,
//                                  timeoutInterval: 10.0)
    @IBOutlet var webKit: UIWebView!
    var webView: WKWebView?
    override func loadView() {
        super.loadView()

        self.webView = WKWebView()
        
        self.view = self.webView!
    }
    func loadDocument(idtype:Int){
        if let url = NSURL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/formBuilder/?idDocument=\(idtype)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw){
            let urlrequest = NSURLRequest(URL: url)
            webView!.loadRequest(urlrequest)
        }
    }
    func loadNewType(){
        if let url = NSURL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/formBuilder/?db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw){
            let urlrequest = NSURLRequest(URL: url)
            
            webView!.loadRequest(urlrequest)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
