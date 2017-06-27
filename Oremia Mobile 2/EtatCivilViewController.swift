//
//  EtatCivilViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 22/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import MobileCoreServices


class EtatCivilViewController: UIViewController, APIControllerProtocol, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate {
    var detailsViewController : EtatCivilTableViewController?
    @IBOutlet weak var buttonRetablir: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var buttonValider: UIButton!
    var api:APIController?
    var patient:patients?
    var cameraUI:UIImagePickerController = UIImagePickerController()
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet weak var validButton: UIButton!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        api = APIController(delegate: self)
        let tb : TabBarViewController = self.tabBarController as! TabBarViewController
        patient = tb.patient!
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
            validButton.setFAIcon(FAType.faCheck, forState: UIControlState())
            validButton.layer.cornerRadius = validButton.frame.size.width / 2;
            validButton.clipsToBounds = true
        }
        

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if ( patient!.info != ""){
            
            var info = patient!.info.components(separatedBy: "!")
            var infoParsed = ""
            for i in (1 ..< info.count){
                infoParsed += info[i]
                if i<info.count - 1 {infoParsed += "\n"}
            }
            
            let banner = Banner(title: "Informations patient", subtitle: infoParsed, image: UIImage(named: "glyphicons_078_warning_sign"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Valider(_ sender: AnyObject) {
        let alert = SCLAlertView()
        _ = alert.addButton("Valider", action:{
            self.detailsViewController!.editPatient()
        })
        _ = alert.showWarning("Confirmation", subTitle: "Êtes-vous sur de vouloir modifier \(patient!.prenom)", closeButtonTitle:"Annuler")
    }
    @IBAction func Retablir(_ sender: AnyObject) {
        let alert = SCLAlertView()
        _ = alert.addButton("Oui", action:{
            self.detailsViewController!.initValue()
        })
        _ = alert.showWarning("Confirmation", subTitle: "Êtes-vous sur de vouloir annuler les modifications?", closeButtonTitle:"Annuler")
        
    }
    @IBAction func prendrePhoto(_ sender: AnyObject) {
        self.presentCamera()
    }
    @IBAction func choisirPhoto(_ sender: AnyObject) {
         self.presentGallery()
    }

    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        DispatchQueue.main.async(execute: {
            if resultsArr[0] as! String == "" {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                _ = alert.addButton("Ok", action:{})
                _ = alert.showSuccess("Patient modifé", subTitle: "\(self.patient!.prenom.capitalized) a bien été modifié avec succès.")
            } else {
                let alert = SCLAlertView()
                _ = alert.showCloseButton = false
                _ = alert.addButton("Ok", action:{})
                _ = alert.showSuccess("Erreur", subTitle: "Une erreur a survenu lors de la modification de \(self.patient!.prenom.capitalized). \n Veuillez vérifié les champs rentrés")
            }
        })
    }
    func handleError(_ results: Int) {
        if results != 0{
            DispatchQueue.main.async(execute: {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                _ = alert.addButton("Ok", action:{})
                _ = alert.showSuccess("Mise à jour", subTitle: "La photo de \(self.patient!.prenom.capitalized) a été modifié avec succès.")
                self.patient!.idPhoto = results
            })
        } else {
            DispatchQueue.main.async(execute: {
            let alert = SCLAlertView()
            alert.showCloseButton = false
            _ = alert.addButton("Ok", action:{})
            _ = alert.showError("Erreur", subTitle: "Une erreur inconnue est survenue lors du téléversement de la photo")
            })
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="embedTable"){
            self.detailsViewController = segue.destination as? EtatCivilTableViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            patient = tb.patient!
            self.detailsViewController!.p = patient!
        }
        if(segue.identifier=="selectImage"){
            let ImageCollection: ImageViewController = segue.destination as! ImageViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            patient = tb.patient!
            ImageCollection.patient = patient!
        }
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
        cameraUI.allowsEditing = false
        cameraUI.navigationItem.title = "Photo"
        self.present(cameraUI, animated: true, completion: nil)
    }
    func presentGallery()
    {
        cameraUI = UIImagePickerController()
        cameraUI.delegate = self
        cameraUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
        //cameraUI.mediaTypes = [kUTTypeImage] as! String
        cameraUI.allowsEditing = false
        cameraUI.navigationItem.title = "Photo"
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
