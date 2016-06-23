//
//  ImageCollectionViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 02/06/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit



class ImageCollectionViewController: UICollectionViewController, APIControllerProtocol  {
    let reuseIdentifier = "ImageCell"
    var api:APIController?
    var nb = 0
    var idRadio:NSArray?
    var dateCrea:NSArray?
    var refreshControl:UIRefreshControl?
    var patient:patients?
    let scl = SCLAlertView()
    var selectedPhoto:UIImage?
    var imageCache = [Int:UIImage]()
    var activityIndicator = DTIActivityIndicatorView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var quitButton: UIBarButtonItem!
    @IBOutlet var cv: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api=APIController(delegate: self)
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.blackColor()
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
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        nb=0
        idRadio = nil
        self.collectionView?.reloadData()
        menuButton.setFAIcon(FAType.FASearch, iconSize: 24)
        quitButton.setFAIcon(FAType.FATimes, iconSize: 24)
        api!.sendRequest("select id from images where idpatient=\(patient!.id)")
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView?.addSubview(self.refreshControl!)
        self.collectionView?.alwaysBounceVertical = true
        
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "\(title.title!) -  Dr \(preference.nomUser) - \(patient!.nom) \(patient!.prenom)"

        
        
    }
    func quit(sender: UIBarButtonItem){
        self.performSegueWithIdentifier("unWind", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   func longPressImage(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Began{
        
        sender.view!.userInteractionEnabled = false
        let alert = SCLAlertView()
        alert.addButton("Oui", action: {
            let cell = sender.view as! UICollectionViewCell
            let indexPath = self.collectionView?.indexPathForCell(cell)
            
            if let index = indexPath {
                let idr = self.idRadio?.objectAtIndex(index.row).valueForKey("id") as! Int
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
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        ToolBox.setDefaultBackgroundMessageForCollection(self.collectionView!, elements: nb, message: "Aucune photo n'a été prise")
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return nb
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! RadioCollectionViewCell
        let idr:Int = idRadio?.objectAtIndex(indexPath.row).valueForKey("id") as! Int
        //var image = api!.getRadioFromUrl(idr)
        cell.backgroundColor = UIColor.clearColor()
        var datec = " Date de création :"
        datec += dateCrea!.objectAtIndex(indexPath.row).valueForKey("date") as! String
        cell.label.text = datec
        cell.imageView.contentMode = .ScaleAspectFit
        // Configure the cell
        let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
        let urlString = NSURL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+image+from+images+where+id=\(idr)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)
        progressIndicatorView.frame = cell.imageView.bounds
        progressIndicatorView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        dispatch_async(dispatch_get_main_queue(), {
            cell.imageView.addSubview(progressIndicatorView)
            var alreadyLoad = true
        cell.imageView?.sd_setImageWithURL(urlString, placeholderImage: nil, options: .CacheMemoryOnly, progress: {
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
        let recognizer = UILongPressGestureRecognizer(target: self, action: "longPressImage:")
        recognizer.minimumPressDuration = 0.5
        recognizer.delaysTouchesBegan = true
        recognizer.delegate = self as? UIGestureRecognizerDelegate
        cell.addGestureRecognizer(recognizer)
        return cell
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        var type = 1
        for value in resultsArr{
            if value.count == 0 {
                type = 3
            } else
            if value.objectForKey("id") !=  nil{
                type = 0
                idRadio=resultsArr
                nb = idRadio!.count
            } else
            if value.objectForKey("date") !=  nil{
                type = 0
                dateCrea=resultsArr
            } else
            if value.objectForKey("error") !=  nil && value["error"] as? Int == 7{
                type = 2
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if(self.dateCrea?.count ?? 0 != self.nb){
                self.api!.sendRequest("select date from images where idpatient=\(self.patient!.id)")
            } else {
                self.activityIndicator.stopActivity()
                self.activityIndicator.removeFromSuperview()
                self.collectionView?.reloadData()
                if let a = self.refreshControl {
                    if a.refreshing {
                        a.endRefreshing()
                    }
                }
                
            }
            if(type == 3){
                SCLAlertView().showSuccess("Photo mis à jour", subTitle: "La modification de la photo du patient a été effectué avec succes", closeButtonTitle: "Fermer")
            }
        })
    }
    func handleError(results: Int) {
        if results == 1{
            api!.sendRequest("select id from images where idpatient=\(patient!.id)")
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
    func handleRefresh(refreshControl:UIRefreshControl){
        api!.sendRequest("select id from images where idpatient=\(patient!.id)")
        
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let cell:RadioCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! RadioCollectionViewCell
            self.selectedPhoto = cell.imageView.image
            
            self.performSegueWithIdentifier("showPhoto", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.destinationViewController.isKindOfClass(EtatCivilNavigationViewController) && self.cv.indexPathsForSelectedItems()!.count != 0 ){
            let fullScreenView: EtatCivilNavigationViewController = segue.destinationViewController as! EtatCivilNavigationViewController
            fullScreenView.profilePicture = self.selectedPhoto
            let idr = idRadio?.objectAtIndex((self.cv.indexPathsForSelectedItems()?.first?.row)!).valueForKey("id") as! Int
            api!.sendInsert("UPDATE patients SET idphoto = \(idr) where id=\(patient!.id)")
            patient?.idPhoto=idr
        }
        if segue.destinationViewController.isKindOfClass(CarousselViewController){
            let fullScreenView: CarousselViewController = segue.destinationViewController as! CarousselViewController
            fullScreenView.imageCache = [self.selectedPhoto!]
        }
    }
    

}
