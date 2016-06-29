//
//  FullScreenDocumentViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 21/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import WebKit


class FullScreenDocumentViewController: UIViewController {
    var document = Document?()
    var modeleDocument = ModeleDocument?()
    var leDocument:NSURL?
    var isNew:Bool = false
    var isCreate:Bool = false
    var patient:patients?
    var webView: WKWebView?
    var idDocument:Int?
    @IBOutlet var containerView: UIView!
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
        
        self.view = self.webView!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
            if isNew {
            leDocument = NSURL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/formBuilder/fill.html?idPrat=\(preference.idUser)&&idPatient=\(patient!.id)&&idDocument=\(self.idDocument!)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)
            print(leDocument)
        }
        if modeleDocument != nil {
            var scandale="http://\(preference.ipServer)/scripts/OremiaMobileHD/formBuilder/fill.html"
            scandale += "?db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw
            scandale += "&&idDocument=\(self.modeleDocument!.idDocument)"
            leDocument = NSURL(string : scandale)
        }
        if isCreate{
            leDocument = NSURL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/formBuilder/?v=1.1")
        }
        let day_url_request = NSURLRequest(URL: leDocument!)

        webView!.loadRequest(day_url_request)
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
