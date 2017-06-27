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
        searchButton.setFAIcon(FAType.faSearch, iconSize: 24)
        trashButton.setFAIcon(FAType.faTrash, iconSize: 24)
        refreshButton.setFAIcon(FAType.faRefresh, iconSize: 24)
        closeButton.setFAIcon(FAType.faTimes, iconSize: 24)
        //favorisButton.setFAIcon(FAType.FAPlus, iconSize: 24)
        favorisButton.title = ""
        saveButton.setFAIcon(FAType.faFloppyO, iconSize: 24)
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "Saisie des actes -  Dr \(preference.nomUser) - \(schemaDentController!.patient!.getFullName())"
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.pad){
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: SchemaDentaireCollectionViewController.self){
            let destinationView: SchemaDentaireCollectionViewController = segue.destination as! SchemaDentaireCollectionViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            destinationView.patient = tb.patient!
            destinationView.sourceViewNavigationBar = self.navigationController
            destinationView.sourceViewTabBar = self.tabBarController
            destinationView.actesController = self
            self.schemaDentController = destinationView
        }else
            if segue.destination.isKind(of: SaisieActesTableViewController.self){
                let destinationView: SaisieActesTableViewController = segue.destination as! SaisieActesTableViewController
                let tb : TabBarViewController = self.tabBarController as! TabBarViewController
                destinationView.patient = tb.patient!
                destinationView.actesController = self
                self.saisieActesController = destinationView
            }else if segue.destination.isKind(of: ListeActesTableViewController.self){
                let destinationView: ListeActesTableViewController = segue.destination as! ListeActesTableViewController
                let tb : TabBarViewController = self.tabBarController as! TabBarViewController
                destinationView.patient = tb.patient!
                destinationView.actesController = self
                self.listeActesController = destinationView
        }else
        
        if segue.destination.isKind(of: UINavigationController.self){
            let navigationController: UINavigationController = segue.destination as! UINavigationController
            let viewControllers = navigationController.viewControllers
            
            let destination: NoteActeTableViewController = viewControllers.first as! NoteActeTableViewController
            destination.acte = self.saisieActesController!.selectedActe
            destination.callback = self.saisieActesController!.callback
            destination.preferredContentSize = CGSize(width: 605, height: 305)
            destination.title = "\(self.saisieActesController!.selectedActe!.description) )"
        }
        
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
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
    
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func emptyFses(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
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
    @IBAction func showFavoris(_ sender: AnyObject) {
//        let VC1 = self.storyboard!.instantiateViewControllerWithIdentifier("FavorisViewController") as! UINavigationController
//        let viewControllers = VC1.viewControllers
//        VC1.modalPresentationStyle = UIModalPresentationStyle.PageSheet
//        let favorisView: FavorisTableViewController = viewControllers.first as! FavorisTableViewController
//        favorisView.favorisPlus = self.listeActesController?.favorisPlus
//        favorisView.listeController = self.listeActesController
//        self.listeActesController?.favorisViewController = favorisView
//        self.listeActesController?.presentViewController(VC1, animated: true, completion: nil)
    }
    
    @IBAction func resfreshViews(_ sender: AnyObject) {
        saisieActesController!.refresh()
        schemaDentController?.loadData()
    }
    @IBAction func saveBridge(_ sender: AnyObject) {
        let alert = SCLAlertView()
        alert.showCloseButton = false
        alert.addButton("Confirmer"){
            var  sql = self.schemaDentController?.chart?.sql ?? ","
            sql = sql.substring(to: sql.characters.index(before: sql.endIndex))
            self.listeActesController?.api.sendInsert("INSERT INTO chart(idpatient, date, localisation, layer) VALUES\(sql);")
            self.schemaDentController?.chart?.sql = ""
        }
        alert.addButton("Annuler"){
        }
        alert.showInfo("Voulez-vous enregister le schéma?", subTitle: "Vous allez enregistrer le schéma dentaire.\n Note: la FSE s'enregistre automatiquement.")
        
    }

    
    
}
