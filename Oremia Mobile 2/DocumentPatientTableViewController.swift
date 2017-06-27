//
//  DocumentPatientTableViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 21/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import QuickLook
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


class DocumentPatientTableViewController: UITableViewController, APIControllerProtocol, QLPreviewControllerDataSource,UIPopoverPresentationControllerDelegate {
    var api:APIController?
    var patient:patients?
    var lesDocuments = [Document]()
    var lesDocumentsWord = [Document]()
    var lesModeleDocuments = [ModeleDocument]()
    var whichType = 0
    var index = 0
    var selectedDoc=0
    var signing = false
    @IBOutlet var documentTableView: UITableView!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var newDocument: UIBarButtonItem!
    @IBOutlet var signerButton: UIBarButtonItem!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        api = APIController(delegate: self)
        let tb : TabBarViewController = self.tabBarController as! TabBarViewController
        patient = tb.patient!
        api!.sendRequest("SELECT id,nom,date FROM documents WHERE idpatient = \(patient!.id) AND type='PDF'")
        
        menuButton.setFAIcon(FAType.faSearch, iconSize: 24)
        quitButton.setFAIcon(FAType.faTimes, iconSize: 24)
        newDocument.setFAIcon(FAType.faPlus, iconSize: 24)
        self.refreshControl?.addTarget(self, action: #selector(DocumentPatientTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "\(title.title!) -  Dr \(preference.nomUser) - \(patient!.getFullName())"
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTabBarVisible(true, animated: true)
    }
    
