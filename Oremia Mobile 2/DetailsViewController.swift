//
//  DetailsViewController.swift
//  Oremia mobile
//
//  Created by Zumatec on 10/03/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import UIKit
import QuartzCore

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol, UISearchBarDelegate,  UISearchDisplayDelegate, UISearchControllerDelegate {
    lazy var api : APIController = APIController(delegate: self)
    var praticien: Praticien?
    var tracks = [patients]()
    var filtredpatients = [patients]()
    var searchActive : Bool = false
    var loading = false
    var isSelectingPatient:Bool = false
    var patientText: UILabel?
    var eventManager:EventManager?
    var activityIndicator = DTIActivityIndicatorView()
    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var logOut: UIBarButtonItem!
    @IBOutlet weak var appsTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if(!self.isSelectingPatient){
            menuButton.setFAIcon(FAType.FABars, iconSize: 24)
            addButton.setFAIcon(FAType.FAUserPlus, iconSize: 24)
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            //            let navigationItem = UINavigationItem(title: "Nouvel événement")
            //            self.navigationController?.navigationItem = navigationItem
        }
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.blackColor()
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
        api.sendRequest("select * from patients where idpraticien=\(preference.idUser) ORDER BY id DESC LIMIT 10 OFFSET 0 ")
        loading = true
        if self.revealViewController() != nil && !self.isSelectingPatient {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        } else {
            let barbuttonFont = UIFont(name: "Avenir Next", size: 15) ?? UIFont.systemFontOfSize(15)
            menuButton.title = "annuler"
            menuButton.action = "hideMe"
            menuButton.target = self
            menuButton.setTitleTextAttributes([NSFontAttributeName: barbuttonFont], forState: UIControlState.Normal)
        }
        self.tracksTableView.reloadData()
        self.searchDisplayController?.searchResultsTableView.rowHeight = tracksTableView.rowHeight
        self.searchDisplayController?.searchBar.showsCancelButton = false
        self.searchDisplayController?.searchBar.showsSearchResultsButton = false
        let test = HelpButton()
        test.showButton(self)
            }
    
    override func viewDidAppear(animated: Bool) {
        if (self.searchDisplayController!.active){
            self.searchActive = true
        }
        
    }
    func hideMe() {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive || self.searchDisplayController!.active{
            return self.filtredpatients.count
        } else {
            return tracks.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var track:patients
        let cell = tracksTableView.dequeueReusableCellWithIdentifier("TrackCell") as! TrackCell
        if self.searchActive || self.searchDisplayController!.active {
            track  = filtredpatients[indexPath.row]
        } else {
            track = tracks[indexPath.row]
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let ddate = dateFormatter.dateFromString(track.dateNaissance)
        //        dateFormatter.dateFormat = "yyyy"
        let flags: NSCalendarUnit = [.NSDayCalendarUnit, .NSMonthCalendarUnit, .NSYearCalendarUnit]
        let date = NSDate()
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        let year = components.year as Int
        if (ddate != nil ){
            let dyear =  NSCalendar.currentCalendar().components(flags, fromDate: ddate!).year as Int
            let dage = year - dyear
            cell.age.text = "\(dage) ans"
        }else {
            cell.age.text = "Date naissance non renseignée"
        }
        
        cell.Adresse.text = (""+renseigner(track.adresse)+" "+track.codePostal+" "+track.ville).lowercaseString.capitalizedString
        cell.email.text = ""+renseigner(track.email)
        cell.tel.text = ""+renseigner(track.telephone1)
        cell.titleLabel.text = ""+track.prenom.lowercaseString.capitalizedString+" "+track.nom.lowercaseString.capitalizedString
        print(NSDate())
        cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2;
        cell.avatar.clipsToBounds = true
        cell.avatar.layer.borderWidth = 0.5
        cell.avatar.layer.borderColor = UIColor.whiteColor().CGColor
        cell.avatar.contentMode = .ScaleAspectFit
        let urlString = NSURL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+image+from+images_preview+where+id=\(track.idPhoto)&&db=zuma&&login=zm\(preference.idUser)&&pw=\(preference.password)")
        dispatch_async(dispatch_get_main_queue(), {
            cell.avatar.sd_setImageWithURL(urlString, placeholderImage: nil, options: .CacheMemoryOnly, progress: {
            (receivedSize, expectedSize) -> Void in
            }) {
                (image, error, _, _) -> Void in
                cell.avatar.image = image
                track.photo = image
                        }
            })

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.isSelectingPatient {
            var track:patients
            if self.searchActive || self.searchDisplayController!.active {
                track  = filtredpatients[indexPath.row]
            } else {
                track = tracks[indexPath.row]
            }
            self.patientText!.text = ""+track.prenom.lowercaseString.capitalizedString+" "+track.nom.lowercaseString.capitalizedString
            self.eventManager!.internalEvent.idPatient = track.id
            self.eventManager!.internalEvent.patient = track
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        if self.searchActive || self.searchDisplayController!.active {
            _ = filtredpatients[indexPath.row]
        } else {
            _ = tracks[indexPath.row]
        }
    }
    func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController) {
        controller.searchBar.showsCancelButton = false
    }
    func searchDisplayControllerDidBeginSearch(controller: UISearchDisplayController) {
        controller.searchBar.showsCancelButton = false
        controller.searchBar.showsSearchResultsButton = false
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        self.tracksTableView.reloadData()

    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        self.tracksTableView.reloadData()
    }
    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        searchActive = false;
//        self.tracksTableView.reloadData()
//    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true;
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != ""  {
            api.sendRequest("select * from patients where nom LIKE '%\( searchText.uppercaseString)%' OR prenom LIKE '%\(searchText.uppercaseString)%' OR nom LIKE '%\( searchText.lowercaseString)%' OR prenom LIKE '%\(searchText.lowercaseString)%' LIMIT 10")
            
        }
        //        self.filtredpatients = self.tracks.filter({( patient: patients) -> Bool in
        //            //            let categoryMatch = (scope == "All")
        //            let stringMatch = patient.prenom.capitalizedString.rangeOfString(searchText.capitalizedString)
        //            let nomMatch = patient.nom.capitalizedString.rangeOfString(searchText.capitalizedString)
        //            return (stringMatch != nil) || (nomMatch != nil)
        //        })
        if(filtredpatients.count == 0){
        } else {
            searchActive = true;
        }
        self.tracksTableView.reloadData()
        self.searchDisplayController?.searchResultsTableView.reloadData()
    }
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.showsSearchResultsButton = false
    }
    func renseigner(text:String) -> String{
        var vretour = text
        if text == "" {
            vretour = "Non renseigné"
        }
        return vretour
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height && !loading && !self.searchDisplayController!.active) {
            self.loading = true
            api.sendRequest("select * from patients where idpraticien=\(preference.idUser) ORDER BY id DESC limit 20 OFFSET \(tracks.count)")
        }
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            if self.searchDisplayController!.active {
                self.filtredpatients = patients.patientWithJSON(resultsArr)
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }else {
                self.tracks = self.tracks + patients.patientWithJSON(resultsArr)
                
            }
            self.activityIndicator.stopActivity()
            self.activityIndicator.removeFromSuperview()
            self.tracksTableView.reloadData()
            self.loading = false
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            //            if patients.patientWithJSON(resultsArr).count == 10{
            //            self.api.sendRequest("select * from patients where idpraticien=\(preference.idUser) limit 10 OFFSET \(self.tracks.count)")
            //            }
            
        })
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        var vretour = true
        if self.isSelectingPatient {
            vretour = false
        }
        return vretour
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier=="toPatientTabBar"){
            let detailsViewController: TabBarViewController = segue.destinationViewController as! TabBarViewController
            var albumIndex : Int
            var selectedAlbum:patients
            if (self.searchDisplayController!.active){
                albumIndex = searchDisplayController!.searchResultsTableView.indexPathForSelectedRow!.row
                selectedAlbum = self.filtredpatients[albumIndex]
            }else{
                albumIndex = appsTableView!.indexPathForSelectedRow!.row
                selectedAlbum = self.tracks[albumIndex]
            }
            detailsViewController.patient = selectedAlbum
        } else if (segue.identifier=="register"){
            let newpatient: NewPatientTableViewController = segue.destinationViewController as! NewPatientTableViewController
            newpatient.parent = self
        }
    }
    func handleError(results: Int) {
        if results == 1{
            api.sendRequest("select * from patients where idpraticien=\(preference.idUser) ORDER BY id DESC LIMIT 10 OFFSET 0 ")
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
    @IBAction func unwindToSelectPatient(segue: UIStoryboardSegue) {
        
        self.tracksTableView.reloadData()
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}