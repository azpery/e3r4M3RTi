//
//  Actes.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 22/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import Foundation
class Actes{
    var id: Int
    var idDocument:Int
    var date: String
    var localisation: Int
    var lettre: String
    var cotation:Int
    var descriptif:String
    var montant:String
    
    init(id:Int,idDocument:Int,date:String,localisation: Int,lettre: String,cotation:Int,descriptif:String,montant:String) {
        self.id=id
        self.idDocument = idDocument
        self.date=date
        self.localisation=localisation
        self.lettre = lettre
        self.cotation=cotation
        self.descriptif = descriptif
        self.montant = montant        
    }
    class func actesWithJSON(allResults: NSArray) -> [Actes] {
        var actes = [Actes]()
        if allResults.count>0 {
            for result in allResults {
                let id = result["id"] as? Int ?? 0
                let idDocument = result["iddocument"] as? Int ?? 0
                let date = result["date"] as? String ?? ""
                let localisation = result["localisation"] as? Int ?? 0
                let lettre = result["lettre"] as? String ?? ""
                let cotation = result["cotation"] as? Int ?? 0
                let descriptif = result["description"] as? String ?? ""
                let montant = result["montant"] as? String ?? ""
                
                let newAlbum = Actes(id: id, idDocument: idDocument, date: date, localisation: localisation, lettre: lettre, cotation: cotation, descriptif: descriptif, montant: montant)
                actes.append(newAlbum)
            }
        }
        return actes
    }
    class func sortInDict(var allResults: [Actes]) -> [String:[Actes]] {
        var lesSectionActes = [String:[Actes]]()
        var lesActes = [Actes]()
        while allResults.count>0 {
            var section:String?
            for var i=0; i < allResults.count; i++ {
                if(section == nil){
                    section = allResults[i].lettre
                    lesActes.append(allResults[i])
                    allResults.removeAtIndex(i)
                } else if(allResults[i].lettre == section){
                    lesActes.append(allResults[i])
                    allResults.removeAtIndex(i)
                }
            }
            lesSectionActes[section!] = lesActes
            section = nil
            lesActes.removeAll()
        }
        return lesSectionActes
    }
}