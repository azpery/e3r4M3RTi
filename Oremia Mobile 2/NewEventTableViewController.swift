//
//  NewEventTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 14/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class NewEventTableViewController: UITableViewController  {

    @IBOutlet weak var patientText: UILabel!
    @IBOutlet var calendrier: UILabel!
    var eventManager = EventManager()
    var caller:MSCalendarViewController?
    var cell:MSEventCell?
    var initialDate:NSDate?
    @IBOutlet var rightArrow: UILabel!
    @IBOutlet var alerte: UISwitch!
    @IBOutlet var notes: UITextView!
    @IBOutlet var dateDebut: UIDatePicker!
    @IBOutlet var dateFin: UIDatePicker!
    @IBOutlet var delete: UIButton!
    @IBOutlet var dateDebutLabel: UILabel!
    @IBOutlet var dateFinLabel: UILabel!
    var dateFormatter = NSDateFormatter()
    var dateDebutPicker = false
    var dateFinPicker = false
    @IBOutlet var rightArrowBis: UILabel!
    @IBOutlet var statutLabel: UILabel!
    @IBOutlet var typeRDV: UILabel!
    @IBOutlet var addPatientButton: UIButton!
    @IBOutlet var consulterDossier: UIButton!
    @IBOutlet var image: UIImageView!
    var tryed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMe()
    }
    
    func loadMe(){
        consulterDossier.hidden = true
        eventManager.selectedCalendarIdentifier = eventManager.defaultCalendar?.title
        calendrier.text = eventManager.defaultCalendar?.title
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        rightArrow.setFAIcon(FAType.FAArrowRight, iconSize: 17)
        rightArrow.tintColor = UIColor.whiteColor()
        rightArrowBis.setFAIcon(FAType.FAArrowRight, iconSize: 17)
        rightArrowBis.tintColor = UIColor.whiteColor()
        addPatientButton.setFAIcon(FAType.FAPlusCircle, forState: UIControlState.Normal)
        if self.eventManager.internalEvent.patient != nil{
            consulterDossier.hidden = false
            consulterDossier.setFAIcon(FAType.FAFolder, forState: UIControlState.Normal)
            loadPhoto()
        } else {
            if(!tryed){
                self.tryed = true
                self.eventManager.internalEvent.loadPatient(loadMe)
                consulterDossier.hidden = true
                consulterDossier.titleLabel?.text = ""
            }
        }
        if eventManager.editEvent != nil {
            patientText.text = eventManager.editEvent?.title
            calendrier.text = eventManager.editEvent?.calendar.title
            dateDebut.date = (eventManager.editEvent?.startDate)!
            self.initialDate = eventManager.editEvent?.startDate
            dateFin.date = (eventManager.editEvent?.endDate)!
            notes.text = eventManager.editEvent?.notes
            self.navigationItem.title = "Modifier l'évennement"
            self.navigationItem.rightBarButtonItem?.title = "Modifier"
            self.navigationItem.rightBarButtonItem?.target = self
            self.navigationItem.rightBarButtonItem?.action = Selector("editEvent")
            dateDebutLabel.text = dateFormatter.stringFromDate((eventManager.editEvent?.startDate)!)
            dateFinLabel.text = dateFormatter.stringFromDate((eventManager.editEvent?.endDate)!)
            typeRDV.text = eventManager.internalEvent.descriptionModele == "" ? "Modifier le type de rendez-vous" : eventManager.internalEvent.descriptionModele
            self.tableView.reloadData()
        } else {
            delete.removeFromSuperview()
        }
        delete.addTarget(self, action: Selector("deleteEvent"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    func loadPhoto(){
        image.layer.cornerRadius = image.frame.size.width / 2;
        image.clipsToBounds = true
        image.layer.borderWidth = 0.5
        image.layer.borderColor = UIColor.whiteColor().CGColor
        image.contentMode = .ScaleAspectFit
        let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
        let urlString = NSURL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+image+from+images+where+id=\(self.eventManager.internalEvent.patient!.idPhoto)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)
        progressIndicatorView.frame = image.bounds
        progressIndicatorView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        dispatch_async(dispatch_get_main_queue(), {
//            self.image.addSubview(progressIndicatorView)
            self.image.sd_setImageWithURL(urlString, placeholderImage: nil, options: .CacheMemoryOnly, progress: {
                (receivedSize, expectedSize) -> Void in
                    progressIndicatorView.progress = CGFloat(receivedSize)/CGFloat(expectedSize)
                }) {
                    (image, error, _, _) -> Void in
                    self.image.image = image
//                    progressIndicatorView.reveal()
//                    progressIndicatorView.removeFromSuperview()
            }
        })
    }
    override func viewDidAppear(animated: Bool) {
        loadMe()
        if self.eventManager.internalEvent.patient != nil{
            consulterDossier.setFAIcon(FAType.FAFolder, forState: UIControlState.Normal)
            loadPhoto()
        } else {
            consulterDossier.titleLabel?.text = ""
        }
    }
    override func viewDidDisappear(animated: Bool) {
        self.tryed = false
    }
    @IBAction func dateDebutChanged(sender: UIDatePicker) {
        dateDebutLabel.text = dateFormatter.stringFromDate(sender.date)
        dateFin.date = sender.date.dateByAddingTimeInterval(60*30)
        dateFinLabel.text = dateFormatter.stringFromDate(dateFin.date)
    }

    @IBAction func dateFinChanged(sender: UIDatePicker) {
        dateFinLabel.text = dateFormatter.stringFromDate(sender.date)
//        dateDebut.date = sender.date.dateByAddingTimeInterval(60*30)
//        dateDebutLabel.text = dateFormatter.stringFromDate(dateDebut.date)
    }
    func majDuree(duree:Double){
        dateFin.date = dateDebut.date.dateByAddingTimeInterval(60*duree)
        dateFinLabel.text = dateFormatter.stringFromDate(dateFin.date)
    }
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: ({}))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(CalendarsTableViewController){
            let destination = segue.destinationViewController as! CalendarsTableViewController
            destination.caller = self
            destination.eventManager = eventManager
        }
        if segue.destinationViewController.isKindOfClass(StatutTableViewController){
            let destination = segue.destinationViewController as! StatutTableViewController
            destination.eventManager = eventManager
            destination.label = statutLabel
        }
        if segue.destinationViewController.isKindOfClass(TypeRDVTableViewController){
            let destination = segue.destinationViewController as! TypeRDVTableViewController
            destination.eventManager = eventManager
            destination.label = typeRDV
            destination.caller = self
        }
        if segue.destinationViewController.isKindOfClass(TabBarViewController){
            let detailsViewController: TabBarViewController = segue.destinationViewController as! TabBarViewController
            detailsViewController.patient = self.eventManager.internalEvent.patient
            detailsViewController.fromCal = true
        }
        if segue.destinationViewController.isKindOfClass(NewPatientTableViewController){
            let detailsViewController: NewPatientTableViewController = segue.destinationViewController as! NewPatientTableViewController
            detailsViewController.fromCal = true
            detailsViewController.cal = self
        }
        
    }
    func deleteEvent() {
        if eventManager.deleteEvent(){
            SCLAlertView().showSuccess("Rendez-vous supprimé", subTitle: "Le rendez vous a été supprimé", closeButtonTitle: "OK")
        }else {
            let alert = SCLAlertView()
            alert.showError("Erreur", subTitle: "Suppression impossible, cette évennement est en lecture seule", closeButtonTitle: "OK")
        }
        self.dismissViewControllerAnimated(true, completion: ({
            self.caller?.reloadItMotherFucker()
        }))
    }
    func editEvent() {
        let startDate = dateDebut.date
        let endDate = dateFin.date
        eventManager.selectedCalendarIdentifier = calendrier.text
        if (startDate.compare(endDate) == .OrderedAscending && patientText.text! != "Cliquez pour séléctionner le patient" && eventManager.editEvent?.calendar != nil) {
            if eventManager.editEvent(patientText.text!, startDate: startDate, endDate: endDate, notes: notes.text, reminder: alerte.on, initialDate:self.initialDate) {
                let dateFormat = NSDateFormatter()
                dateFormat.dateStyle = .FullStyle
                dateFormat.timeStyle = .MediumStyle
                SCLAlertView().showSuccess("Rendez-vous modifié", subTitle: "Le rendez vous a été modifié pour le \(dateFormat.stringFromDate(startDate).capitalizedString)", closeButtonTitle: "OK")
            }else{
                let alert = SCLAlertView()
                alert.addButton("Besoin d'aide?") {
                    let popoverContent = (self.storyboard?.instantiateViewControllerWithIdentifier("Help"))! as UIViewController
                    let nav = UINavigationController(rootViewController: popoverContent)
                    nav.modalPresentationStyle = UIModalPresentationStyle.PageSheet
                    self.presentViewController(nav, animated: true, completion: nil)
                }
                
                alert.showError("Erreur", subTitle: "Il y a eu un probleme lors de l'enregistrement du rendez-vous, si le probleme persiste, contactez le support technique.", closeButtonTitle: "OK")
            }
            self.dismissViewControllerAnimated(true, completion: ({
                self.eventManager.agenda = self.caller
                let mabite = self.eventManager.editEvent!.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
//                self.eventManager.CalDavRessource[mabite[1]] = "X-ORE-IPP=%\(eventManager.internalEvent.patient?.id)"
                self.tryed = false
                self.caller?.reloadItMotherFucker()
            }))
        } else {
            ToolBox.shakeIt(self.view)
        }
    }
    @IBAction func addNewpatient(sender: AnyObject) {
        performSegueWithIdentifier("ajouterPatient", sender: self)
    }
    @IBAction func addNewEvent(sender: AnyObject) {
        let startDate = dateDebut.date
        let endDate = dateFin.date
        if (startDate.compare(endDate) == .OrderedAscending && patientText.text! != "Cliquez pour séléctionner le patient" && eventManager.selectedCalendarIdentifier != nil) {
            if eventManager.insertEvent(patientText.text!, startDate: startDate, endDate: endDate, notes: notes.text, reminder: alerte.on) {
                let dateFormat = NSDateFormatter()
                dateFormat.dateStyle = .FullStyle
                dateFormat.timeStyle = .MediumStyle
                SCLAlertView().showSuccess("Rendez-vous enregistré", subTitle: "Le rendez vous a été enregistré pour le \(dateFormat.stringFromDate(startDate).capitalizedString)", closeButtonTitle: "OK")
            }else{
                let alert = SCLAlertView()
                alert.addButton("Besoin d'aide?") {
                    let popoverContent = (self.storyboard?.instantiateViewControllerWithIdentifier("Help"))! as UIViewController
                    let nav = UINavigationController(rootViewController: popoverContent)
                    nav.modalPresentationStyle = UIModalPresentationStyle.PageSheet
                    self.presentViewController(nav, animated: true, completion: nil)
                }
                
                alert.showError("Erreur", subTitle: "Il y a eu un probleme lors de l'enregistrement du rendez-vous, si le probleme persiste, contactez le support technique.", closeButtonTitle: "OK")
            }
            self.dismissViewControllerAnimated(true, completion: ({
                self.caller?.reloadItMotherFucker()
            }))
        } else {
            ToolBox.shakeIt(self.view)
        }
    }

     func performSelectionPatient() {
            let selectionPatient = self.storyboard!.instantiateViewControllerWithIdentifier("DetailsViewController") as! DetailsViewController
            selectionPatient.isSelectingPatient = true
            selectionPatient.patientText = patientText
            selectionPatient.eventManager = eventManager
            self.showViewController(selectionPatient, sender: self)
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row{
        case 1 :
            
            performSelectionPatient()
            break
        case 2:
            dateDebutPicker = !dateDebutPicker
            dateFinPicker = false
//            let cell = NSIndexPath(forRow: 2, inSection: 0)
//            self.tableView.reloadRowsAtIndexPaths([cell], withRowAnimation: UITableViewRowAnimation.Fade)
//            self.tableView.reloadData()
            tableView.beginUpdates()
            tableView.endUpdates()
            break
        case 4:
            dateFinPicker = !dateFinPicker
            dateDebutPicker = false
//            let cell = NSIndexPath(forRow: 4, inSection: 0)
//            self.tableView.reloadRowsAtIndexPaths([cell], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.beginUpdates()
            tableView.endUpdates()
//            self.tableView.reloadData()
            break
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 && self.eventManager.internalEvent.patient == nil || self.eventManager.internalEvent.patient?.idPhoto == 0 && indexPath.row == 0{
            return 0.0
        }else if indexPath.row == 0{
            return 66.0
        }
        if indexPath.row == 3 {
            if dateDebutPicker == false {
                return 0.0
            }
            return 154.0
        }
        if indexPath.row == 5 {
            if dateFinPicker == false {
                return 0.0
            }
            return 154.0
        }
        if indexPath.row == 10 {
            
            return 125.0
        }
        return 43.0

    }


}
