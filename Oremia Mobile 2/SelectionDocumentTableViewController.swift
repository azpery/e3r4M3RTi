//
//  SelectionDocumentTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 09/05/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class SelectionDocumentTableViewController: UITableViewController, APIControllerProtocol {
    var callback:((_ index:Int)->Void)?
    lazy var api : APIController = APIController(delegate: self)
    var typeDocuments:[TypeModeleDocument] = []
    var detailview:ModeleDocumentEditorViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        api.sendRequest("SELECT idtype, nomtype FROM typedocument;")
    }
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.typeDocuments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionModeleCell", for: indexPath) as! ModeleDocumentEditorTableViewCell
        cell.nomModeleLabel.text = self.typeDocuments[indexPath.row].nomType ?? "Nom du type de modèle non renseigné"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let call = self.callback {
            self.dismiss(animated: true, completion: {call(self.typeDocuments[indexPath.row].idType)})
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
