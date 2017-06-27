//
//  ActesTableViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 22/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import QuickLook

class ActesTableViewController: UITableViewController, APIControllerProtocol, QLPreviewControllerDataSource,UIPopoverPresentationControllerDelegate {
    
    var selectedActes:Actes = Actes()

    @IBOutlet var actesTableView: UITableView!
    var sortedActes = [String:[Actes]]()
    var lesActes = [Actes]()
    var patient:patients?
    var api:APIController?
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        self.clearsSelectionOnViewWillAppear = true
        api = APIController(delegate: self)
        let tb : TabBarViewController = self.tabBarController as! TabBarViewController
        patient = tb.patient!
        menuButton.setFAIcon(FAType.faSearch, iconSize: 24)
        quitButton.setFAIcon(FAType.faTimes, iconSize: 24)
        
        self.refreshControl?.addTarget(self, action: #selector(ActesTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "\(title.title!) -  Dr \(preference.nomUser) - \(patient!.getFullName())"

        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        api!.sendRequest("SELECT * FROM actes WHERE idpatient = \(patient!.id) ORDER BY date DESC")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        ToolBox.setDefaultBackgroundMessage(self.tableView, elements: sortedActes.count, message: "Aucun acte n'a été appliqué à ce jour")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return lesActes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "actesCell", for: indexPath) as! ActesTableViewCell
        let lActe = lesActes[indexPath.row]
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let ddate = dateFormat.date(from: lActe.date)
        dateFormat.timeStyle = DateFormatter.Style.none
        dateFormat.dateStyle = DateFormatter.Style.medium
        cell.date.text = dateFormat.string(from: ddate ?? Date())
        cell.descriptif.text = lActe.descriptif
        cell.montant.text = "\(lActe.montant)"
        switch lActe.lettre {
        case "C":
            cell.icon.setFAIcon(FAType.faEye, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xFFFFFF)
            break
        case "BDC":
            cell.icon.setFAIcon(FAType.faExclamationCircle, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xFFFFFF)
            break
        case "#REG":
            cell.icon.setFAIcon(FAType.faCalculator, iconSize: 17)
             cell.backgroundColor = ToolBox.UIColorFromRGB(0xB2BFBB)
            break
        case "#COM":
            cell.icon.setFAIcon(FAType.faPencilSquareO, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xFDF19C)
            break
        case "#FSE":
            cell.icon.setFAIcon(FAType.faFilePdfO, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0x94D500)
            break
        case "#DOC":
            cell.icon.setFAIcon(FAType.faFileText, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0x3EBFAC)
            break
        case "#MDT":
            cell.icon.setFAIcon(FAType.faBarcode, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xF7D44B)
            break
        case "#TODO":
            cell.icon.setFAIcon(FAType.faCheckCircle, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xFC7E88)
            break
        default :
            cell.icon.setFAIcon(FAType.faEuro, iconSize: 17)
            cell.backgroundColor = ToolBox.UIColorFromRGB(0xFFFFFF)
            break
        }
        if lActe.descriptif.contains("\n") {
            cell.noteIcon.isHidden = false
        }else{
            cell.noteIcon.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lettre = lesActes[indexPath.row].lettre
        if(lettre != "#MDT" && lettre != "#DOC" && lettre != "#REG"){
            selectedActes = lesActes[indexPath.row]
            performSegue(withIdentifier: "showNotesSegue", sender: self)
        }else if lettre == "#DOC"{
            let previewQL = QLPreviewController()
            previewQL.dataSource = self
            previewQL.currentPreviewItemIndex = indexPath.row
            show(previewQL, sender: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: UINavigationController.self) && segue.identifier == "showNotesSegue"{
            let navigationController: UINavigationController = segue.destination as! UINavigationController
            let viewControllers = navigationController.viewControllers
            
            let noteView: NotesTableViewController = viewControllers.first as! NotesTableViewController
            noteView.title = "\(selectedActes.lettre) - \(patient!.getFullName())"
            noteView.preferredContentSize = CGSize(width: 605, height: 305)
            noteView.acte = self.selectedActes
        }
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = SectionHeaderView()
//         let index = sortedActes.startIndex.advancedBy(section)
//        var title = ""
//        switch sortedActes.keys[index] {
//        case "C":
//            title = "Consultation"
//            break
//        case "BDC":
//            title = "Bilan"
//            break
//        case "Z":
//            title = "Radiographie"
//            break
//        case "#REG":
//            title = "Réglement"
//            break
//        case "#COM":
//            title = "A faire "
//            break
//        case "#FSE":
//            title = "Création FSE"
//            break
//        case "#DOC":
//            title = "Création document"
//            break
//        case "#MDT":
//            title = "Traçabilité"
//            break
//        default :
//            title = sortedActes.keys[index]
//            break
//        }
//        view.titleLabel.text = title
//        return view
//    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        DispatchQueue.main.async(execute: {
            self.lesActes = Actes.actesWithJSON(resultsArr)
            //self.sortedActes = Actes.sortInDict(self.lesActes)
            self.actesTableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let a = self.refreshControl {
                if a.isRefreshing {
                    a.endRefreshing()
                }
            }
        })
    }
    
    func handleRefresh(_ refreshControl:UIRefreshControl){
        api!.sendRequest("SELECT * FROM actes WHERE idpatient = \(patient!.id) ORDER BY date DESC")
        
    }
    
    func handleError(_ results: Int) {
        if results == 1{
            
            api!.sendRequest("SELECT * FROM actes WHERE idpatient = \(patient!.id) ORDER BY date DESC")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    @IBAction func newNoteAtion(_ sender: AnyObject) {
        selectedActes = Actes()
        selectedActes.lettre = "#COM"
        selectedActes.idPatient = patient?.id ?? 0
        selectedActes.date = ToolBox.getFormatedDate(Date())
        performSegue(withIdentifier: "showNotesSegue", sender: self)
    }

    @IBAction func newTodoAction(_ sender: AnyObject) {
        selectedActes = Actes()
        selectedActes.lettre = "#TODO"
        selectedActes.idPatient = patient?.id ?? 0
        selectedActes.date = ToolBox.getFormatedDate(Date())
        performSegue(withIdentifier: "showNotesSegue", sender: self)
    }
    
    //qldelegate
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int{
        return 1
        
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        var idr:Int = 0
        //var selectedDocument = api!.getRadioFromUrl(idr)
        var fileType = ""
        var nom = ""
        idr = lesActes[tableView.indexPathForSelectedRow!.row].idDocument
        nom = lesActes[tableView.indexPathForSelectedRow!.row].descriptif
        nom = nom.replace("/", withString: "-")
        fileType = "pdf"
        let doc = api!.getUrlFromDocument(idr)
        let path = APIController.loadFileSync(doc,fileType: fileType, nom: nom, id: idr, completion:{(path:String, error:NSError!) in })
        return path as QLPreviewItem
    }
}
