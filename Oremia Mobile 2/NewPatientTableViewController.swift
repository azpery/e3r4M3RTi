//
//  NewPatientTableViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 01/10/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class NewPatientTableViewController: UITableViewController, UIPickerViewDelegate, APIControllerProtocol {
    var api:APIController?
    var hazards = ["", "Monsieur","Madame", "Mademoiselle", "Enfant"]
    var pickerView1: UIPickerView!
    var dateNpicker: UIDatePicker!
    var parents :  DetailsViewController?
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
        dateNpicker.datePickerMode = UIDatePickerMode.date
        dateNpicker.addTarget(self, action: #selector(NewPatientTableViewController.dateNPickerChanged(_:)), for: UIControlEvents.valueChanged)
        pickerView1.delegate = self
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        let item = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewPatientTableViewController.doneAction))
        item.title = "OK"
        toolbar.setItems([item], animated: true)
        c.inputView = pickerView1
        c.inputAccessoryView = toolbar
        dn.inputView = dateNpicker
        dn.inputAccessoryView = toolbar
        if(!fromCal){
            let ni = UIBarButtonItem.init(title: "Annuler",style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewPatientTableViewController.dismissView(_:)))
            self.navigationItem.leftBarButtonItem = ni
        }
        
        let nav = self.navigationController as? NewPatientNavigationController
        
        self.parents = nav?.parents
    }
    @IBAction func dismissView(_ sender: AnyObject) {
        if self.fromCal{
            self.navigationController?.popToRootViewController(animated: true)
        }else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func register(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/M/yyyy"
        let date = Date()
        let daten = dateFormatter.date(from: dn.text!)
        let genre = pickerView1.selectedRow(inComponent: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        api!.sendRequest("INSERT INTO patients( id, nir, genre, nom, prenom, adresse, codepostal, ville, telephone1, telephone2, email, naissance, creation, idpraticien, idphoto, info, autorise_sms, correspondant, ipp2, adresse2, patient_par, amc, amc_prefs, profession, correspondants, statut, famille, tel1_info, tel2_info)VALUES (DEFAULT, DEFAULT, \(genre), '\(nom.text!.uppercased())', '\(prenom.text!.uppercased())', '\(a1.text!.uppercased())', '\(cp.text!)', '\(ville.text!.uppercased())', '\(telf.text!)', DEFAULT, DEFAULT, '\(dateFormatter.string(from: daten ?? date))', '\(dateFormatter.string(from: date))', \(preference.idUser), DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) RETURNING id;")
    }
    func dateNPickerChanged(_ datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: datePicker.date)
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
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            return hazards.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pt = pickerView.tag
        if pt == 0{
            
            return hazards[row]
        }
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0{
            c.text = hazards[row]
        }
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        DispatchQueue.main.async(execute: {
            if resultsArr.count != 0  && self.parent != nil {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showSuccess("Patient ajouté", subTitle: "Le nouveau patient a été ajouté avec succès.")
                self.parents!.tracks = []
                self.parents!.api.sendRequest("select * from patients where idpraticien=\(preference.idUser) ORDER BY id DESC LIMIT 10 OFFSET 0 ")
                self.dismiss(animated: true, completion: {})
                
            } else {
                if !self.fromCal{
                    let alert = SCLAlertView()
                    alert.showCloseButton = false
                    alert.addButton("Ok", action:{})
                    alert.showError("Erreur", subTitle: "Une erreur a survenu lors de l'ajout de . \n Veuillez vérifié les champs rentrés")
                }else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/M/yyyy"
                    let date = Date()
                    let daten = dateFormatter.date(from: self.dn.text!)
                    let r = resultsArr[0] as? NSDictionary
                    let patient = patients.init(id: r?["id"] as! Int, idP: 0, nom: self.nom.text!.uppercased(), prenom: self.prenom.text!.uppercased(), civilite: self.pickerView1.selectedRow(inComponent: 0), adresse: self.a1.text!.uppercased(), codePostal: self.cp.text!, ville: self.ville.text!.uppercased(), tel1: self.telf.text!, tel2: "", email: "", dn: dateFormatter.string(from: daten ?? date), sms: false, profession: "", statut: 0, ids: "", datec: dateFormatter.string(from: date), numss: "" , info: "")
                    self.cal?.patientText.text = ""+self.prenom.text!.lowercased().capitalized+" "+self.nom.text!.lowercased().capitalized
                    self.cal!.eventManager.internalEvent.idPatient = r?["id"] as! Int
                    self.cal!.eventManager.internalEvent.patient = patient
                    self.cal!.eventManager.editEvent?.title = (self.cal?.patientText.text) ?? "Nouveau rendez-vous"
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        })
        
    }
    func handleError(_ results: Int) {
        if results == 1{
            DispatchQueue.main.async(execute: {
                SCLAlertView().showError("Serveur introuvable", subTitle: "Veuillez rentrer une adresse ip de serveur correct", closeButtonTitle:"Fermer")
            })
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}
