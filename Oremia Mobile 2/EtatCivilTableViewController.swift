
//  EtatCivilTableViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 29/05/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit

class EtatCivilTableViewController: UITableViewController, UIPickerViewDelegate, APIControllerProtocol {
    var p:patients?
    var api = APIController?()
    var hazards = ["", "Monsieur","Madame", "Mademoiselle", "Enfant"]
    var statut = ["Dossier actif", "Dossier archivé"]
    var pickerView1: UIPickerView!
    var pickerView2: UIPickerView!
    var dateNpicker: UIDatePicker!
    var dateCpicker: UIDatePicker!
    @IBOutlet weak var c: UITextField!
    @IBOutlet weak var nom: UITextField!
    @IBOutlet weak var prenom: UITextField!
    @IBOutlet weak var dn: UITextField!
    @IBOutlet weak var a1: UITextField!
    @IBOutlet weak var a2: UITextField!
    @IBOutlet weak var cp: UITextField!
    @IBOutlet weak var ville: UITextField!
    @IBOutlet weak var telf: UITextField!
    @IBOutlet weak var telm: UITextField!
    @IBOutlet weak var sms: AIFlatSwitch!
    @IBOutlet weak var em: UITextField!
    @IBOutlet weak var pr: UITextField!
    @IBOutlet weak var s: KaedeTextField!
    @IBOutlet weak var ids: KaedeTextField!
    @IBOutlet weak var dc: KaedeTextField!
    @IBOutlet weak var nss: KaedeTextField!
    @IBOutlet weak var i: UITextView!
    override func viewDidLoad() {
        initValue()
        self.tableView.scrollsToTop = true
        super.viewDidLoad()
        api = APIController(delegate: self)
        
        
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    override func viewDidDisappear(animated: Bool){
        
    }
    func initValue(){
        pickerView1 = UIPickerView()
        pickerView1.tag = 0
        pickerView2 = UIPickerView()
        pickerView2.tag = 1
        pickerView1.reloadInputViews()
        dateNpicker = UIDatePicker()
        dateCpicker = UIDatePicker()
        dateNpicker.datePickerMode = UIDatePickerMode.Date
        dateCpicker.datePickerMode = UIDatePickerMode.Date
        dateNpicker.addTarget(self, action: Selector("dateNPickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        dateCpicker.addTarget(self, action: Selector("dateCPickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let daten = dateFormatter.dateFromString(p!.dateNaissance)
        let datec = dateFormatter.dateFromString(p!.datec)
        let date = NSDate()
        let gbDateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy-MM-dd", options: 0, locale: NSLocale(localeIdentifier: "fr-FR"))
        dateFormatter.dateFormat = gbDateFormat
        pickerView1.delegate = self
        pickerView2.delegate = self
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.size.width, 44))
        let item = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.Plain, target: self, action: "doneAction")
        item.title = "OK"
        toolbar.setItems([item], animated: true)
        c.text = hazards[p!.civilite]
        c.inputView = pickerView1
        c.inputAccessoryView = toolbar
        nom.text = p!.nom.capitalizedString
        prenom.text = p!.prenom.capitalizedString
        dn.text = dateFormatter.stringFromDate(daten ?? date)
        dn.inputView = dateNpicker
        dn.inputAccessoryView = toolbar
        a1.text = p!.adresse.capitalizedString
        cp.text = p!.codePostal
        ville.text = p!.ville.capitalizedString
        telf.text = p!.telephone1
        telm.text = p!.telephone2
        sms.selected = p!.autoSMS
        pr.text = p!.profession.capitalizedString
        em.text = p!.email
        s.text = statut[p!.statut]
        s.inputView = pickerView2
        s.inputAccessoryView = toolbar
        ids.text = p!.ids
        dc.text = dateFormatter.stringFromDate(datec ?? date)
        dc.inputView = dateCpicker
        dc.inputAccessoryView = toolbar
        nss.text = p!.numss
        i.text = p!.info
    }
    func editPatient(){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/M/yyyy"
        let daten = dateFormatter.dateFromString(dn.text!)
        let datec = dateFormatter.dateFromString(dc.text!)
        var genre = pickerView1.selectedRowInComponent(0)
        let statut = pickerView2.selectedRowInComponent(0)
        if  genre == 0 { genre = p!.civilite }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        api!.sendRequest("UPDATE patients SET nir='\(nss.text!)', genre=\(genre), nom='\(nom.text!.uppercaseString)', prenom='\(prenom.text!.uppercaseString)', adresse='\(a1.text!.uppercaseString)', codepostal='\(cp.text!)', ville='\(ville.text!.uppercaseString)', telephone1='\(telf.text!)', telephone2='\(telm.text!)', email='\(em.text!)', naissance='\(dateFormatter.stringFromDate(daten!))', creation='\(dateFormatter.stringFromDate(datec!))', info='\(i.text!)', autorise_sms=\(sms.selected), ipp2='\(ids.text!)',  profession='\(pr.text!)', statut=\(statut) WHERE id =\(p!.id);")
        p!.civilite = pickerView1.selectedRowInComponent(0)
        p!.nom = (nom.text?.uppercaseString)!
        p!.prenom = (prenom.text?.uppercaseString)!
        p!.dateNaissance = dateFormatter.stringFromDate(daten!)
        p!.adresse = (a1.text?.uppercaseString)!
        p!.codePostal = cp.text!
        p!.ville = (ville.text?.uppercaseString)!
        p!.telephone1 = telf.text!
        p!.telephone2 = telm.text!
        p!.autoSMS = sms.selected
        p!.profession = pr.text!
        p!.email = em.text!
        p!.statut = statut
        p!.ids = ids.text!
        p!.datec = dateFormatter.stringFromDate(datec!)
        p!.numss = nss.text!
        p!.info = i.text!
    }
    
    func dateNPickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        dn.text = strDate
    }
    func dateCPickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        dc.text = strDate
    }
    func doneAction() {
        self.c.resignFirstResponder()
        self.s.resignFirstResponder()
        self.dn.resignFirstResponder()
        self.dc.resignFirstResponder()
        print("done!")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func showpicker(sender:UITextField!){
        performSegueWithIdentifier("showpicker", sender: self)
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         if pickerView.tag == 0{
        return hazards.count
        } else  if pickerView.tag == 1{
        return statut.count
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
            if row == hazards.count {
                pickerView1.selectRow(p!.civilite, inComponent: 0, animated: true)
            }
            return hazards[row]
        } else if pickerView.tag == 1{
            if row == statut.count {
                pickerView2.selectRow(p!.statut, inComponent: 0, animated: true)
            }
            return statut[row]
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0{
            c.text = hazards[row]
        } else if pickerView.tag == 1{
            s.text = statut[row]
        }
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            if resultsArr.count != 0 && resultsArr[0].count  == 0  {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showSuccess("Patient modifé", subTitle: "\(self.p!.prenom.capitalizedString) a été modifié avec succès.")
            } else {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showError("Erreur", subTitle: "Une erreur a survenu lors de la modification de \(self.p!.prenom.capitalizedString). \n Veuillez vérifier les champs rentrés")
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
