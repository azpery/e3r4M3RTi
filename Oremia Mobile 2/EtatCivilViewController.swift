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
    var api = APIController?()
    var patient = patients?()
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
        title.title = "\(title.title!) -  Dr \(preference.nomUser) - \(patient!.nom) \(patient!.prenom.capitalizedString)"
        if profilePicture != nil {
            
            profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
            profilePicture.clipsToBounds = true
            profilePicture.layer.borderWidth = 0.5
            profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
            profilePicture.contentMode = .ScaleAspectFit
            let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
            progressIndicatorView.frame = self.profilePicture.bounds
            progressIndicatorView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.profilePicture.addSubview(progressIndicatorView)
            var alreadyLoad = true
            let urlString = NSURL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+image+from+images+where+id=\(patient!.idPhoto)&&db=zuma&&login=zm\(preference.idUser)&&pw=\(preference.password)")
            dispatch_async(dispatch_get_main_queue(), {
                self.profilePicture.sd_setImageWithURL(urlString, placeholderImage: nil, options: .CacheMemoryOnly, progress: {
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
            photoButton.setFAIcon(FAType.FACamera, forState: .Normal)
            chooseButton.setFAIcon(FAType.FAPictureO, forState: .Normal)
            menuButton.setFAIcon(FAType.FASearch, iconSize: 24)
            quitButton.setFAIcon(FAType.FATimes, iconSize: 24)
            validButton.setFAIcon(FAType.FACheck, forState: .Normal)
            validButton.layer.cornerRadius = validButton.frame.size.width / 2;
            validButton.clipsToBounds = true
        }

//        buttonRetablir.setType(Type.Danger)
//        buttonRetablir.buttonStyle = Style.V3
//        buttonValider.setType(Type.Success)
//        buttonValider.buttonStyle = Style.V3
        

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        if ( patient!.info != ""){
            
            JLToastView.setDefaultValue(
                UIColor.redColor(),
                forAttributeName: JLToastViewBackgroundColorAttributeName,
                userInterfaceIdiom: .Phone
            )
            JLToastView.setDefaultValue(
                UIColor.whiteColor(),
                forAttributeName: JLToastViewTextColorAttributeName,
                userInterfaceIdiom: .Phone
            )
            var info = patient!.info.componentsSeparatedByString("!")
            var infoParsed = ""
            for(var i = 1; i<info.count; i++){
                infoParsed += info[i]
                if i<info.count - 1 {infoParsed += "\n"}
            }
            JLToast.makeText(infoParsed).show()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Valider(sender: AnyObject) {
        let alert = SCLAlertView()
        alert.addButton("Valider", action:{
            self.detailsViewController!.editPatient()
        })
        alert.showWarning("Confirmation", subTitle: "Êtes-vous sur de vouloir modifier \(patient!.prenom)", closeButtonTitle:"Annuler")
    }
    @IBAction func Retablir(sender: AnyObject) {
        let alert = SCLAlertView()
        alert.addButton("Oui", action:{
            self.detailsViewController!.initValue()
        })
        alert.showWarning("Confirmation", subTitle: "Êtes-vous sur de vouloir annuler les modifications?", closeButtonTitle:"Annuler")
        
    }
    @IBAction func prendrePhoto(sender: AnyObject) {
        self.presentCamera()
    }
    @IBAction func choisirPhoto(sender: AnyObject) {
         self.presentGallery()
    }

    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            if resultsArr[0] as! String == "" {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showSuccess("Patient modifé", subTitle: "\(self.patient!.prenom.capitalizedString) a bien été modifié avec succès.")
            } else {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showSuccess("Erreur", subTitle: "Une erreur a survenu lors de la modification de \(self.patient!.prenom.capitalizedString). \n Veuillez vérifié les champs rentrés")
            }
        })
    }
    func handleError(results: Int) {
        if results != 0{
            dispatch_async(dispatch_get_main_queue(), {
                let alert = SCLAlertView()
                alert.showCloseButton = false
                alert.addButton("Ok", action:{})
                alert.showSuccess("Mise à jour", subTitle: "La photo de \(self.patient!.prenom.capitalizedString) a été modifié avec succès.")
                self.patient!.idPhoto = results
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
            let alert = SCLAlertView()
            alert.showCloseButton = false
            alert.addButton("Ok", action:{})
            alert.showError("Erreur", subTitle: "Une erreur inconnue est survenue lors du téléversement de la photo")
            })
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier=="embedTable"){
            self.detailsViewController = segue.destinationViewController as? EtatCivilTableViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            patient = tb.patient!
            self.detailsViewController!.p = patient!
        }
        if(segue.identifier=="selectImage"){
            let ImageCollection: ImageViewController = segue.destinationViewController as! ImageViewController
            let tb : TabBarViewController = self.tabBarController as! TabBarViewController
            patient = tb.patient!
            ImageCollection.patient = patient!
        }
    }
    @IBAction func dismiss(sender: AnyObject) {
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)

    }
    func presentCamera()
    {
        cameraUI = UIImagePickerController()
        cameraUI.delegate = self
        cameraUI.sourceType = UIImagePickerControllerSourceType.Camera
        //cameraUI.mediaTypes = [kUTTypeImage] as! String
        cameraUI.allowsEditing = true
        cameraUI.navigationItem.title = "kikou"
        self.presentViewController(cameraUI, animated: true, completion: nil)
    }
    func presentGallery()
    {
        cameraUI = UIImagePickerController()
        cameraUI.delegate = self
        cameraUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //cameraUI.mediaTypes = [kUTTypeImage] as! String
        cameraUI.allowsEditing = true
        cameraUI.navigationItem.title = "kikou"
        self.presentViewController(cameraUI, animated: true, completion: nil)
    }
    

    //pragma mark- Image
    
    func imagePickerControllerDidCancel(picker:UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        var imageToSave:UIImage
        imageToSave = image
        self.dismissViewControllerAnimated(true, completion: nil)
        self.profilePicture.image = imageToSave
        self.patient!.photo = image
        api?.insertImage(image, idPatient: self.patient!.id)
    }
    
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int)
    {
        NSLog("Did dismiss button: %d", buttonIndex)
        //self.presentCamera()
    }

}
