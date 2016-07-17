//
//  Evenement.swift
//  OremiaMobile2
//
//  Created by Zumatec on 10/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import Foundation
import EventKit

@objc class Evennement :  NSObject, APIControllerProtocol{
    var idEvent : String = ""
    var eventManager:EventManager?
    var event : EKEvent?
    lazy var api : APIController = APIController(delegate: self)
    var idPatient:Int = 0
    var statut: Int = 0
    var modele: Int = 0
    var descriptionModele:String  = ""
    var dureeModele: Int = 0
    var ressources:String = ""
    var location = UILabel()
    var cell:MSEventCell?
    var statutView:UIView?
    var patient:patients?
    var callback:(()->())?
    override init() {
        super.init()
    }
    init (event :EKEvent, statut:UIView, cell:MSEventCell, eventManager:EventManager){
        super.init()
        self.event = event
        self.statutView = statut
        self.cell = cell
        self.eventManager = eventManager
        let mabite = event.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
        if mabite.count>0{
            let ressources = eventManager.CalDavRessource?[mabite[1]] as? String
            dispatch_async(dispatch_get_main_queue(), {
                self.statutView?.hidden = false
                if ressources != nil {
                    self.findRessources(ressources!)
                } else if(event.calendar.source.title == "iCloud"){
                    self.api.sendRequest("select e.statut as statutrdv,m.description, e.idPatient,e.modele, p.id, p.nir, p.genre, p.nom, p.prenom, p.adresse, p.codepostal, p.ville, p.telephone1,p.telephone2, p.email,p.statut, p.naissance, p.creation, p.idpraticien, p.idphoto,p.info, p.autorise_sms, p.correspondant, p.ipp2, p.adresse2, p.patient_par,amc, p.amc_prefs, p.profession, p.correspondants,p.famille,p.tel1_info, p.tel2_info FROM calendar_events e FULL OUTER JOIN calendar_events_modeles m ON e.modele = m.id INNER JOIN patients p ON p.id = e.idPatient WHERE e.idevent = '\(mabite[1])'")
                }
            })
            dispatch_async(dispatch_get_main_queue(), {
                self.updateStatut()
            })
        } else {
            statutView?.hidden = true
        }
        
    }
    func loadPatient(callback:()->()){
        if(idPatient != 0){
            self.api.sendRequest("select * FROM patients  WHERE id = '\(idPatient)'")
            self.callback = callback
        }
    }
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            if resultsArr.count > 0 {
                self.idPatient = resultsArr[0]["id"] as? Int ?? self.idPatient
                self.statut = resultsArr[0]["statutrdv"] as? Int ?? self.statut
                self.modele = resultsArr[0]["modele"] as? Int ?? self.modele
                self.descriptionModele = resultsArr[0]["description"] as? String ?? self.descriptionModele
                self.cell?.updateLocation(self.descriptionModele)
                self.dureeModele = resultsArr[0]["duree"] as? Int ?? 0
                self.ressources = resultsArr[0]["ressources"] as? String ?? ""
                self.updateStatut()
                self.patient = patients.patientWithJSON(resultsArr)[0]
                if let callback = self.callback {
                    callback()
                }
                if ((resultsArr[0]["nom"] as? String ) == nil){
                    self.eventManager?.agenda?.reloadCalendars()
                }
            }
            
            
        })
    }
    func findRessources(ressources:String){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let a = ressources.componentsSeparatedByString(";")
            var d:[String]
            var e:[String]
            var val:String
            for b in a {
                d = b.componentsSeparatedByString("X-ORE-")
                for c in d {
                    e = c.componentsSeparatedByString("=")
                    if e.count > 1 {
                        val = e[1].stringByReplacingOccurrencesOfString("%", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        switch e[0]{
                        case "IPP":
                            self.idPatient = Int(val)!
                            break
                        case "STATUT":
                            self.statut = Int(val)!
                            break
                        case "TYPE":
                            self.modele = Int(val)!
                            self.descriptionModele = TypeRDV.getTypeRDVById(self.eventManager!.TypesRDV, id: self.modele).description
                            break
                        default:
                            break
                        }
                    }
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.updateStatut()
                self.cell?.updateLocation(self.descriptionModele)
            })
        });
    }
    func updateEvent() {
        let mabite = event!.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
        if mabite.count>0 && event?.calendar.source.title == "iCloud"{
            api.sendRequest("UPDATE calendar_events SET idpatient=\(idPatient), statut=\(statut), modele=\(modele), ressources='\(ressources)' WHERE idevent='\(mabite[1])';")
            //            print("UPDATE calendar_events SET idpatient=\(idPatient), statut=\(statut), modele=\(modele), ressources='\(ressources)' WHERE idevent='\(mabite[1])';")
        }
    }
    func updateCalDavEvent(uid:String, initialDate:NSDate?) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        let dtstart = dateFormatter.stringFromDate((event?.startDate)!)
        let dtend = dateFormatter.stringFromDate((event?.endDate)!)
        let summary = event?.title
        self.updateStatut()
        api.setCalDavRessources(uid, ipp: idPatient, statut: statut, dtstart: dtstart, dtend: dtend, summary: summary!, title: event!.calendar.title, type: self.modele, date: initialDate)
    }
    func deleteEvent() {
        let mabite = event!.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
        if mabite.count>0{
            api.sendRequest("DELETE FROM calendar_events WHERE idevent='\(mabite[1])';")
        }
    }
    func insertEvent() {
        let mabite = event!.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
        if mabite.count>0{
            api.sendRequest("INSERT INTO calendar_events( idevent, idpatient, statut, modele, ressources) VALUES ('\(mabite[1])', \(idPatient), \(statut), \(modele), '\(ressources)');")
        }
    }
    func getLibelleStatut()->String{
        var vretour=""
        switch self.statut % 10{
        case 1 :
            vretour = "À l'heure"
            break
        case 2 :
            vretour = "En retard"
            break
        case 3 :
            vretour = "Retard important"
            break
        case 4 :
            vretour = "Annulé avant 48 heures"
            break
        case 5 :
            vretour = "Absence"
            break
        case 6 :
            vretour = "Annulé"
            break
        default:
            vretour = "Présence non renseignée"
            break
        }
        return vretour
    }
    func updateStatut() {
        dispatch_async(dispatch_get_main_queue(), {
            switch self.statut % 10{
            case 1 :
                self.statutView?.backgroundColor = ToolBox.UIColorFromRGB(0x26A65B)
                break
            case 2 :
                self.statutView?.backgroundColor = ToolBox.UIColorFromRGB(0xF89406)
                break
            case 3 :
                self.statutView?.backgroundColor = ToolBox.UIColorFromRGB(0xD35400)
                break
            case 4 :
                self.statutView?.backgroundColor = ToolBox.UIColorFromRGB(0xC0392B)
                break
            case 5 :
                self.statutView?.backgroundColor = ToolBox.UIColorFromRGB(0x96281B)
                break
            case 6 :
                self.statutView?.backgroundColor = ToolBox.UIColorFromRGB(0xC0392B)
                break
            default:
                self.statutView?.backgroundColor = ToolBox.UIColorFromRGB(0x2C3E50)
                break
            }
        })
    }
    func handleError(results: Int) {
        if results == 1{
            let mabite = event!.eventIdentifier.characters.split{$0 == ":"}.map(String.init)
            if mabite.count>0{
                let ressources = eventManager!.CalDavRessource?[mabite[1]] as? String
                dispatch_async(dispatch_get_main_queue(), {
                    self.statutView?.hidden = false
                    if ressources != nil {
                        self.findRessources(ressources!)
                    } else {
                        //                        self.api.sendRequest("select e.statut as statutrdv,m.description, e.idPatient,e.modele, p.id, p.nir, p.genre, p.nom, p.prenom, p.adresse, p.codepostal, p.ville, p.telephone1,p.telephone2, p.email,p.statut, p.naissance, p.creation, p.idpraticien, p.idphoto,p.info, p.autorise_sms, p.correspondant, p.ipp2, p.adresse2, p.patient_par,amc, p.amc_prefs, p.profession, p.correspondants,p.famille,p.tel1_info, p.tel2_info FROM calendar_events e FULL OUTER JOIN calendar_events_modeles m ON e.modele = m.id INNER JOIN patients p ON p.id = e.idPatient WHERE e.idevent = '\(mabite[1])'")
                    }
                })
            }
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
}