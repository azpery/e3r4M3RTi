//
//  selectPratViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 07/05/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class selectPratViewController: UIViewController, UIScrollViewDelegate, APIControllerProtocol{
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnConnexion: UIButton!
    @IBOutlet weak var password: UITextField!
    var pageViews: [UIButton?] = []
    var api:APIController?
    var praticiens = [Praticien]()
    var mdp:String?
    var selectedPrat:Praticien?
    var timer = Timer()
    @IBOutlet var logo: UIImageView!
    let autoDetect = AutoDetect()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        self.displayLoad()
        btnConnexion.isHidden = true
        let test = HelpButton()
        test.showButton(self)
        UIApplication.shared.statusBarStyle = .default
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.black
        
        api!.pingServer()
        timer.invalidate() // just in case this button is tapped multiple times
        logo.layer.minificationFilter = kCAFilterTrilinear
        // start the timer
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        //api!.sendRequest("select id,nom,prenom from praticiens")
        btnConnexion.addTarget(self, action: #selector(selectPratViewController.clicked), for: UIControlEvents.touchUpInside)
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UINavigationBar.appearance().barTintColor = ToolBox.UIColorFromRGB(0x34495E)
        UINavigationBar.appearance().tintColor = UIColor.white
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToMainMenu(_ segue: UIStoryboardSegue) {
        displayLoad()
        //        api!.selectpraticien()
        api?.pingServer()
        
        //api!.sendRequest("select id,nom,prenom from praticiens")
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        return true
    }
    func displayLoad(){
        self.praticiens.removeAll(keepingCapacity: false)
        self.praticiens.append(Praticien(id: 0, nom:"Recherche du Serveur...", prenom: "", licence: 0))
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.initScroll()
        self.loadVisiblePages()
        self.scrollView.reloadInputViews()
        preference.ipServer = api!.readServerAdress()
        btnConnexion.isHidden = true
        self.password.isHidden = true
    }
    func clicked(){
        mdp="zuma"
        if(!password.text!.isEmpty){
            mdp = password.text
        }
        selectedPrat=praticiens[pageControl.currentPage]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        connexionString.login = "zm\(self.selectedPrat!.id)"
        connexionString.pw = self.mdp!
        self.api!.setConnexion()
        //api!.sendRequest("select COUNT(*) as correct from praticiens")
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Load the pages that are now on screen
        if(!UIApplication.shared.isNetworkActivityIndicatorVisible){
            loadVisiblePages()
        }
    }
    func loadPage(_ page: Int) {
        if page < 0 || page >= self.praticiens.count {
            return
        }
        var frame = scrollView.bounds
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0
        let newPageView = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        newPageView.backgroundColor=UIColor.orange
        if (self.praticiens[0].id != 0) {
            newPageView.setTitle("Dr "+self.praticiens[page].prenom+" "+self.praticiens[page].nom, for: UIControlState())
        } else {
            newPageView.setTitle(self.praticiens[page].nom, for: UIControlState())
        }
        newPageView.contentMode = .scaleAspectFit
        newPageView.frame = frame
        scrollView.addSubview(newPageView)
        
        pageViews[page] = newPageView
    }
    func purgePage(_ page: Int) {
        if page < 0 || page >= self.praticiens.count{
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    func loadVisiblePages() {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        pageControl.currentPage = page
        var firstPage = 0
        if page > 0  {
            firstPage = page - 1
        }
        
        let lastPage = page + 1
        
        // Purge anything before the first page
        for index in (0 ..< firstPage) {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for index in (lastPage ..< self.praticiens.count) {
            purgePage(index)
        }
    }
    func initScroll(){
        pageControl.currentPage = 0
        pageControl.numberOfPages = self.praticiens.count
        for _ in 0..<self.praticiens.count {
            pageViews.append(nil)
        }
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(self.praticiens.count),
                                        height: pagesScrollViewSize.height)
    }
    
    func showActivityLoader(){
        self.timer.invalidate()
        _ = SwiftSpinner.show("Mise à jour des fichiers...")
        _ = SwiftSpinner.showWithDelay(15.0, title: "Nous mettons à jour les fichiers sur le poste serveur.")
    }
    func pingResult(_ success:NSNumber){
        if(success.boolValue){
            api!.checkFileUpdate()
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(selectPratViewController.showActivityLoader), userInfo: nil, repeats: true)
        }else {
            self.handleError(1)
        }
    }
    
    func didReceiveAPIResults(_ results: NSDictionary) {
        self.timer.invalidate()
        if let resultsArr: NSArray = results["results"] as? NSArray {
            var type = 1
            var nb:Int?
            for value in resultsArr{
                if (value as AnyObject).object(forKey: "correct") !=  nil{
                    type = 0
                    let v = value as! NSDictionary
                    nb = v["correct"] as? Int
                }
                if (value as AnyObject).object(forKey: "connexionBegin") !=  nil{
                    preference.idUser = self.selectedPrat!.id
                    preference.nomUser = self.selectedPrat!.nom
                    preference.prenomUser = self.selectedPrat!.prenom
                    preference.licence = self.selectedPrat!.licence
                    preference.password = self.mdp!
                    connexionString.login = "zm\(self.selectedPrat!.id)"
                    connexionString.pw=self.mdp!
                    api?.checkLicence({result->Void in
                        DispatchQueue.main.async(execute: {
                            if result{
                                
                                self.performSegue(withIdentifier: "connectionGranted", sender:self)
                                
                            }else{
                                let alert = SCLAlertView()
                                _ = alert.showError("Licence invalide", subTitle: "Vous n'avez pas la licence requise pour utiliser cette application.\n Veuillez contacter le service commercial de Zumatec.", closeButtonTitle:"Fermer")
                                self.api!.selectpraticien()
                            }
                        })
                    })
                }
                let u = value as? NSDictionary
                if (value as AnyObject).object(forKey: "error") !=  nil && u?["error"] as? Int == 7{
                    type = 2
                }
            }
            if type == 0{
                if nb > 0{
                    DispatchQueue.main.async(execute: {
                        preference.idUser = self.selectedPrat!.id
                        preference.nomUser = self.selectedPrat!.nom
                        preference.prenomUser = self.selectedPrat!.prenom
                        preference.password = self.mdp!
                        connexionString.login = "zm\(self.selectedPrat!.id)"
                        connexionString.pw=self.mdp!
                        self.api!.setConnexion()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                }
            }else if type == 2{
                DispatchQueue.main.async(execute: {
                    let alert = SCLAlertView()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    _ = alert.showError("Mot de passe incorrect", subTitle: "Mot de passe incorrect ou inexistant, veuillez resaisir vos identifiants", closeButtonTitle:"Fermer")
                })
                
            } else {
                DispatchQueue.main.async(execute: {
                    self.praticiens = Praticien.praticienWithJSON(resultsArr)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.initScroll()
                    self.loadVisiblePages()
                    self.btnConnexion.isHidden = false
                    self.password.isHidden = false
                })
            }
        } else if let resultsArr: String = results["results"] as? String {
            DispatchQueue.main.async(execute: {
                self.timer.invalidate()
                if resultsArr == "AJ" {
                    SwiftSpinner.hide()
                    self.api!.selectpraticien()
                }else if resultsArr == "3"{
                    SwiftSpinner.hide()
                    let alert = SCLAlertView()
                    alert.showCloseButton = false
                    _ = alert.addButton("Lancer la démonstration"){
                        preference.ipServer = "109.10.173.81"
                        self.api!.selectpraticien()
                    }
                    _ = alert.addButton("Besoin d'aide?") {
                        let help = HelpButton()
                        help.caller = self
                        help.triggerPopOver()
                    }
                    _ = alert.showError("Erreur serveur", subTitle: "Veuillez contacter le service technique. \nLe serveur n'a pas les droits suffisant pour mettre à jour les fichiers.\nVeuillez nous excuser mais il est nécessaire d'effectuer une opération sur votre poste serveur.")
                    
                }else{
                    self.timer.invalidate()
                    SwiftSpinner.show("Mise à jour effectuée", animated: false).addTapHandler({
                        self.api?.selectpraticien()
                        SwiftSpinner.hide()
                        }, subtitle: "Taper n'importe où pour continuer")
                }
            })
        }
    }
    func handleError(_ results: Int) {
        DispatchQueue.main.async(execute: {
            self.timer.invalidate()
            switch results {
            case 1 :
                
                //            SCLAlertView().showError("Serveur introuvable", subTitle: "Veuillez rentrer une adresse ip de serveur correct", closeButtonTitle:"Fermer", duration: 800)
                
                let alert = SCLAlertView()
                let txt = alert.addTextField(preference.ipServer)
                alert.showCloseButton = false
                _ = alert.addButton("Valider") {
                    self.displayLoad()
                    preference.ipServer=txt.text!
                    self.api!.updateServerAdress(txt.text!)
                    self.api!.pingServer()
                    //                    self.api!.selectpraticien()
                }
                _ = alert.addButton("Trouver mon serveur"){
                    self.praticiens.removeAll(keepingCapacity: false)
                    self.praticiens.append(Praticien(id: 0, nom:"Recherche du serveur", prenom: "", licence: 0))
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    DispatchQueue.main.async(execute: {
                        _ = SwiftSpinner.show("Recherche du serveur sur votre réseau...")
                    })
                    self.autoDetect.getServerIpAdress({ip->Void in
                        self.praticiens.removeAll(keepingCapacity: false)
                        self.praticiens.append(Praticien(id: 0, nom:"Serveur trouvé, chargement...", prenom: "", licence: 0))
                        preference.ipServer = ip
                        self.api!.checkFileUpdate()
                        SwiftSpinner.hide()
                        },
                        failure: {defaut->Void in
                            
                            SwiftSpinner.hide()
                            self.praticiens.removeAll(keepingCapacity: false)
                            self.praticiens.append(Praticien(id: 0, nom:"Serveur introuvable", prenom: "", licence: 0))
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                    self.initScroll()
                    self.loadVisiblePages()
                }
                _ = alert.addButton("Lancer la démonstration"){
                    preference.ipServer = "109.10.173.81"
                    self.api!.selectpraticien()
                }
                _ = alert.addButton("Réessayer"){
                    self.api!.pingServer()
                }
                
                _ = alert.showInfo("Serveur Introuvable", subTitle: "Veuillez saisir une adresse correct")
                
            case 2 :
                self.praticiens.removeAll(keepingCapacity: false)
                self.praticiens.append(Praticien(id: 0, nom:"Fichier(s) manquant(s)", prenom: "", licence: 0))
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.initScroll()
                self.loadVisiblePages()
                self.scrollView.reloadInputViews()
            default :
                print("exception non gérée")
                
            }
        })
    }
    func delay(seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
}
