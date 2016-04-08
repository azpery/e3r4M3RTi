//
//  DocumentPatientTableViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 21/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class DocumentPatientTableViewController: UITableViewController, APIControllerProtocol {
    var api=APIController?()
    var patient:patients?
    var lesDocuments = [Document]()
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
        return i
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var i = 0
        if (section == 0 && lesDocuments.count > 0){
            i = lesDocuments.count
        } else {
            i = lesModeleDocuments.count
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
        } else {
            let ddate = dateFormat.dateFromString(lesModeleDocuments[row].date)
            dateFormat.timeStyle = NSDateFormatterStyle.NoStyle
            dateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
            cell.dateLabel.text = dateFormat.stringFromDate(ddate!)
            cell.nomLabel.text = lesModeleDocuments[row].nomDocument
            cell.mimeIcon.setFAIcon(FAType.FAHtml5, iconSize: 17)
            //cell.backgroundColor = UIColor(red: 240, green: 73, blue: 23, alpha: 50)
        }

        return cell
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView()
        var title = ""
        switch section{
        case 0:
            if (lesDocuments.count>0){
                title = "Documents"
            }else {
                title = "Modeles de documents"
            }
            break
        case 1:
            title = "Modeles de documents"
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
            case "showDocument":
                if (documentTableView.indexPathForSelectedRow!.section == 0 && lesDocuments.count > 0){
                    let idr:Int = lesDocuments[documentTableView.indexPathForSelectedRow!.row].id
                    //var selectedDocument = api!.getRadioFromUrl(idr)
                    fullScreenView.document = lesDocuments[documentTableView.indexPathForSelectedRow!.row]
                    fullScreenView.leDocument = api!.getUrlFromDocument(idr)
                } else {
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

    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            switch self.whichType{
            case 0:
                self.lesDocuments = Document.documentWithJSON(resultsArr)
                self.documentTableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.api!.sendRequest("SELECT  md.iddocument, t.nomtype, md.date FROM modele_document md INNER JOIN typedocument t ON md.idtype = t.idtype  WHERE md.idpatient = \(self.patient!.id)")
                self.whichType++
                break
            case 1:
                self.lesModeleDocuments = ModeleDocument.documentWithJSON(resultsArr)
                self.documentTableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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

}