    @IBAction func performSigningAction(_ sender: AnyObject) {
        if self.signing {
            self.signing = false
            self.signerButton.title = "Signer"
            self.tableView.reloadData()
        }else{
            self.signing = true
            self.signerButton.title = "Annuler"
            self.tableView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var i = 0
        if (lesDocuments.count > 0 ){i += 1;self.signerButton.isEnabled = true}else{self.signerButton.isEnabled = false}
        if (lesModeleDocuments.count > 0 && !self.signing){i += 1}
        if (lesDocumentsWord.count > 0 && !self.signing){i += 1}
        ToolBox.setDefaultBackgroundMessage(self.tableView, elements: i, message: "Aucun document n'a été créé")
        return i
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var i = 0
        if (section == 0 && lesDocuments.count > 0){
            i = lesDocuments.count
        } else if (section == 1 && lesModeleDocuments.count > 0 || section == 0 && lesModeleDocuments.count > 0){
            i = lesModeleDocuments.count
        }else{
            i = lesDocumentsWord.count
        }
        return i
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath) as! DocumentTableViewCell
        let row = indexPath.row
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        if(indexPath.section == 0 && lesDocuments.count>0){
            let ddate = dateFormat.date(from: lesDocuments[row].date)
            dateFormat.timeStyle = DateFormatter.Style.none
            dateFormat.dateStyle = DateFormatter.Style.medium
            cell.dateLabel.text = dateFormat.string(from: ddate!)
            cell.nomLabel.text = lesDocuments[row].nom
            cell.mimeIcon.setFAIcon(FAType.faFilePdfO, iconSize: 17)
            //            cell.backgroundColor = UIColor(red: 215, green: 20, blue: 18, alpha: 50)
        } else if (indexPath.section == 1 && lesModeleDocuments.count > 0 || indexPath.section == 0 && lesModeleDocuments.count > 0){
            let ddate = dateFormat.date(from: lesModeleDocuments[row].date)
            dateFormat.timeStyle = DateFormatter.Style.none
            dateFormat.dateStyle = DateFormatter.Style.medium
            cell.dateLabel.text = dateFormat.string(from: ddate!)
            cell.nomLabel.text = lesModeleDocuments[row].nomDocument
            cell.mimeIcon.setFAIcon(FAType.faHtml5, iconSize: 17)
            //cell.backgroundColor = UIColor(red: 240, green: 73, blue: 23, alpha: 50)
        }else{
            let ddate = dateFormat.date(from: lesDocumentsWord[row].date)
            dateFormat.timeStyle = DateFormatter.Style.none
            dateFormat.dateStyle = DateFormatter.Style.medium
            cell.dateLabel.text = dateFormat.string(from: ddate!)
            cell.nomLabel.text = lesDocumentsWord[row].nom
            cell.mimeIcon.setFAIcon(FAType.faFile, iconSize: 17)
            //            cell.backgroundColor = UIColor(red: 215, green: 20, blue: 18, alpha: 50)
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView()
        var title = ""
        switch section{
        case 0:
            if (lesDocuments.count>0){
                title = "Documents PDF"
            }else if (lesModeleDocuments.count>0) {
                title = "Modeles de documents"
            }else{
                title = "Documents Word"
            }
            break
        case 1:
            if (lesModeleDocuments.count>0) {
                title = "Modeles de documents"
            }else{
                title = "Documents Word"
            }
            break
        case 2:
            title = "Documents Word"
            break
            
        default:
            break
        }
        view.titleLabel.text = title
        return view
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            var idDoc:Int
            let row = indexPath.row
            var query = ""
            if(indexPath.section == 0 && lesDocuments.count>0){
                idDoc = lesDocuments[row].id
                self.lesDocuments.remove(at: row)
                query = "DELETE FROM documents WHERE id = \(idDoc)"
            } else if (indexPath.section == 1 && lesModeleDocuments.count > 0 || indexPath.section == 0 && lesModeleDocuments.count > 0){
                idDoc = lesModeleDocuments[row].idDocument
                query = "DELETE FROM modele_document WHERE iddocument = \(idDoc)"
                self.lesModeleDocuments.remove(at: row)
            }else{
                idDoc = lesDocumentsWord[row].id
                query = "DELETE FROM documents WHERE id = \(idDoc)"
                self.lesDocumentsWord.remove(at: row)
            }
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            api?.sendRequest(query, success: {results->Bool in
            return true})
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    @IBAction func dismiss(_ sender: AnyObject) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: SelectionDocumentTableViewController.self){
            let fullScreenView: SelectionDocumentTableViewController = segue.destination as! SelectionDocumentTableViewController
            fullScreenView.callback = self.callback
            segue.destination.popoverPresentationController!.delegate = self
        }else
            if segue.destination.isKind(of: FullScreenDocumentViewController.self){
                let fullScreenView: FullScreenDocumentViewController = segue.destination as! FullScreenDocumentViewController
                switch segue.identifier! {
                case "showDocumentSegue":
                    if (documentTableView.indexPathForSelectedRow!.section == 0 && lesDocuments.count > 0){
                        let idr:Int = lesDocuments[documentTableView.indexPathForSelectedRow!.row].id
                        //var selectedDocument = api!.getRadioFromUrl(idr)
                        fullScreenView.document = lesDocuments[documentTableView.indexPathForSelectedRow!.row]
                        fullScreenView.leDocument = api!.getUrlFromDocument(idr)
                    } else if (documentTableView.indexPathForSelectedRow!.section == 1 && lesDocuments.count > 0 && lesModeleDocuments.count > 0 || documentTableView.indexPathForSelectedRow!.section == 0  && lesModeleDocuments.count > 0){
                        let idr:Int = lesModeleDocuments[documentTableView.indexPathForSelectedRow!.row].idDocument
                        //var selectedDocument = api!.getRadioFromUrl(idr)
                        fullScreenView.modeleDocument = lesModeleDocuments[documentTableView.indexPathForSelectedRow!.row]
                        fullScreenView.leDocument = api!.getUrlFromDocument(idr)
                        fullScreenView.patient = patient
                    }
                    break
                case "addNewDocument" :
                    fullScreenView.isNew = true
                    fullScreenView.patient = self.patient
                    fullScreenView.idDocument = self.index
                    self.setTabBarVisible(false, animated: true)
                    break
                case "createNewDocument" :
                    fullScreenView.isCreate = true
                    fullScreenView.patient = self.patient
                    break
                default: break
                }
                
        }else if segue.destination.isKind(of: UINavigationController.self) && segue.identifier == "showSignature"{
                let navigationController: UINavigationController = segue.destination as! UINavigationController
                let viewControllers = navigationController.viewControllers
                
                let signatureView: TypeDocumentTableViewController = viewControllers.first as! TypeDocumentTableViewController
                signatureView.preferredContentSize = CGSize(width: 605, height: 350)
                signatureView.patient = self.patient
                signatureView.success = self.insertSignature
        }
    }
    func callback(_ index:Int){
        self.index = index
        self.performSegue(withIdentifier: "addNewDocument", sender: self)
    }
    
