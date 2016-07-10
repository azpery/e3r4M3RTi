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
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.blackColor()
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
        searchButton.setFAIcon(FAType.FASearch, iconSize: 24)
        trashButton.setFAIcon(FAType.FATrash, iconSize: 24)
        refreshButton.setFAIcon(FAType.FARefresh, iconSize: 24)
        closeButton.setFAIcon(FAType.FATimes, iconSize: 24)
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "Saisie des actes -  Dr \(preference.nomUser) - \(schemaDentController!.patient!.nom) \(schemaDentController!.patient!.prenom.capitalizedString)"
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
    
    @IBAction func dismiss(sender: AnyObject) {
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began || gestureRecognizer.state == UIGestureRecognizerState.Changed {
            if gestureRecognizer.locationInView(self.view).x >= 0 && gestureRecognizer.locationInView(self.view).x < 50{
                let translation = gestureRecognizer.translationInView(self.view)
                self.rightPanel.frame =  CGRect(x: self.rightPanel.frame.origin.x, y: self.rightPanel.frame.origin.y, width: ((self.rightPanel.frame.width) + translation.x), height: (self.rightPanel.frame.height))
            }
        }
    }
    
    @IBAction func emptyFses(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = SCLAlertView()
            alert.showCloseButton = false
            alert.addButton("Confirmer"){
                let api = APIController()
                self.saisieActesController!.prestation = []
                api.insertActes(self.saisieActesController!.patient!, actes: [] )
                self.saisieActesController!.tableView.reloadData()
            }
            alert.addButton("Annuler"){
            }
            alert.showInfo("Voulez-vous vider la FSE?", subTitle: "Confirmer la suppression de la feuille de soin.")
        })
    }
    
    @IBAction func resfreshViews(sender: AnyObject) {
        saisieActesController!.refresh()
    }
    
    
}
