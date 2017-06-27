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
    var initialDate:Date?
    @IBOutlet var rightArrow: UILabel!
    @IBOutlet var alerte: UISwitch!
    @IBOutlet var notes: UITextView!
    @IBOutlet var dateDebut: UIDatePicker!
    @IBOutlet var dateFin: UIDatePicker!
    @IBOutlet var delete: UIButton!
    @IBOutlet var dateDebutLabel: UILabel!
    @IBOutlet var dateFinLabel: UILabel!
    var dateFormatter = DateFormatter()
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
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short

    }
    
    func loadEvent(){
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
            self.navigationItem.rightBarButtonItem?.action = #selector(NewEventTableViewController.editEvent)
            dateDebutLabel.text = dateFormatter.string(from: (eventManager.editEvent?.startDate)!)
            dateFinLabel.text = dateFormatter.string(from: (eventManager.editEvent?.endDate)!)
            typeRDV.text = eventManager.internalEvent.descriptionModele == "" ? "Modifier le type de rendez-vous" : eventManager.internalEvent.descriptionModele
            statutLabel.text = eventManager.internalEvent.getLibelleStatut()
            self.tableView.reloadData()
        } else {
            delete.removeFromSuperview()
        }
    }
    
    func loadMe(){
        consulterDossier.isHidden = true
        eventManager.selectedCalendarIdentifier = eventManager.defaultCalendar?.title
        calendrier.text = eventManager.defaultCalendar?.title
        rightArrow.setFAIcon(FAType.faArrowRight, iconSize: 17)
        rightArrow.tintColor = UIColor.white
        rightArrowBis.setFAIcon(FAType.faArrowRight, iconSize: 17)
        rightArrowBis.tintColor = UIColor.white
        addPatientButton.setFAIcon(FAType.faPlusCircle, forState: UIControlState())
        if self.eventManager.internalEvent.patient != nil{
            consulterDossier.isHidden = false
            consulterDossier.setFAIcon(FAType.faFolder, forState: UIControlState())
            loadPhoto()
            self.tableView.reloadData()
        } else {
            if(!tryed){
                self.tryed = true
                self.eventManager.internalEvent.loadPatient(loadMe)
                consulterDossier.isHidden = true
                consulterDossier.titleLabel?.text = ""
            }
        }
        
        delete.addTarget(self, action: #selector(NewEventTableViewController.deleteEvent), for: UIControlEvents.touchUpInside)
    }
    func loadPhoto(){
        image.layer.cornerRadius = image.frame.size.width / 2;
        image.clipsToBounds = true
        image.layer.borderWidth = 0.5
        image.layer.borderColor = UIColor.white.cgColor
        image.contentMode = .scaleAspectFit
        let progressIndicatorView = CircularLoaderView(frame: CGRect.zero)
        let urlString = URL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+image+from+images+where+id=\(self.eventManager.internalEvent.patient!.idPhoto)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)
        progressIndicatorView.frame = image.bounds
        progressIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        DispatchQueue.main.async(execute: {
//            self.image.addSubview(progressIndicatorView)
            self.image.sd_setImage(with: urlString, placeholderImage: nil, options: .cacheMemoryOnly, progress: {
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
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async(execute: {
            self.loadMe()
//        if self.eventManager.internalEvent.patient != nil{
//            self.consulterDossier.setFAIcon(FAType.FAFolder, forState: UIControlState.Normal)
//            self.loadPhoto()
//        } else {
//            self.consulterDossier.titleLabel?.text = ""
//        }
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.tryed = false
    }
    @IBAction func dateDebutChanged(_ sender: UIDatePicker) {
        dateDebutLabel.text = dateFormatter.string(from: sender.date)
        dateFin.date = sender.date.addingTimeInterval(60*30)
        dateFinLabel.text = dateFormatter.string(from: dateFin.date)
    }

    @IBAction func dateFinChanged(_ sender: UIDatePicker) {
        dateFinLabel.text = dateFormatter.string(from: sender.date)
//        dateDebut.date = sender.date.dateByAddingTimeInterval(60*30)
//        dateDebutLabel.text = dateFormatter.stringFromDate(dateDebut.date)
    }
    func majDuree(_ duree:Double){
        dateFin.date = dateDebut.date.addingTimeInterval(60*duree)
        dateFinLabel.text = dateFormatter.string(from: dateFin.date)
    }
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: ({}))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: CalendarsTableViewController.self){
            let destination = segue.destination as! CalendarsTableViewController
            destination.caller = self
            destination.eventManager = eventManager
        }
        if segue.destination.isKind(of: StatutTableViewController.self){
            let destination = segue.destination as! StatutTableViewController
            destination.eventManager = eventManager
            destination.label = statutLabel
        }
        if segue.destination.isKind(of: TypeRDVTableViewController.self){
            let destination = segue.destination as! TypeRDVTableViewController
            destination.eventManager = eventManager
            destination.label = typeRDV
            destination.caller = self
        }
        if segue.destination.isKind(of: TabBarViewController.self){
            let detailsViewController: TabBarViewController = segue.destination as! TabBarViewController
            detailsViewController.patient = self.eventManager.internalEvent.patient
            detailsViewController.fromCal = true
        }
        if segue.destination.isKind(of: NewPatientTableViewController.self){
            let detailsViewController: NewPatientTableViewController = segue.destination as! NewPatientTableViewController
            detailsViewController.fromCal = true
            detailsViewController.cal = self
        }
        
    }
    func deleteEvent() {
        if eventManager.deleteEvent(){
            _ = SCLAlertView().showSuccess("Rendez-vous supprimé", subTitle: "Le rendez vous a été supprimé", closeButtonTitle: "OK")
        }else {
            let alert = SCLAlertView()
            _ = alert.showError("Erreur", subTitle: "Suppression impossible, cette évennement est en lecture seule", closeButtonTitle: "OK")
        }
        self.dismiss(animated: true, completion: ({
            self.caller?.reloadItMotherFucker()
        }))
    }
    func editEvent() {
        let startDate = dateDebut.date
        let endDate = dateFin.date
        eventManager.selectedCalendarIdentifier = calendrier.text
        if (startDate.compare(endDate) == .orderedAscending && patientText.text! != "Cliquez pour séléctionner le patient" && eventManager.editEvent?.calendar != nil) {
            if eventManager.editEvent(patientText.text!, startDate: startDate, endDate: endDate, notes: notes.text, reminder: alerte.isOn, initialDate:self.initialDate) {
                let dateFormat = DateFormatter()
                dateFormat.dateStyle = .full
                dateFormat.timeStyle = .medium
                _ = SCLAlertView().showSuccess("Rendez-vous modifié", subTitle: "Le rendez vous a été modifié pour le \(dateFormat.string(from: startDate).capitalized)", closeButtonTitle: "OK")
            }else{
                let alert = SCLAlertView()
                _ = alert.addButton("Besoin d'aide?") {
                    let popoverContent = (self.storyboard?.instantiateViewController(withIdentifier: "Help"))! as UIViewController
                    let nav = UINavigationController(rootViewController: popoverContent)
                    nav.modalPresentationStyle = UIModalPresentationStyle.pageSheet
                    self.present(nav, animated: true, completion: nil)
                }
                
                _ = alert.showError("Erreur", subTitle: "Il y a eu un probleme lors de l'enregistrement du rendez-vous, si le probleme persiste, contactez le support technique.", closeButtonTitle: "OK")
            }
            self.dismiss(animated: true, completion: ({
                self.eventManager.agenda = self.caller
                _ = self.eventManager.editEvent!.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
//                self.eventManager.CalDavRessource[mabite[1]] = "X-ORE-IPP=%\(eventManager.internalEvent.patient?.id)"
                self.tryed = false
                self.caller?.reloadItMotherFucker()
            }))
        } else {
            ToolBox.shakeIt(self.view)
        }
    }
    @IBAction func addNewpatient(_ sender: AnyObject) {
        performSegue(withIdentifier: "ajouterPatient", sender: self)
    }
    @IBAction func addNewEvent(_ sender: AnyObject) {
        let startDate = dateDebut.date
        let endDate = dateFin.date
        if (startDate.compare(endDate) == .orderedAscending && patientText.text! != "Cliquez pour séléctionner le patient" && eventManager.selectedCalendarIdentifier != nil) {
            if eventManager.insertEvent(patientText.text!, startDate: startDate, endDate: endDate, notes: notes.text, reminder: alerte.isOn) {
                let dateFormat = DateFormatter()
                dateFormat.dateStyle = .full
                dateFormat.timeStyle = .medium
                _ = SCLAlertView().showSuccess("Rendez-vous enregistré", subTitle: "Le rendez vous a été enregistré pour le \(dateFormat.string(from: startDate).capitalized)", closeButtonTitle: "OK")
            }else{
                let alert = SCLAlertView()
                _ = alert.addButton("Besoin d'aide?") {
                    let popoverContent = (self.storyboard?.instantiateViewController(withIdentifier: "Help"))! as UIViewController
                    let nav = UINavigationController(rootViewController: popoverContent)
                    nav.modalPresentationStyle = UIModalPresentationStyle.pageSheet
                    self.present(nav, animated: true, completion: nil)
                }
                
                _ = alert.showError("Erreur", subTitle: "Il y a eu un probleme lors de l'enregistrement du rendez-vous, si le probleme persiste, contactez le support technique.", closeButtonTitle: "OK")
            }
            self.dismiss(animated: true, completion: ({
                self.caller?.reloadItMotherFucker()
            }))
        } else {
            ToolBox.shakeIt(self.view)
        }
    }

     func performSelectionPatient() {
            let selectionPatient = self.storyboard!.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
            selectionPatient.isSelectingPatient = true
            selectionPatient.patientText = patientText
            selectionPatient.eventManager = eventManager
            self.show(selectionPatient, sender: self)
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
