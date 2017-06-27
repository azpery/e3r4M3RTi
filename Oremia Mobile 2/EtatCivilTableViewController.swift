
//  EtatCivilTableViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 29/05/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit

class EtatCivilTableViewController: UITableViewController, UIPickerViewDelegate, APIControllerProtocol, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate {

    var patient:patients?
    var p:patients?
    var api:APIController?
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
    @IBOutlet weak var s: UITextField!
    @IBOutlet weak var ids: UITextField!
    @IBOutlet weak var dc: UITextField!
    @IBOutlet weak var nss: UITextField!
    @IBOutlet weak var i: UITextView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet weak var validButton: UIBarButtonItem!
    var cameraUI:UIImagePickerController = UIImagePickerController()
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var buttonValider: UIBarButtonItem!

    override func viewDidLoad() {
        
        self.tableView.scrollsToTop = true
        super.viewDidLoad()
        api = APIController(delegate: self)
        let tb : TabBarViewController = self.tabBarController as! TabBarViewController
        patient = tb.patient!
        p = patient
        initValue()
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "\(title.title!) -  Dr \(preference.nomUser) - \(patient!.nom) \(patient!.prenom.capitalized)"
        if profilePicture != nil {
            
            profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
            profilePicture.clipsToBounds = true
            profilePicture.layer.borderWidth = 0.5
            profilePicture.layer.borderColor = UIColor.white.cgColor
            profilePicture.contentMode = .scaleAspectFill
            let progressIndicatorView = CircularLoaderView(frame: CGRect.zero)
            progressIndicatorView.frame = self.profilePicture.bounds
            progressIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.profilePicture.addSubview(progressIndicatorView)
            var alreadyLoad = true
            let urlString = URL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+image+from+images+where+id=\(patient!.idPhoto)&&db=zuma&&login=zm\(preference.idUser)&&pw=\(preference.password)")
            DispatchQueue.main.async(execute: {
                self.profilePicture.sd_setImage(with: urlString, placeholderImage: nil, options: .cacheMemoryOnly, progress: {
                    (receivedSize, expectedSize) -> Void in
                    alreadyLoad = false
                    progressIndicatorView.progress = CGFloat(receivedSize)/CGFloat(expectedSize)
                }) {
                    (image, error, _, _) -> Void in
                    if !alreadyLoad {
                        progressIndicatorView.reveal()
                    } else {
                        progressIndicatorView.removeFromSuperview()
                    }
                    
                }
            })
            photoButton.setFAIcon(FAType.faCamera, forState: UIControlState())
            chooseButton.setFAIcon(FAType.faPictureO, forState: UIControlState())
            menuButton.setFAIcon(FAType.faSearch, iconSize: 24)
            quitButton.setFAIcon(FAType.faTimes, iconSize: 24)
            validButton.setFAIcon(FAType.faCheck, iconSize: 24)

        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if ( patient!.info != ""){
            
            var info = patient!.info.components(separatedBy: "!")
            var infoParsed = ""
            for i in (1 ..< info.count){
                infoParsed += info[i]
                if i<info.count - 1 {infoParsed += "\n"}
            }
            if infoParsed != ""{
                let banner = Banner(title: "Informations patient", subtitle: infoParsed, image: UIImage(named: "glyphicons_078_warning_sign"), backgroundColor: ToolBox.UIColorFromRGB(0xf39c12))
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }
            
            
        }
        
    }
    @IBAction func Valider(_ sender: AnyObject) {
        let alert = SCLAlertView()
        alert.addButton("Valider", action:{
            self.editPatient()
        })
        alert.showWarning("Confirmation", subTitle: "Êtes-vous sur de vouloir modifier \(patient!.prenom)", closeButtonTitle:"Annuler")
    }
    @IBAction func prendrePhoto(_ sender: AnyObject) {
        self.presentCamera()
    }
    @IBAction func choisirPhoto(_ sender: AnyObject) {
        self.presentGallery()
    }
    override func viewDidDisappear(_ animated: Bool){
        
    }
    func initValue(){
        pickerView1 = UIPickerView()
        pickerView1.tag = 0
        pickerView2 = UIPickerView()
        pickerView2.tag = 1
        pickerView1.reloadInputViews()
        dateNpicker = UIDatePicker()
        dateCpicker = UIDatePicker()
        dateNpicker.datePickerMode = UIDatePickerMode.date
        dateCpicker.datePickerMode = UIDatePickerMode.date
        dateNpicker.addTarget(self, action: #selector(EtatCivilTableViewController.dateNPickerChanged(_:)), for: UIControlEvents.valueChanged)
        dateCpicker.addTarget(self, action: #selector(EtatCivilTableViewController.dateCPickerChanged(_:)), for: UIControlEvents.valueChanged)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let daten = dateFormatter.date(from: p!.dateNaissance)
        let datec = dateFormatter.date(from: p!.datec)
        let date = Date()
        let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: Locale(identifier: "fr-FR"))
        dateFormatter.dateFormat = gbDateFormat
        pickerView1.delegate = self
        pickerView2.delegate = self
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        let item = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EtatCivilTableViewController.doneAction))
        item.title = "OK"
        toolbar.setItems([item], animated: true)
        c.text = hazards[p!.civilite]
        c.inputView = pickerView1
        c.inputAccessoryView = toolbar
        nom.text = p!.nom.capitalized
        prenom.text = p!.prenom.capitalized
        dn.text = dateFormatter.string(from: daten ?? date)
        dn.inputView = dateNpicker
        dn.inputAccessoryView = toolbar
        a1.text = p!.adresse.capitalized
        cp.text = p!.codePostal
        ville.text = p!.ville.capitalized
        telf.text = p!.telephone1
        telm.text = p!.telephone2
        sms.isSelected = p!.autoSMS
        pr.text = p!.profession.capitalized
        em.text = p!.email
        s.text = statut[p!.statut]
        s.inputView = pickerView2
        s.inputAccessoryView = toolbar
        ids.text = p!.ids
        dc.text = dateFormatter.string(from: datec ?? date)
        dc.inputView = dateCpicker
        dc.inputAccessoryView = toolbar
        nss.text = p!.numss
        i.text = p!.info
    }
    func editPatient(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/M/yyyy"
        let daten = dateFormatter.date(from: dn.text!)
        let datec = dateFormatter.date(from: dc.text!)
        var genre = pickerView1.selectedRow(inComponent: 0)
        let statut = pickerView2.selectedRow(inComponent: 0)
        if  genre == 0 { genre = p!.civilite }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        api!.sendRequest("UPDATE patients SET nir='\(nss.text!)', genre=\(genre), nom='\(nom.text!.uppercased())', prenom='\(prenom.text!.uppercased())', adresse='\(a1.text!.uppercased())', codepostal='\(cp.text!)', ville='\(ville.text!.uppercased())', telephone1='\(telf.text!)', telephone2='\(telm.text!)', email='\(em.text!)', naissance='\(dateFormatter.string(from: daten!))', creation='\(dateFormatter.string(from: datec!))', info='\(i.text!)', autorise_sms=\(sms.isSelected), ipp2='\(ids.text!)',  profession='\(pr.text!)', statut=\(statut) WHERE id =\(p!.id);")
        p!.civilite = pickerView1.selectedRow(inComponent: 0)
        p!.nom = (nom.text?.uppercased())!
        p!.prenom = (prenom.text?.uppercased())!
        p!.dateNaissance = dateFormatter.string(from: daten!)
        p!.adresse = (a1.text?.uppercased())!
        p!.codePostal = cp.text!
        p!.ville = (ville.text?.uppercased())!
        p!.telephone1 = telf.text!
        p!.telephone2 = telm.text!
        p!.autoSMS = sms.isSelected
        p!.profession = pr.text!
        p!.email = em.text!
        p!.statut = statut
        p!.ids = ids.text!
        p!.datec = dateFormatter.string(from: datec!)
        p!.numss = nss.text!
        p!.info = i.text!
    }
    
