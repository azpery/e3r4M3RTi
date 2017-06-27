//
//  patients.swift
//  Oremia mobile
//
//  Created by Zumatec on 23/03/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import Foundation
class patients {
    
    var id: Int
    var civilite:Int
    var idPhoto: Int
    var nom: String
    var prenom: String
    var adresse: String
    var codePostal:String
    var ville:String
    var telephone1:String
    var telephone2:String
    var email:String
    var dateNaissance:String
    var autoSMS:Bool
    var profession:String
    var photo:UIImage?
    var statut:Int
    var ids: String
    var datec:String
    var numss:String
    var info:String
    
    init(id: Int, idP:Int, nom: String, prenom: String, civilite:Int, adresse:String, codePostal:String, ville: String, tel1:String, tel2: String, email:String, dn:String, sms:Bool, profession:String, statut:Int, ids:String, datec:String, numss:String, info:String) {
        self.id = id
        self.idPhoto = idP
        self.nom = nom
        self.prenom = prenom
        self.photo = UIImage(named: "glyphicons_003_user")
        self.civilite = civilite
        self.adresse = adresse
        self.codePostal = codePostal
        self.ville = ville
        self.telephone1 = tel1
        self.telephone2 = tel2
        self.email = email
        self.dateNaissance = dn
        self.autoSMS = sms
        self.profession = profession
        self.statut = statut
        self.ids = ids
        self.datec = datec
        self.numss = numss
        self.info = info
    }
    class func patientWithJSON(_ allResults: NSArray) -> [patients] {
        
        var tracks = [patients]()
        
        if allResults.count>0 {
            for trackInfo in allResults {
                let t = trackInfo as! NSDictionary
                        let id = t["id"] as? Int ?? 0
                        let idP = t["idphoto"] as? Int ?? 0
                        let nomP = t["nom"] as? String ?? ""
                        let prenomP = t["prenom"] as? String ?? ""
                        let civilite = t["genre"] as? Int ?? 0
                        let adresse = t["adresse"] as? String ?? ""
                        let codePostal = t["codepostal"] as? String ?? ""
                        let ville = t["ville"] as? String ?? ""
                        let tel1 = t["telephone1"] as? String ?? ""
                        let tel2 = t["telephone2"] as? String ?? ""
                        let email = t["email"] as? String ?? ""
                        let dn = t["naissance"] as? String ?? ""
                        let sms = t["autorise_sms"] as? Bool ?? false
                        let profession = t["profession"] as? String ?? ""
                        let statut = t["statut"] as? Int ?? 0
                        let ids = t["profession"] as? String ?? ""
                        let datec = t["creation"] as? String ?? ""
                        let numss = t["nir"] as? String ?? ""
                        let info = t["info"] as? String ?? ""
                let track = patients(id: id, idP:idP, nom: nomP, prenom: prenomP, civilite: civilite, adresse: adresse,codePostal: codePostal,ville: ville,tel1: tel1,tel2: tel2,email: email,dn: dn,sms: sms,profession: profession, statut: statut, ids: ids, datec: datec, numss: numss, info: info)
                        tracks.append(track)
            }
        }
        return tracks
    }
    
    func getFullName() -> String {
        return "\(prenom.lowercased().capitalized) \(nom.uppercased())"
    }
}
