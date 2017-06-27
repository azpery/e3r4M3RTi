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
    var idPatient:Int
    var date: String
    var localisation: Int
    var lettre: String
    var cotation:Int
    var descriptif:String
    var montant:String
    
    init(){
        self.id=0
        self.idDocument = 0
        self.date=""
        self.localisation=0
        self.lettre = ""
        self.cotation=0
        self.descriptif = ""
        self.montant = ""
        self.idPatient = 0
    }
    
    init(id:Int,idDocument:Int,date:String,localisation: Int,lettre: String,cotation:Int,descriptif:String,montant:String) {
        self.id=id
        self.idDocument = idDocument
        self.date=date
        self.localisation=localisation
        self.lettre = lettre
        self.cotation=cotation
        self.descriptif = descriptif
        self.montant = montant
        self.idPatient = 0
    }
    class func actesWithJSON(_ allResults: NSArray) -> [Actes] {
        var actes = [Actes]()
        if allResults.count>0 {
            for result in allResults {
                let r = result as! NSDictionary
                let id = r["id"] as? Int ?? 0
                let idDocument = r["iddocument"] as? Int ?? 0
                let date = r["date"] as? String ?? ""
                let localisation = r["localisation"] as? Int ?? 0
                let lettre = r["lettre"] as? String ?? ""
                let cotation = r["cotation"] as? Int ?? 0
                let descriptif = r["description"] as? String ?? ""
                let montant = r["montant"] as? String ?? ""
                
                let newAlbum = Actes(id: id, idDocument: idDocument, date: date, localisation: localisation, lettre: lettre, cotation: cotation, descriptif: descriptif, montant: montant)
                actes.append(newAlbum)
            }
        }
        return actes
    }
    class func sortInDict(_ allResults: [Actes]) -> [String:[Actes]] {
        var allResults = allResults
        var lesSectionActes = [String:[Actes]]()
        var lesActes = [Actes]()
        while allResults.count>0 {
            var section:String?
            for i in 0 ..< allResults.count {
                
                if(section == nil){
                    section = allResults[i].lettre
                    lesActes.append(allResults[i])
                    allResults.remove(at: i)
                } else if(i < allResults.count && allResults[i].lettre == section){
                    lesActes.append(allResults[i])
                    allResults.remove(at: i)
                }
                //c = allResults.count - 1
            }
            if section != nil {
                lesSectionActes[section!] = lesActes
                section = nil
                lesActes.removeAll()
            }
        }
        return lesSectionActes
    }
}
