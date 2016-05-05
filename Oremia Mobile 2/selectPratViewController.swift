//
//  selectPratViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 07/05/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit

class selectPratViewController: UIViewController, UIScrollViewDelegate, APIControllerProtocol{
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnConnexion: UIButton!
    @IBOutlet weak var password: UITextField!
    var pageViews: [UIButton?] = []
    var api = APIController?()
    var praticiens = [Praticien]()
    var mdp:String?
    var selectedPrat:Praticien?
    var timer = NSTimer()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        self.displayLoad()
        btnConnexion.hidden = true
        let test = HelpButton()
        test.showButton(self)
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        api!.pingServer()
        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        
        
        
    }
    override func viewDidAppear(animated: Bool) {
        
        //api!.sendRequest("select id,nom,prenom from praticiens")
        btnConnexion.addTarget(self, action: "clicked", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UINavigationBar.appearance().barTintColor = ToolBox.UIColorFromRGB(0x34495E)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {
        displayLoad()
        //        api!.selectpraticien()
        api?.pingServer()
        
        //api!.sendRequest("select id,nom,prenom from praticiens")
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        return true
    }
    func displayLoad(){
        self.praticiens.removeAll(keepCapacity: false)
        self.praticiens.append(Praticien(id: 0, nom:"Recherche du Serveur...", prenom: ""))
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.initScroll()
        self.loadVisiblePages()
        self.scrollView.reloadInputViews()
        preference.ipServer = api!.readServerAdress()
        btnConnexion.hidden = true
        self.password.hidden = true
    }
    func clicked(){
        mdp="zuma"
        if(!password.text!.isEmpty){
            mdp = password.text
        }
        selectedPrat=praticiens[pageControl.currentPage]
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        connexionString.login = "zm\(self.selectedPrat!.id)"
        connexionString.pw = self.mdp!
        self.api!.setConnexion()
        //api!.sendRequest("select COUNT(*) as correct from praticiens")
        
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        print("yolo")
        if(!UIApplication.sharedApplication().networkActivityIndicatorVisible){
            loadVisiblePages()
        }
    }
    func loadPage(page: Int) {
        if page < 0 || page >= self.praticiens.count {
            return
        }
        var frame = scrollView.bounds
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0
        let newPageView = UIButton(frame: CGRectMake(100, 100, 100, 50))
        newPageView.backgroundColor=UIColor.orangeColor()
        if (self.praticiens[0].id != 0) {
            newPageView.setTitle("Dr "+self.praticiens[page].prenom+" "+self.praticiens[page].nom, forState: UIControlState.Normal)
        } else {
            newPageView.setTitle(self.praticiens[page].nom, forState: UIControlState.Normal)
        }
        newPageView.contentMode = .ScaleAspectFit
        newPageView.frame = frame
        scrollView.addSubview(newPageView)
        
        pageViews[page] = newPageView
    }
    func purgePage(page: Int) {
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
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < self.praticiens.count; ++index {
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
        SwiftSpinner.show("Mise à jour des fichiers...")
        SwiftSpinner.showWithDelay(15.0, title: "Nous mettons à jour les fichiers sur le poste serveur.")
    }
    func pingResult(success:NSNumber){
        if(success.boolValue){
            api!.checkFileUpdate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "showActivityLoader", userInfo: nil, repeats: true)
        }else {
            self.handleError(1)
        }
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        self.timer.invalidate()
        if let resultsArr: NSArray = results["results"] as? NSArray {
            var type = 1
            var nb:Int?
            for value in resultsArr{
                if value.objectForKey("correct") !=  nil{
                    type = 0
                    nb = value["correct"] as? Int
                }
                if value.objectForKey("connexionBegin") !=  nil{
                    preference.idUser = self.selectedPrat!.id
                    preference.nomUser = self.selectedPrat!.nom
                    preference.prenomUser = self.selectedPrat!.prenom
                    preference.password = self.mdp!
                    connexionString.login = "zm\(self.selectedPrat!.id)"
                    connexionString.pw=self.mdp!
                    self.performSegueWithIdentifier("connectionGranted", sender:self)
                }
                if value.objectForKey("error") !=  nil && value["error"] as? Int == 7{
                    type = 2
                }
            }
            if type == 0{
                if nb > 0{
                    dispatch_async(dispatch_get_main_queue(), {
                        preference.idUser = self.selectedPrat!.id
                        preference.nomUser = self.selectedPrat!.nom
                        preference.prenomUser = self.selectedPrat!.prenom
                        preference.password = self.mdp!
                        connexionString.login = "zm\(self.selectedPrat!.id)"
                        connexionString.pw=self.mdp!
                        self.api!.setConnexion()
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    })
                }
            }else if type == 2{
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = SCLAlertView()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    alert.showError("Mot de passe incorrect", subTitle: "Mot de passe incorrect ou inexistant, veuillez resaisir vos identifiants", closeButtonTitle:"Fermer")
                })
                
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.praticiens = Praticien.praticienWithJSON(resultsArr)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.initScroll()
                    self.loadVisiblePages()
                    self.btnConnexion.hidden = false
                    self.password.hidden = false
                })
            }
        } else if let resultsArr: String = results["results"] as? String {
            dispatch_async(dispatch_get_main_queue(), {
                self.timer.invalidate()
                if resultsArr == "AJ" {
                    SwiftSpinner.hide()
                    self.api!.selectpraticien()
                }else if resultsArr == "3"{
                    SwiftSpinner.hide()
                    let alert = SCLAlertView()
                    alert.showCloseButton = false
                    alert.addButton("Lancer la démonstration"){
                        preference.ipServer = "77.153.245.34"
                        self.api!.selectpraticien()
                    }
                    alert.addButton("Besoin d'aide?") {
                        let help = HelpButton()
                        help.caller = self
                        help.triggerPopOver()
                    }
                    alert.showError("Erreur serveur", subTitle: "Veuillez contacter le service technique. \nLe serveur n'a pas les droits suffisant pour mettre à jour les fichiers.\nVeuillez nous excuser mais il est nécessaire d'effectuer une opération sur votre poste serveur.")
                    
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
    func handleError(results: Int) {
        dispatch_async(dispatch_get_main_queue(), {
            SwiftSpinner.hide()
            self.timer.invalidate()
            switch results {
            case 1 :
                
                //            SCLAlertView().showError("Serveur introuvable", subTitle: "Veuillez rentrer une adresse ip de serveur correct", closeButtonTitle:"Fermer", duration: 800)
                self.praticiens.removeAll(keepCapacity: false)
                self.praticiens.append(Praticien(id: 0, nom:"Serveur introuvable", prenom: ""))
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let alert = SCLAlertView()
                let txt = alert.addTextField(preference.ipServer)
                alert.showCloseButton = false
                alert.addButton("Valider") {
                    self.displayLoad()
                    print("Text value: \(txt.text)")
                    preference.ipServer=txt.text!
                    self.api!.updateServerAdress(txt.text!)
                    self.api!.pingServer()
//                    self.api!.selectpraticien()
                }
                alert.addButton("Lancer la démonstration"){
                    preference.ipServer = "77.153.245.34"
                    self.api!.selectpraticien()
                }
                alert.showInfo("Serveur Introuvable", subTitle: "Veuillez saisir une adresse correct")
                self.initScroll()
                self.loadVisiblePages()
            case 2 :
                self.praticiens.removeAll(keepCapacity: false)
                self.praticiens.append(Praticien(id: 0, nom:"Fichier(s) manquant(s)", prenom: ""))
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.initScroll()
                self.loadVisiblePages()
                self.scrollView.reloadInputViews()
            default :
                print("exception non gérée")
                
            }
        })
    }
    func delay(seconds seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
}
