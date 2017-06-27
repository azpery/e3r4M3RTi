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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        api!.sendRequest("select id from radios where idpatient=\(patient!.id)")
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.black
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
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
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(RadioCollectionViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
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


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        ToolBox.setDefaultBackgroundMessageForCollection(self.collectionView!, elements: nb, message: "Aucune radio n'a été prise")
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nb
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RadioCollectionViewCell
        let idr:Int = (idRadio?.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! Int
        cell.backgroundColor = UIColor.white
         let datec = (dateCrea!.object(at: indexPath.row) as AnyObject).value(forKey: "date") as! String
        cell.label.text = ToolBox.getFormatedDateWithSlash(ToolBox.getDateFromString(datec) ?? Date())
        cell.imageView.contentMode = .scaleAspectFit
        // Configure the cell
        let urlString = URL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+radio+as+image+from+radios+where+id=\(idr)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)
        let progressIndicatorView = CircularLoaderView(frame: CGRect.zero)
            progressIndicatorView.frame = cell.imageView.bounds
            progressIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        DispatchQueue.main.async(execute: {
            var alreadyLoad = true
            progressIndicatorView.progress = 0.0
            cell.imageView.addSubview(progressIndicatorView)
            
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
                self!.imageCache[indexPath.row] = image
        }
        })
        return cell
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        for value in resultsArr{
            if (value as AnyObject).object(forKey: "id") !=  nil{
                idRadio=resultsArr
                nb = idRadio!.count
            }
            if (value as AnyObject).object(forKey: "date") !=  nil{
                dateCrea=resultsArr
            }
            let v = value as? NSDictionary
            if (value as AnyObject).object(forKey: "error") !=  nil && v?["error"] as? Int == 7{
            }
        }
        DispatchQueue.main.async(execute: {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if(self.dateCrea?.count ?? 0 != self.nb){
                api!.sendRequest("select date from radios where idpatient=\(self.patient!.id)")
            } else {
                self.activityIndicator.stopActivity()
                self.activityIndicator.removeFromSuperview()
                if let a = self.refreshControl {
                    if a.isRefreshing {
                        a.endRefreshing()
                    }
                }
                self.collectionView?.reloadData()
            }
        })
        
        
    }
    func handleError(_ results: Int) {
        if results == 1{
            api!.sendRequest("select id from radios where idpatient=\(patient!.id)")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    func handleRefresh(_ refreshControl:UIRefreshControl){
        api!.sendRequest("select id from radios where idpatient=\(patient!.id)")
        
    }
    
    override func collectionView(_ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath){
        selectedPhoto = self.imageCache[indexPath.row]
        self.performSegue(withIdentifier: "showRadio", sender: self)
        
    }
    @IBAction func dismiss(_ sender: AnyObject) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: ImageScrollViewController.self){
            let fullScreenView: ImageScrollViewController = segue.destination as! ImageScrollViewController
            fullScreenView.imageScrollLargeImageName = self.imageCache[(self.cv.indexPathsForSelectedItems?.first!.row)!]
        }
        if segue.destination.isKind(of: CarousselViewController.self){
            let fullScreenView: CarousselViewController = segue.destination as! CarousselViewController
            fullScreenView.imageCache = [self.selectedPhoto!]
        }
    }

}
