//
//  Prestation.swift
//  OremiaMobile2
//
//  Created by Zumatec on 28/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
class Prestation{
    var nom: Int
    var coefficient:Int
    var description: String
    var qualificatif: String
    var lettreCle: String
    var coefficientEnft:Int
    var image:String
    var montant:String
    
    init(nom:Int,coefficient:Int,description: String,lettreCle: String, qualificatif:String,coefficientEnft:Int,image:String,montant:String) {
        self.nom = nom
        self.coefficient = coefficient
        self.description = description
        self.lettreCle = lettreCle
        self.qualificatif = qualificatif
        self.coefficientEnft = coefficientEnft
        self.image = image
        self.montant = montant
    }
    
    func findMontantByLettreCle(){
        let api = APIController()
        api.sendRequest("SELECT tarif FROM ccam WHERE code = '\(self.lettreCle)'",success: {results in
            let dictRes = results["results"] as? NSArray ?? [""]
            let res = dictRes!.count > 0 ? dictRes![0] as? NSDictionary ?? ["tarif":"0.00"] : ["tarif":"0.00"]
            self.montant = res["tarif"] as! String
            return true
        })
    }
    
    class func prestationWithJSON(allResults: NSArray) -> [Prestation] {
        var prestations = [Prestation]()
        if allResults.count>0 {
            for value in allResults {
                let nom =  value["nom"] as? String  ?? "Prestation_0"
                let ordre = Int(nom.replace("Prestation_", withString: "")) ?? 0
                let coefficient = Int(value["Coefficient"] as? String ?? "0") ?? 0
                let description = value["Description"] as? String  ?? ""
                let qualificatif = value["Qualificatif"] as? String ?? ""
                let lettreCle = value["LettreCle"] as? String ?? ""
                let coefficientEnft = Int(value["CoefficientEnft"] as? String ?? "0") ?? 0
                let image = value["Image"] as? String ?? ""
                var needMontant = false
                if value["Montant"] as? String == nil{
                    needMontant = true
                }
                let montant = value["Montant"] as? String ?? "0,00"
                
                let newPrest = Prestation(nom: ordre, coefficient: coefficient, description: description, lettreCle: lettreCle,qualificatif:qualificatif, coefficientEnft: coefficientEnft, image: image, montant: montant)
                if needMontant{
                    newPrest.findMontantByLettreCle()
                }
                prestations.append(newPrest)
            }
        }
        return prestations
    }

}