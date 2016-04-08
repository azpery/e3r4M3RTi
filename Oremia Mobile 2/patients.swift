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
    class func patientWithJSON(allResults: NSArray) -> [patients] {
        
        var tracks = [patients]()
        
        if allResults.count>0 {
            for trackInfo in allResults {
                        let id = trackInfo["id"] as? Int ?? 0
                        let idP = trackInfo["idphoto"] as? Int ?? 0
                        let nomP = trackInfo["nom"] as? String ?? ""
                        let prenomP = trackInfo["prenom"] as? String ?? ""
                        let civilite = trackInfo["genre"] as? Int ?? 0
                        let adresse = trackInfo["adresse"] as? String ?? ""
                        let codePostal = trackInfo["codepostal"] as? String ?? ""
                        let ville = trackInfo["ville"] as? String ?? ""
                        let tel1 = trackInfo["telephone1"] as? String ?? ""
                        let tel2 = trackInfo["telephone2"] as? String ?? ""
                        let email = trackInfo["email"] as? String ?? ""
                        let dn = trackInfo["naissance"] as? String ?? ""
                        let sms = trackInfo["autorise_sms"] as? Bool ?? false
                        let profession = trackInfo["profession"] as? String ?? ""
                        let statut = trackInfo["statut"] as? Int ?? 0
                        let ids = trackInfo["profession"] as? String ?? ""
                        let datec = trackInfo["creation"] as? String ?? ""
                        let numss = trackInfo["nir"] as? String ?? ""
                        let info = trackInfo["info"] as? String ?? ""
                let track = patients(id: id, idP:idP, nom: nomP, prenom: prenomP, civilite: civilite, adresse: adresse,codePostal: codePostal,ville: ville,tel1: tel1,tel2: tel2,email: email,dn: dn,sms: sms,profession: profession, statut: statut, ids: ids, datec: datec, numss: numss, info: info)
                        tracks.append(track)
            }
        }
        return tracks
    }
}