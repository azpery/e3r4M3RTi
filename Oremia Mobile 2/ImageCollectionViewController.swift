//
//  ImageCollectionViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 02/06/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit
import MobileCoreServices



class ImageCollectionViewController: UICollectionViewController, APIControllerProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    let reuseIdentifier = "ImageCell"
    var api:APIController?
    var nb = 0
    var idRadio:NSArray?
    var dateCrea:NSArray?
    var refreshControl:UIRefreshControl?
    var patient:patients?
    let scl = SCLAlertView()
    var cameraUI:UIImagePickerController = UIImagePickerController()
    var selectedPhoto:UIImage?
    var imageCache = [Int:UIImage]()
    var activityIndicator = DTIActivityIndicatorView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet var cv: UICollectionView!
    @IBOutlet var takePic: UIBarButtonItem!
    @IBOutlet var pickPic: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api=APIController(delegate: self)
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.black
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
        if self.tabBarController != nil{
           let tbn : TabBarViewController = self.tabBarController as! TabBarViewController
            patient = tbn.patient
        } else {
            let tb : ImageViewController = self.navigationController as! ImageViewController
            patient = tb.patient
        }
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        nb=0
        idRadio = nil
        self.collectionView?.reloadData()
        menuButton.setFAIcon(FAType.faSearch, iconSize: 24)
        quitButton.setFAIcon(FAType.faTimes, iconSize: 24)
        takePic.setFAIcon(FAType.faCamera, iconSize: 24)
        pickPic.setFAIcon(FAType.faPictureO, iconSize: 24)
        api!.sendRequest("select id from images where idpatient=\(patient!.id)")
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(ImageCollectionViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(self.refreshControl!)
        self.collectionView?.alwaysBounceVertical = true
        
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "\(title.title!) -  Dr \(preference.nomUser) - \(patient!.getFullName())"

        
        
    }
    func quit(_ sender: UIBarButtonItem){
        self.performSegue(withIdentifier: "unWind", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   func longPressImage(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began{
        
        sender.view!.isUserInteractionEnabled = false
        let alert = SCLAlertView()
        alert.addButton("Oui", action: {
            let cell = sender.view as! UICollectionViewCell
            let indexPath = self.collectionView?.indexPath(for: cell)
            
            if let index = indexPath {
                let idr = (self.idRadio?.object(at: index.row) as AnyObject).value(forKey: "id") as! Int
                self.api!.sendRequest("UPDATE patients SET idphoto = \(idr) where id=\(self.patient!.id)")
                self.patient?.idPhoto=idr
                print(index.row)
            } else {
                print("Could not find index path")
            }
            
            
        })
        alert.showWarning("Modification image patient", subTitle: "Etes vous sur de vouloir choisir cette image?", closeButtonTitle: "Non")
        
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        ToolBox.setDefaultBackgroundMessageForCollection(self.collectionView!, elements: nb, message: "Aucune photo n'a été prise")
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return nb
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RadioCollectionViewCell
        let idr:Int = (idRadio?.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! Int
        //var image = api!.getRadioFromUrl(idr)
        cell.backgroundColor = UIColor.clear
        var datec = " Date de création :"
        datec += (dateCrea!.object(at: indexPath.row) as AnyObject).value(forKey: "date") as! String
        cell.label.text = ToolBox.getFormatedDate(ToolBox.getDateFromString(datec) ?? Date())
        cell.imageView.contentMode = .scaleAspectFit
        // Configure the cell
        let progressIndicatorView = CircularLoaderView(frame: CGRect.zero)
        let urlString = URL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+image+from+images+where+id=\(idr)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)
        progressIndicatorView.frame = cell.imageView.bounds
        progressIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        DispatchQueue.main.async(execute: {
            cell.imageView.addSubview(progressIndicatorView)
            var alreadyLoad = true
        cell.imageView?.sd_setImage(with: urlString, placeholderImage: nil, options: .cacheMemoryOnly, progress: {
            (receivedSize, expectedSize) -> Void in
            alreadyLoad = false
            progressIndicatorView.progress = CGFloat(receivedSize)/CGFloat(expectedSize)
            }) {
                [weak self]
                (image, error, _, _) -> Void in
                if !alreadyLoad {
                    progressIndicatorView.reveal()
                } else {
                    progressIndicatorView.removeFromSuperview()
                }
                if image == nil {
                    self!.imageCache[indexPath.row] = UIImage(named: "glyphicons_003_user")!
                } else {
                    self!.imageCache[indexPath.row] = image
                }
                
        }
        })
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(ImageCollectionViewController.longPressImage(_:)))
        recognizer.minimumPressDuration = 0.5
        recognizer.delaysTouchesBegan = true
        recognizer.delegate = self as? UIGestureRecognizerDelegate
        cell.addGestureRecognizer(recognizer)
        return cell
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        
        if let resultsArr = results["results"] as? NSArray{
            var type = 1
            for value in resultsArr{
                if (value as AnyObject).count == 0 {
                    type = 3
                } else
                    if (value as AnyObject).object(forKey: "id") !=  nil{
                        type = 0
                        idRadio=resultsArr
                        nb = idRadio!.count
                    } else
                        if (value as AnyObject).object(forKey: "date") !=  nil{
                            type = 0
                            dateCrea=resultsArr
                        } else{
                            let v = value as? NSDictionary
                            if (value as AnyObject).object(forKey: "error") !=  nil && v?["error"] as? Int == 7{
                                type = 2
                            }
                            
                }
                
            }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if(self.dateCrea?.count ?? 0 != self.nb){
                    self.api!.sendRequest("select date from images where idpatient=\(self.patient!.id)")
                } else {
                    self.activityIndicator.stopActivity()
                    self.activityIndicator.removeFromSuperview()
                    self.collectionView?.reloadData()
                    if let a = self.refreshControl {
                        if a.isRefreshing {
                            a.endRefreshing()
                        }
                    }
                    
                }
                if(type == 3){
                    SCLAlertView().showSuccess("Photo mis à jour", subTitle: "La modification de la photo du patient a été effectué avec succes", closeButtonTitle: "Fermer")
                }
            })
            
        }else{
            DispatchQueue.main.async(execute: {
                
                self.api!.sendRequest("select id from images where idpatient=\(self.patient!.id)")
                
            })
        }
        
    }
    func handleError(_ results: Int) {
        if results != 0{
            self.api!.sendRequest("select id from images where idpatient=\(self.patient!.id)")
        }else
        if results == 1{
            api!.sendRequest("select id from images where idpatient=\(patient!.id)")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    func handleRefresh(_ refreshControl:UIRefreshControl){
        api!.sendRequest("select id from images where idpatient=\(patient!.id)")
        
    }
    
    @IBAction func takePic(_ sender: AnyObject) {
        presentCamera()
    }
    @IBAction func pickPic(_ sender: AnyObject) {
        presentGallery()
    }
    
    func presentCamera()
    {
        cameraUI = UIImagePickerController()
        cameraUI.delegate = self
        cameraUI.sourceType = UIImagePickerControllerSourceType.camera
        //cameraUI.mediaTypes = [kUTTypeImage] as! String
        cameraUI.allowsEditing = false
        cameraUI.navigationItem.title = "kikou"
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
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        var imageToSave:UIImage
        imageToSave = image
        self.dismiss(animated: true, completion: nil)
        api?.insertImage(image, idPatient: self.patient!.id, isNewPp: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let cell:RadioCollectionViewCell = collectionView.cellForItem(at: indexPath) as! RadioCollectionViewCell
            self.selectedPhoto = cell.imageView.image
            
            self.performSegue(withIdentifier: "showPhoto", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination.isKind(of: EtatCivilNavigationViewController.self) && self.cv.indexPathsForSelectedItems!.count != 0 ){
            let fullScreenView: EtatCivilNavigationViewController = segue.destination as! EtatCivilNavigationViewController
            fullScreenView.profilePicture = self.selectedPhoto
            let idr = (idRadio?.object(at: (self.cv.indexPathsForSelectedItems?.first?.row)!) as AnyObject).value(forKey: "id") as! Int
            api!.sendInsert("UPDATE patients SET idphoto = \(idr) where id=\(patient!.id)")
            patient?.idPhoto=idr
        }
        if segue.destination.isKind(of: CarousselViewController.self){
            let fullScreenView: CarousselViewController = segue.destination as! CarousselViewController
            fullScreenView.imageCache = [self.selectedPhoto!]
        }
    }
    

}
