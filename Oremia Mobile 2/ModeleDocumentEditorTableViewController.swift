//
//  ModeleDocumentEditorTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 29/06/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class ModeleDocumentEditorTableViewController: UITableViewController, APIControllerProtocol {
    lazy var api : APIController = APIController(delegate: self)
    var typeDocuments:[TypeModeleDocument] = []
    var detailview:ModeleDocumentEditorViewController?
    @IBOutlet var barButton: UIBarButtonItem!
    @IBOutlet var newModele: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailview = self.splitViewController!.xx_secondaryViewController as? ModeleDocumentEditorViewController
        newModele.setFAIcon(FAType.faPlus, iconSize: 21)
        barButton.setFAIcon(FAType.faBars, iconSize: 24)
        api.sendRequest("SELECT idtype, nomtype FROM typedocument;")
        if self.revealViewController() != nil{
            barButton.target = self.revealViewController()
            barButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    @IBAction func newDocument(_ sender: AnyObject) {
        
        
        let alert = SCLAlertView()
        let txt = alert.addTextField("Questionnaire médical")
        alert.showCloseButton = false
        alert.addButton("Ajouter"){
            self.api.sendRequest("INSERT INTO typedocument(nomtype, nomfichier) VALUES('\(txt.text!)', '') RETURNING idtype",success: {
                (results)->Bool in
                let resultsArr: NSArray = (results["results"] as? NSArray) ?? []
                let id = resultsArr[0] as! NSDictionary
                self.api.sendRequest("SELECT idtype, nomtype FROM typedocument;")
                self.detailview?.loadDocument(id["idtype"] as! Int)
                return true
            })
        }
        alert.addButton("Annuler"){
            
        }
        alert.showInfo("Créer un nouveau questionnaire", subTitle: "Veuillez nommer votre questionaire")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.typeDocuments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModeleCell", for: indexPath) as! ModeleDocumentEditorTableViewCell
        cell.nomModeleLabel.text = self.typeDocuments[indexPath.row].nomType ?? "Nom du type de modèle non renseigné"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailview = self.detailview{
            detailview.loadDocument(self.typeDocuments[indexPath.row].idType)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        DispatchQueue.main.async(execute: {
            self.typeDocuments = TypeModeleDocument.typeDocumentWithJSON(resultsArr)
            self.tableView.reloadData()
        })
    }
    func handleError(_ results: Int) {
        self.tableView.reloadData()
        
    }
}