    func dateNPickerChanged(_ datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: datePicker.date)
        dn.text = strDate
    }
    func dateCPickerChanged(_ datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: datePicker.date)
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
    func showpicker(_ sender:UITextField!){
        performSegue(withIdentifier: "showpicker", sender: self)
    }
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         if pickerView.tag == 0{
        return hazards.count
        } else  if pickerView.tag == 1{
        return statut.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        if pickerView.tag == 0{
            c.text = hazards[row]
        } else if pickerView.tag == 1{
            s.text = statut[row]
        }
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        DispatchQueue.main.async(execute: {
            if resultsArr.count != 0 && (resultsArr[0] as AnyObject).count  == 0  {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showSuccess("Patient modifé", subTitle: "\(self.p!.prenom.capitalized) a été modifié avec succès.")
            } else {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showError("Erreur", subTitle: "Une erreur a survenu lors de la modification de \(self.p!.prenom.capitalized). \n Veuillez vérifier les champs rentrés")
            }
        })
        
    }
    func handleError(_ results: Int) {
        if results != 0{
            DispatchQueue.main.async(execute: {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showSuccess("Mise à jour", subTitle: "La photo de \(self.patient!.prenom.capitalized) a été modifié avec succès.")
                self.patient!.idPhoto = results
            })
        } else {
            DispatchQueue.main.async(execute: {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showError("Erreur", subTitle: "Une erreur inconnue est survenue lors du téléversement de la photo")
            })
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    @IBAction func dismiss(_ sender: AnyObject) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
        
    }
    func presentCamera()
    {
        cameraUI = UIImagePickerController()
        cameraUI.delegate = self
        cameraUI.sourceType = UIImagePickerControllerSourceType.camera
        //cameraUI.mediaTypes = [kUTTypeImage] as! String
        cameraUI.allowsEditing = true
        cameraUI.navigationItem.title = "kikou"
        self.present(cameraUI, animated: true, completion: nil)
    }
    func presentGallery()
    {
        cameraUI = UIImagePickerController()
        cameraUI.delegate = self
        cameraUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //cameraUI.mediaTypes = [kUTTypeImage] as! String
        cameraUI.allowsEditing = true
        cameraUI.navigationItem.title = "kikou"
        self.present(cameraUI, animated: true, completion: nil)
    }
    
    
    //pragma mark- Image
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        var imageToSave:UIImage
        imageToSave = image
        self.dismiss(animated: true, completion: nil)
        self.profilePicture.image = imageToSave
        self.patient!.photo = image
        api?.insertImage(image, idPatient: self.patient!.id)
    }
    
    
    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int)
    {
        NSLog("Did dismiss button: %d", buttonIndex)
        //self.presentCamera()
    }

}
