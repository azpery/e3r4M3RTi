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
    var document:Document?
    var modeleDocument:ModeleDocument?
    var leDocument:URL?
    var isNew:Bool = false
    var isCreate:Bool = false
    var patient:patients?
    var webView: WKWebView?
    var idDocument:Int?
    var mdp:String?
    @IBOutlet var containerView: UIView!
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
        
        self.view = self.webView!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        showNewMdp(SCLAlertView())
        if isNew {
//            let url1 = Bundle.main.url(forResource: "fill", withExtension: "html")!
//            leDocument = NSURL(string: "?idPrat=\(preference.idUser)&&idPatient=\(patient!.id)&&idDocument=\(self.idDocument!)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw, relativeTo: url1)! as URL
//            self.webView?.load(NSURLRequest(url: url1 as URL) as URLRequest)
            leDocument = URL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/formBuilder/fill.html?idPrat=\(preference.idUser)&&idPatient=\(patient!.id)&&idDocument=\(self.idDocument!)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)
        }
        if modeleDocument != nil {
            var scandale="http://\(preference.ipServer)/scripts/OremiaMobileHD/formBuilder/fill.html"
            scandale += "?db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw
            scandale += "&&idDocument=\(self.modeleDocument!.idDocument)"
            leDocument = URL(string : scandale)
            
        }
        if isCreate{
            leDocument = URL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/formBuilder/?v=1.1")
        }
        let day_url_request = URLRequest(url: leDocument!)

        webView!.load(day_url_request)
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Retour au menu", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FullScreenDocumentViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton;
    }
    
    func showNewMdp(_ alert:SCLAlertView){
        let txt = alert.addTextField("Mot de passe", isPlaceHolder: true)
        txt.keyboardType = UIKeyboardType.numberPad
        txt.isSecureTextEntry = true
        alert.appearance.showCloseButton = false
        alert.appearance.shouldAutoDismiss = false
        _ = alert.addButton("Valider"){
            if txt.text == ""{
                ToolBox.shakeIt(alert.baseView)
            }else{
                self.mdp = txt.text
                alert.hideView()
            }
        }
        _ = alert.addButton("Annuler"){
            self.navigationController?.popViewController(animated: true)
            alert.hideView()
        }
        _ = alert.showInfo("Saisir un mot de passe", subTitle: "Veuillez saisir un mot de passe.")
    }
    
    func back(_ sender: UIBarButtonItem) {
        let alert = SCLAlertView()
        let txt = alert.addTextField("Mot de passe", isPlaceHolder: true)
        txt.keyboardType = UIKeyboardType.numberPad
        txt.isSecureTextEntry = true
        alert.appearance.shouldAutoDismiss = false
        _ = alert.addButton("Valider"){
            if(self.mdp == txt.text){
                alert.hideView()
                self.navigationController?.popViewController(animated: true)
            }else{
                ToolBox.shakeIt(alert.baseView)
            }
        }
        _ = alert.showInfo("Saisir le mot de passe", subTitle: "Veuillez saisir le mot de passe.")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