    func insertSignature(_ sPrat:String, sPatient:String, selectedRow: Int) -> Void{
        var activityIndicator = DTIActivityIndicatorView()
        DispatchQueue.main.async(execute: {
            activityIndicator = ToolBox.startActivity(self.view)
        })
        api?.signDocument(sPrat, sPatient: sPatient, idDoc: self.selectedDoc, idPatient: self.patient!.id,selectedRow: selectedRow, success: {id -> Bool in
            
            let previewQL = QLPreviewController()
            previewQL.dataSource = self
            self.lesDocuments.append(Document(id: id, nom: self.lesDocuments[self.documentTableView.indexPathForSelectedRow!.row].nom, date: ToolBox.getFormatedDate(Date())))
            previewQL.currentPreviewItemIndex = self.lesDocuments.count - 1
            DispatchQueue.main.async(execute: {
                ToolBox.stopActivity(activityIndicator)
                self.show(previewQL, sender: nil)
            })
            return true
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1 && lesDocuments.count > 0 && lesModeleDocuments.count > 0 || indexPath.section == 0 &&  lesModeleDocuments.count > 0 && lesDocuments.count == 0){
            self.performSegue(withIdentifier: "showDocumentSegue", sender: self)
        } else {
            if !self.signing{
                let previewQL = QLPreviewController()
                previewQL.dataSource = self
                previewQL.currentPreviewItemIndex = documentTableView.indexPathForSelectedRow!.row
                show(previewQL, sender: nil)
            }else{
                self.selectedDoc = lesDocuments[indexPath.row].id
                self.performSegue(withIdentifier: "showSignature", sender: self)
            }
            
        }        
    }
    

    
    
    func handleRefresh(_ refreshControl:UIRefreshControl){
        api!.sendRequest("SELECT id,nom,date FROM documents WHERE idpatient = \(patient!.id) AND type='PDF'")
        
        
    }
    
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        DispatchQueue.main.async(execute: {
            switch self.whichType{
            case 0:
                self.lesDocuments = Document.documentWithJSON(resultsArr)
                self.documentTableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.api!.sendRequest("SELECT  md.iddocument, t.nomtype, md.date FROM modele_document md INNER JOIN typedocument t ON md.idtype = t.idtype  WHERE md.idpatient = \(self.patient!.id)")
                self.whichType = 1
                break
            case 1:
                self.api!.sendRequest("SELECT id,nom,date FROM documents WHERE idpatient = \(self.patient!.id) AND type='DOC'")
                self.lesModeleDocuments = ModeleDocument.documentWithJSON(resultsArr)
                self.documentTableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let a = self.refreshControl {
                    if a.isRefreshing {
                        a.endRefreshing()
                    }
                }
                self.whichType = 2
                break
            case 2:
                self.lesDocumentsWord = Document.documentWithJSON(resultsArr)
                self.documentTableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.whichType = 0
                break
            default:
                break
            }
        })
    }
    func handleError(_ results: Int) {
        if results == 1{
            api!.sendRequest("SELECT id,nom,date FROM documents WHERE idpatient = \(patient!.id) AND type='PDF'")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    //qldelegate
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int{
        if (documentTableView.indexPathForSelectedRow!.section == 0 && lesDocuments.count > 0){
            return lesDocuments.count
        } else {
            return lesDocumentsWord.count
        }
        
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        var idr:Int = 0
        //var selectedDocument = api!.getRadioFromUrl(idr)
        var fileType = ""
        var nom = ""
        if (documentTableView.indexPathForSelectedRow!.section == 0 && lesDocuments.count > 0 || self.signing){
            idr = lesDocuments[index].id
            nom = lesDocuments[index].nom
            fileType = "pdf"
        } else {
            idr = lesDocumentsWord[index].id
            nom = lesDocumentsWord[index].nom
            fileType = "doc"
        }
        let doc = api!.getUrlFromDocument(idr)
        let path = APIController.loadFileSync(doc,fileType: fileType, nom: nom, id: idr, completion:{(path:String, error:NSError!) in })
        return path as QLPreviewItem
    }
    
    func setTabBarVisible(_ visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animate(withDuration: duration, animations: {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }) 
        }
    }
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < self.view.frame.maxY
    }
    
}
