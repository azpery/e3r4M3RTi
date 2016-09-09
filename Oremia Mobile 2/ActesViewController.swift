//
//  ActesViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 20/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class ActesViewController: UIViewController {
    var schemaDentController:SchemaDentaireCollectionViewController?
    var saisieActesController:SaisieActesTableViewController?
    var listeActesController:ListeActesTableViewController?
    let scl = SCLAlertView()
    var activityIndicator = DTIActivityIndicatorView()
    var finished = 0
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var dragside: UIButton!
    @IBOutlet var dragbottom: UIButton!
    @IBOutlet var leftPanel: UIView!
    @IBOutlet var bottomPanel: UIView!
    @IBOutlet var rightPanel: UIView!
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var trashButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var favorisButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingOverlay.shared.showOverlay(self.view)
        searchButton.setFAIcon(FAType.FASearch, iconSize: 24)
        trashButton.setFAIcon(FAType.FATrash, iconSize: 24)
        refreshButton.setFAIcon(FAType.FARefresh, iconSize: 24)
        closeButton.setFAIcon(FAType.FATimes, iconSize: 24)
        //favorisButton.setFAIcon(FAType.FAPlus, iconSize: 24)
        favorisButton.title = ""
        saveButton.setFAIcon(FAType.FAFloppyO, iconSize: 24)
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "Saisie des actes -  Dr \(preference.nomUser) - \(schemaDentController!.patient!.nom) \(schemaDentController!.patient!.prenom.capitalizedString)"
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.Pad){
            Overlay.shared.showOverlay(self.view, text: "Cet onglet n'est disponible que sur iPad.")
        }
        if (self.interfaceOrientation.isPortrait)
        {
            Overlay.shared.showOverlay(self.view, text: "Veuillez tourner votre iPad en mode paysage.")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(SchemaDentaireCollectionViewController){
            let destinationView: SchemaDentaireCollectionViewController = segue.destinationViewController as! SchemaDentaireCollectionViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            destinationView.patient = tb.patient!
            destinationView.sourceViewNavigationBar = self.navigationController
            destinationView.sourceViewTabBar = self.tabBarController
            destinationView.actesController = self
            self.schemaDentController = destinationView
        }else
            if segue.destinationViewController.isKindOfClass(SaisieActesTableViewController){
                let destinationView: SaisieActesTableViewController = segue.destinationViewController as! SaisieActesTableViewController
                let tb : TabBarViewController = self.tabBarController as! TabBarViewController
                destinationView.patient = tb.patient!
                destinationView.actesController = self
                self.saisieActesController = destinationView
            }else if segue.destinationViewController.isKindOfClass(ListeActesTableViewController){
                let destinationView: ListeActesTableViewController = segue.destinationViewController as! ListeActesTableViewController
                let tb : TabBarViewController = self.tabBarController as! TabBarViewController
                destinationView.patient = tb.patient!
                destinationView.actesController = self
                self.listeActesController = destinationView
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if(toInterfaceOrientation.isLandscape){
            Overlay.shared.hideOverlayView()
        }else{
            Overlay.shared.showOverlay(self.view, text: "Veuillez tourner votre iPad en mode paysage.")
        }
    }
    
//    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation:UIInterfaceOrientation){
//        if (!UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
//        {
//            Overlay.shared.showOverlay(self.view, text: "Veuillez tourner votre iPad en mode paysage.")
//        }else{
//            Overlay.shared.hideOverlayView()
//        }
//    }
    
    
    @IBAction func dismiss(sender: AnyObject) {
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func emptyFses(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = SCLAlertView()
            alert.showCloseButton = false
            alert.addButton("Confirmer"){
                let api = APIController()
                self.saisieActesController!.prestation = []
                self.schemaDentController?.chart?.sql = ""
                api.insertActes(self.saisieActesController!.patient!, actes: [] )
                self.saisieActesController!.tableView.reloadData()
            }
            alert.addButton("Annuler"){
            }
            alert.showInfo("Voulez-vous vider la FSE?", subTitle: "Confirmer la suppression de la feuille de soin.")
        })
    }
    @IBAction func showFavoris(sender: AnyObject) {
//        let VC1 = self.storyboard!.instantiateViewControllerWithIdentifier("FavorisViewController") as! UINavigationController
//        let viewControllers = VC1.viewControllers
//        VC1.modalPresentationStyle = UIModalPresentationStyle.PageSheet
//        let favorisView: FavorisTableViewController = viewControllers.first as! FavorisTableViewController
//        favorisView.favorisPlus = self.listeActesController?.favorisPlus
//        favorisView.listeController = self.listeActesController
//        self.listeActesController?.favorisViewController = favorisView
//        self.listeActesController?.presentViewController(VC1, animated: true, completion: nil)
    }
    
    @IBAction func resfreshViews(sender: AnyObject) {
        saisieActesController!.refresh()
        schemaDentController?.loadData()
    }
    @IBAction func saveBridge(sender: AnyObject) {
        let alert = SCLAlertView()
        alert.showCloseButton = false
        alert.addButton("Confirmer"){
            var  sql = self.schemaDentController?.chart?.sql ?? ","
            sql = sql.substringToIndex(sql.endIndex.predecessor())
            self.listeActesController?.api.sendInsert("INSERT INTO chart(idpatient, date, localisation, layer) VALUES\(sql);")
            self.schemaDentController?.chart?.sql = ""
        }
        alert.addButton("Annuler"){
        }
        alert.showInfo("Voulez-vous enregister le schéma?", subTitle: "Vous allez enregistrer le schéma dentaire.\n Note: la FSE s'enregistre automatiquement.")
        
    }

    
    
}
