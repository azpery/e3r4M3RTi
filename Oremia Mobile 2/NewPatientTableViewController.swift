//
//  NewPatientTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 01/10/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class NewPatientTableViewController: UITableViewController, UIPickerViewDelegate, APIControllerProtocol {
    var api = APIController?()
    var hazards = ["", "Monsieur","Madame", "Mademoiselle", "Enfant"]
    var pickerView1: UIPickerView!
    var dateNpicker: UIDatePicker!
    var parent :  DetailsViewController?
    var cal: NewEventTableViewController?
    @IBOutlet weak var c: UITextField!
    @IBOutlet weak var nom: UITextField!
    @IBOutlet weak var prenom: UITextField!
    @IBOutlet weak var dn: UITextField!
    @IBOutlet weak var a1: UITextField!
    @IBOutlet weak var cp: UITextField!
    @IBOutlet weak var ville: UITextField!
    @IBOutlet weak var telf: UITextField!
    var fromCal = false
    override func viewDidLoad() {
        super.viewDidLoad()
        api = APIController(delegate: self)
        pickerView1 = UIPickerView()
        pickerView1.tag = 0
        dateNpicker = UIDatePicker()
        dateNpicker = UIDatePicker()
        dateNpicker.datePickerMode = UIDatePickerMode.Date
        dateNpicker.addTarget(self, action: Selector("dateNPickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        pickerView1.delegate = self
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.size.width, 44))
        let item = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.Plain, target: self, action: "doneAction")
        item.title = "OK"
        toolbar.setItems([item], animated: true)
        c.inputView = pickerView1
        c.inputAccessoryView = toolbar
        dn.inputView = dateNpicker
        dn.inputAccessoryView = toolbar
        if(!fromCal){
            let ni = UIBarButtonItem.init(title: "Annuler",style: UIBarButtonItemStyle.Plain, target: self, action: Selector("dismissView:"))
            self.navigationItem.leftBarButtonItem = ni
        }
        
        let nav = self.navigationController as? NewPatientNavigationController
        
        self.parent = nav?.parent
    }
    @IBAction func dismissView(sender: AnyObject) {
        if self.fromCal{
            self.navigationController?.popToRootViewControllerAnimated(true)
        }else {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    @IBAction func register(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/M/yyyy"
        let date = NSDate()
        let daten = dateFormatter.dateFromString(dn.text!)
        let genre = pickerView1.selectedRowInComponent(0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        api!.sendRequest("INSERT INTO patients( id, nir, genre, nom, prenom, adresse, codepostal, ville, telephone1, telephone2, email, naissance, creation, idpraticien, idphoto, info, autorise_sms, correspondant, ipp2, adresse2, patient_par, amc, amc_prefs, profession, correspondants, statut, famille, tel1_info, tel2_info)VALUES (DEFAULT, DEFAULT, \(genre), '\(nom.text!.uppercaseString)', '\(prenom.text!.uppercaseString)', '\(a1.text!.uppercaseString)', '\(cp.text!)', '\(ville.text!.uppercaseString)', '\(telf.text!)', DEFAULT, DEFAULT, '\(dateFormatter.stringFromDate(daten ?? date))', '\(dateFormatter.stringFromDate(date))', \(preference.idUser), DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) RETURNING id;")
    }
    func dateNPickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        dn.text = strDate
    }
    func doneAction() {
        self.c.resignFirstResponder()
        self.dn.resignFirstResponder()
        print("done!")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            return hazards.count
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pt = pickerView.tag
        if pt == 0{
            
            return hazards[row]
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0{
            c.text = hazards[row]
        }
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            if resultsArr.count != 0  && self.parent != nil {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showSuccess("Patient ajouté", subTitle: "Le nouveau patient a été ajouté avec succès.")
                self.parent!.tracks = []
                self.parent!.api.sendRequest("select * from patients where idpraticien=\(preference.idUser) ORDER BY id DESC LIMIT 10 OFFSET 0 ")
                self.dismissViewControllerAnimated(true, completion: {})
                
            } else {
                if !self.fromCal{
                    let alert = SCLAlertView()
                    alert.showCloseButton = false
                    alert.addButton("Ok", action:{})
                    alert.showError("Erreur", subTitle: "Une erreur a survenu lors de l'ajout de . \n Veuillez vérifié les champs rentrés")
                }else {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd/M/yyyy"
                    let date = NSDate()
                    let daten = dateFormatter.dateFromString(self.dn.text!)
                    
                    let patient = patients.init(id: resultsArr[0]["id"] as! Int, idP: 0, nom: self.nom.text!.uppercaseString, prenom: self.prenom.text!.uppercaseString, civilite: self.pickerView1.selectedRowInComponent(0), adresse: self.a1.text!.uppercaseString, codePostal: self.cp.text!, ville: self.ville.text!.uppercaseString, tel1: self.telf.text!, tel2: "", email: "", dn: dateFormatter.stringFromDate(daten ?? date), sms: false, profession: "", statut: 0, ids: "", datec: dateFormatter.stringFromDate(date), numss: "" , info: "")
                    self.cal?.patientText.text = ""+self.prenom.text!.lowercaseString.capitalizedString+" "+self.nom.text!.lowercaseString.capitalizedString
                    self.cal!.eventManager.internalEvent.idPatient = resultsArr[0]["id"] as! Int
                    self.cal!.eventManager.internalEvent.patient = patient
                    self.cal!.eventManager.editEvent?.title = (self.cal?.patientText.text) ?? "Nouveau rendez-vous"
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        })
        
    }
    func handleError(results: Int) {
        if results == 1{
            dispatch_async(dispatch_get_main_queue(), {
                SCLAlertView().showError("Serveur introuvable", subTitle: "Veuillez rentrer une adresse ip de serveur correct", closeButtonTitle:"Fermer")
            })
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
}
