//
//  DocumentPatientTableViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 21/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import QuickLook

class DocumentPatientTableViewController: UITableViewController, APIControllerProtocol, QLPreviewControllerDataSource {
    var api=APIController?()
    var patient:patients?
    var lesDocuments = [Document]()
    var lesDocumentsWord = [Document]()
    var lesModeleDocuments = [ModeleDocument]()
    var whichType = 0
    @IBOutlet var documentTableView: UITableView!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var newDocument: UIBarButtonItem!
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
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        menuButton.setFAIcon(FAType.FASearch, iconSize: 24)
        quitButton.setFAIcon(FAType.FATimes, iconSize: 24)
        newDocument.setFAIcon(FAType.FAPlus, iconSize: 24)
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        var i = 0
        if (lesDocuments.count > 0){i++}
        if (lesModeleDocuments.count > 0){i++}
        if (lesDocumentsWord.count > 0){i++}
        return i
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var i = 0
        if (section == 0 && lesDocuments.count > 0){
            i = lesDocuments.count
        } else if (section == 1 && lesModeleDocuments.count > 0){
            i = lesModeleDocuments.count
        }else{
            i = lesDocumentsWord.count
        }
        return i
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("documentCell", forIndexPath: indexPath) as! DocumentTableViewCell
        let row = indexPath.row
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        if(indexPath.section == 0 && lesDocuments.count>0){
            let ddate = dateFormat.dateFromString(lesDocuments[row].date)
            dateFormat.timeStyle = NSDateFormatterStyle.NoStyle
            dateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
            cell.dateLabel.text = dateFormat.stringFromDate(ddate!)
            cell.nomLabel.text = lesDocuments[row].nom
            cell.mimeIcon.setFAIcon(FAType.FAFilePdfO, iconSize: 17)
//            cell.backgroundColor = UIColor(red: 215, green: 20, blue: 18, alpha: 50)
        } else if (indexPath.section == 1 && lesModeleDocuments.count > 0){
            let ddate = dateFormat.dateFromString(lesModeleDocuments[row].date)
            dateFormat.timeStyle = NSDateFormatterStyle.NoStyle
            dateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
            cell.dateLabel.text = dateFormat.stringFromDate(ddate!)
            cell.nomLabel.text = lesModeleDocuments[row].nomDocument
            cell.mimeIcon.setFAIcon(FAType.FAHtml5, iconSize: 17)
            //cell.backgroundColor = UIColor(red: 240, green: 73, blue: 23, alpha: 50)
        }else{
            let ddate = dateFormat.dateFromString(lesDocumentsWord[row].date)
            dateFormat.timeStyle = NSDateFormatterStyle.NoStyle
            dateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
            cell.dateLabel.text = dateFormat.stringFromDate(ddate!)
            cell.nomLabel.text = lesDocumentsWord[row].nom
            cell.mimeIcon.setFAIcon(FAType.FAFile, iconSize: 17)
            //            cell.backgroundColor = UIColor(red: 215, green: 20, blue: 18, alpha: 50)

        }

        return cell
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    @IBAction func dismiss(sender: AnyObject) {
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(FullScreenDocumentViewController){
            let fullScreenView: FullScreenDocumentViewController = segue.destinationViewController as! FullScreenDocumentViewController
            switch segue.identifier! {
            case "showDocumentSegue":
                if (documentTableView.indexPathForSelectedRow!.section == 0 && lesDocuments.count > 0){
                    let idr:Int = lesDocuments[documentTableView.indexPathForSelectedRow!.row].id
                    //var selectedDocument = api!.getRadioFromUrl(idr)
                    fullScreenView.document = lesDocuments[documentTableView.indexPathForSelectedRow!.row]
                    fullScreenView.leDocument = api!.getUrlFromDocument(idr)
                } else if (documentTableView.indexPathForSelectedRow!.section == 1 && lesDocuments.count > 0 && lesModeleDocuments.count > 0){
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
                break
            default: break
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (documentTableView.indexPathForSelectedRow!.section == 1 && lesDocuments.count > 0 && lesModeleDocuments.count > 0){
            self.performSegueWithIdentifier("showDocumentSegue", sender: self)
        } else {
            let previewQL = QLPreviewController()
            previewQL.dataSource = self
            previewQL.currentPreviewItemIndex = documentTableView.indexPathForSelectedRow!.row
            showViewController(previewQL, sender: nil)
            
        }
        
    }
    
    
    
    func handleRefresh(refreshControl:UIRefreshControl){
        api!.sendRequest("SELECT id,nom,date FROM documents WHERE idpatient = \(patient!.id) AND type='PDF'")

    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            switch self.whichType{
            case 0:
                self.lesDocuments = Document.documentWithJSON(resultsArr)
                self.documentTableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.api!.sendRequest("SELECT  md.iddocument, t.nomtype, md.date FROM modele_document md INNER JOIN typedocument t ON md.idtype = t.idtype  WHERE md.idpatient = \(self.patient!.id)")
                self.whichType = 1
                break
            case 1:
                self.api!.sendRequest("SELECT id,nom,date FROM documents WHERE idpatient = \(self.patient!.id) AND type='DOC'")
                self.lesModeleDocuments = ModeleDocument.documentWithJSON(resultsArr)
                self.documentTableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let a = self.refreshControl {
                    if a.refreshing {
                        a.endRefreshing()
                    }
                }
                self.whichType = 2
                break
            case 2:
                self.lesDocumentsWord = Document.documentWithJSON(resultsArr)
                self.documentTableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.whichType = 0
                break
            default:
                break
            }
        })
    }
    func handleError(results: Int) {
        if results == 1{
            api!.sendRequest("SELECT id,nom,date FROM documents WHERE idpatient = \(patient!.id) AND type='PDF'")
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
    //qldelegate
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int{
        if (documentTableView.indexPathForSelectedRow!.section == 0 && lesDocuments.count > 0){
            return lesDocuments.count
        } else {
            return lesDocumentsWord.count
        }
        
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        var idr:Int = 0
        //var selectedDocument = api!.getRadioFromUrl(idr)
        var fileType = ""
        var nom = ""
        if (documentTableView.indexPathForSelectedRow!.section == 0 && lesDocuments.count > 0){
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
        return path
    }

}
