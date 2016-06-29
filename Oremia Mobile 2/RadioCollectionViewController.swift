//
//  RadioCollectionViewController.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 15/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"


var api:APIController?
class RadioCollectionViewController: UICollectionViewController,  APIControllerProtocol {
    var nb = 0
    var idRadio:NSArray?
    var dateCrea:NSArray?
    var patient:patients?
    let scl = SCLAlertView()
    var refreshControl:UIRefreshControl?
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
        let tb : TabBarViewController = self.tabBarController as! TabBarViewController
        patient = tb.patient
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api!.sendRequest("select id from radios where idpatient=\(patient!.id)")
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.blackColor()
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
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
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView?.addSubview(self.refreshControl!)
        self.collectionView?.alwaysBounceVertical = true
        
        let title = self.navigationController!.navigationBar.topItem!
        title.title = "\(title.title!) -  Dr \(preference.nomUser) - \(patient!.nom) \(patient!.prenom.capitalizedString)"

        
    }
    func quit(sender: UIBarButtonItem){
        self.performSegueWithIdentifier("unWind", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        ToolBox.setDefaultBackgroundMessageForCollection(self.collectionView!, elements: nb, message: "Aucune radio n'a été prise")
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nb
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! RadioCollectionViewCell
        let idr:Int = idRadio?.objectAtIndex(indexPath.row).valueForKey("id") as! Int
        cell.backgroundColor = UIColor.whiteColor()
        var datec = " Date de création :"
        datec += dateCrea!.objectAtIndex(indexPath.row).valueForKey("date") as! String
        cell.label.text = datec
        cell.imageView.contentMode = .ScaleAspectFit
        // Configure the cell
        let urlString = NSURL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+radio+as+image+from+radios+where+id=\(idr)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)
        let progressIndicatorView = CircularLoaderView(frame: CGRectZero)
            progressIndicatorView.frame = cell.imageView.bounds
            progressIndicatorView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        dispatch_async(dispatch_get_main_queue(), {
            var alreadyLoad = true
            progressIndicatorView.progress = 0.0
            cell.imageView.addSubview(progressIndicatorView)
            
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
                self!.imageCache[indexPath.row] = image
        }
        })
        return cell
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        for value in resultsArr{
            if value.objectForKey("id") !=  nil{
                idRadio=resultsArr
                nb = idRadio!.count
            }
            if value.objectForKey("date") !=  nil{
                dateCrea=resultsArr
            }
            if value.objectForKey("error") !=  nil && value["error"] as? Int == 7{
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if(self.dateCrea?.count ?? 0 != self.nb){
                api!.sendRequest("select date from radios where idpatient=\(self.patient!.id)")
            } else {
                self.activityIndicator.stopActivity()
                self.activityIndicator.removeFromSuperview()
                if let a = self.refreshControl {
                    if a.refreshing {
                        a.endRefreshing()
                    }
                }
                self.collectionView?.reloadData()
            }
        })
        
        
    }
    func handleError(results: Int) {
        if results == 1{
            api!.sendRequest("select id from radios where idpatient=\(patient!.id)")
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    
    func handleRefresh(refreshControl:UIRefreshControl){
        api!.sendRequest("select id from radios where idpatient=\(patient!.id)")
        
    }
    
    override func collectionView(collectionView: UICollectionView,
    didSelectItemAtIndexPath indexPath: NSIndexPath){
        let idr:Int = idRadio?.objectAtIndex(indexPath.row).valueForKey("id") as! Int
        selectedPhoto = self.imageCache[indexPath.row]
        self.performSegueWithIdentifier("showRadio", sender: self)
        
    }
    @IBAction func dismiss(sender: AnyObject) {
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(ImageScrollViewController){
            let fullScreenView: ImageScrollViewController = segue.destinationViewController as! ImageScrollViewController
            fullScreenView.imageScrollLargeImageName = self.imageCache[(self.cv.indexPathsForSelectedItems()?.first!.row)!]
        }
        if segue.destinationViewController.isKindOfClass(CarousselViewController){
            let fullScreenView: CarousselViewController = segue.destinationViewController as! CarousselViewController
            fullScreenView.imageCache = [self.selectedPhoto!]
        }
    }

}
