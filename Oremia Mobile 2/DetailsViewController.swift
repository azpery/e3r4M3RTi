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
            menuButton.setFAIcon(FAType.faBars, iconSize: 24)
            addButton.setFAIcon(FAType.faUserPlus, iconSize: 24)
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            //            let navigationItem = UINavigationItem(title: "Nouvel événement")
            //            self.navigationController?.navigationItem = navigationItem
        }
        activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.black
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
        api.sendRequest("select * from patients where idpraticien=\(preference.idUser) ORDER BY id DESC LIMIT 10 OFFSET 0 ")
        loading = true
        if self.revealViewController() != nil && !self.isSelectingPatient {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        } else {
            let barbuttonFont = UIFont(name: "Avenir Next", size: 15) ?? UIFont.systemFont(ofSize: 15)
            menuButton.title = "annuler"
            menuButton.action = #selector(DetailsViewController.hideMe)
            menuButton.target = self
            menuButton.setTitleTextAttributes([NSFontAttributeName: barbuttonFont], for: UIControlState())
        }
        self.tracksTableView.reloadData()
        self.searchDisplayController?.searchResultsTableView.rowHeight = tracksTableView.rowHeight
        self.searchDisplayController?.searchBar.showsCancelButton = false
        self.searchDisplayController?.searchBar.showsSearchResultsButton = false
        let test = HelpButton()
        test.showButton(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.searchDisplayController!.isActive){
            self.searchActive = true
        }
        
    }
    func hideMe() {
        self.dismiss(animated: true, completion: {})
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive || self.searchDisplayController!.isActive{
            return self.filtredpatients.count
        } else {
            return tracks.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var track:patients
        let cell = tracksTableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        if self.searchActive || self.searchDisplayController!.isActive {
            track  = filtredpatients[indexPath.row]
        } else {
            track = tracks[indexPath.row]
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let ddate = dateFormatter.date(from: track.dateNaissance)
        //        dateFormatter.dateFormat = "yyyy"
        let flags: NSCalendar.Unit = [.NSDayCalendarUnit, .NSMonthCalendarUnit, .NSYearCalendarUnit]
        let date = Date()
        let components = (Calendar.current as NSCalendar).components(flags, from: date)
        let year = components.year!
        if (ddate != nil ){
            let dyear =  (Calendar.current as NSCalendar).components(flags, from: ddate!).year!
            let dage = year - dyear
            cell.age.text = "\(dage) ans"
        }else {
            cell.age.text = "Date naissance non renseignée"
        }
        
        cell.Adresse.text = (""+renseigner(track.adresse)+" "+track.codePostal+" "+track.ville).lowercased().capitalized
        cell.email.text = ""+renseigner(track.email)
        cell.tel.text = ""+renseigner(track.telephone1)
        cell.titleLabel.text = track.getFullName()
        print(Date())
        cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2;
        cell.avatar.clipsToBounds = true
        cell.avatar.layer.borderWidth = 0.5
        cell.avatar.layer.borderColor = UIColor.white.cgColor
        cell.avatar.contentMode = .scaleAspectFill
        let urlString = URL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+image+from+images_preview+where+id=\(track.idPhoto)&&db=zuma&&login=zm\(preference.idUser)&&pw=\(preference.password)")
        DispatchQueue.main.async(execute: {
            cell.avatar.sd_setImage(with: urlString, placeholderImage: nil, options: .cacheMemoryOnly, progress: {
                (receivedSize, expectedSize) -> Void in
                }) {
                    (image, error, _, _) -> Void in
                    cell.avatar.image = image
                    track.photo = image
            }
        })
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isSelectingPatient {
            var track:patients
            if self.searchActive || self.searchDisplayController!.isActive {
                track  = filtredpatients[indexPath.row]
            } else {
                track = tracks[indexPath.row]
            }
            self.patientText!.text = ""+track.prenom.lowercased().capitalized+" "+track.nom.lowercased().capitalized
            self.eventManager!.internalEvent.idPatient = track.id
            self.eventManager!.internalEvent.patient = track
            self.eventManager!.editEvent?.title = ""+track.prenom.lowercased().capitalized+" "+track.nom.lowercased().capitalized
            self.navigationController?.popToRootViewController(animated: true)
        }
        if self.searchActive || self.searchDisplayController!.isActive {
            _ = filtredpatients[indexPath.row]
        } else {
            _ = tracks[indexPath.row]
        }
    }
    @nonobjc func searchDisplayControllerWillBeginSearch(_ controller: UISearchController) {
        controller.searchBar.showsCancelButton = false
    }
    @nonobjc func searchDisplayControllerDidBeginSearch(_ controller: UISearchController) {
        controller.searchBar.showsCancelButton = false
        controller.searchBar.showsSearchResultsButton = false
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        self.tracksTableView.reloadData()
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        self.tracksTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != ""  && searchText.characters.count >= 2{
            api.sendRequest("select * from patients where nom LIKE 'percent\( searchText.uppercased().replace(" ", withString: "percent' AND prenom LIKE 'percent"))percent' OR prenom LIKE 'percent\(searchText.uppercased().replace(" ", withString: "percent' AND nom LIKE 'percent"))percent' OR nom LIKE 'percent\( searchText.lowercased().replace(" ", withString: "percent' AND prenom LIKE 'percent"))percent' ORDER BY prenom LIMIT 30")
            
        }
        if(filtredpatients.count == 0){
        } else {
            searchActive = true;
        }
        self.tracksTableView.reloadData()
        self.searchDisplayController?.searchResultsTableView.reloadData()
    }
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.showsSearchResultsButton = false
    }
    func renseigner(_ text:String) -> String{
        var vretour = text
        if text == "" {
            vretour = "Non renseigné"
        }
        return vretour
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height && !loading && !self.searchDisplayController!.isActive) {
            self.loading = true
            api.sendRequest("select * from patients where idpraticien=\(preference.idUser) ORDER BY id DESC limit 20 OFFSET \(tracks.count)")
        }
    }
    func didReceiveAPIResults(_ results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        DispatchQueue.main.async(execute: {
            if self.searchDisplayController!.isActive {
                self.filtredpatients = patients.patientWithJSON(resultsArr)
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }else {
                self.tracks = self.tracks + patients.patientWithJSON(resultsArr)
                
            }
            self.activityIndicator.stopActivity()
            self.activityIndicator.removeFromSuperview()
            self.tracksTableView.reloadData()
            self.loading = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //            if patients.patientWithJSON(resultsArr).count == 10{
            //            self.api.sendRequest("select * from patients where idpraticien=\(preference.idUser) limit 10 OFFSET \(self.tracks.count)")
            //            }
            
        })
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var vretour = true
        if self.isSelectingPatient {
            vretour = false
        }
        return vretour
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="toPatientTabBar"){
            let detailsViewController: TabBarViewController = segue.destination as! TabBarViewController
            var albumIndex : Int
            var selectedAlbum:patients
            if (self.searchDisplayController!.isActive){
                albumIndex = searchDisplayController!.searchResultsTableView.indexPathForSelectedRow!.row
                selectedAlbum = self.filtredpatients[albumIndex]
            }else{
                albumIndex = appsTableView!.indexPathForSelectedRow!.row
                selectedAlbum = self.tracks[albumIndex]
            }
            detailsViewController.patient = selectedAlbum
        }
        if (segue.identifier=="register"){
            let navnewpatient: NewPatientNavigationController = segue.destination as! NewPatientNavigationController
            navnewpatient.parents = self
        }
    }
    func handleError(_ results: Int) {
        if results == 1{
            api.sendRequest("select * from patients where idpraticien=\(preference.idUser) ORDER BY id DESC LIMIT 10 OFFSET 0 ")
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    @IBAction func unwindToSelectPatient(_ segue: UIStoryboardSegue) {
        
        self.tracksTableView.reloadData()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}
