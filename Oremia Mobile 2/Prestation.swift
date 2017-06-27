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
            let res = dictRes.count > 0 ? dictRes[0] as? NSDictionary ?? ["tarif":"0.00"] : ["tarif":"0.00"]
            self.montant = res["tarif"] as! String
            return true
        })
    }
    
    class func prestationWithJSON(_ allResults: NSArray) -> (favoris:[Prestation], favorisPlus: [[String:[Prestation]]]) {
        var prestations = [Prestation]()
        if allResults.count>0 {
            for value in allResults {
                let v = value as! NSDictionary
                let nom =  v["nom"] as? String  ?? "Prestation_0"
                let ordre = Int(nom.replace("Prestation_", withString: "")) ?? 0
                let coefficient = Int(v["Coefficient"] as? String ?? "0") ?? 0
                let description = v["Description"] as? String  ?? ""
                let qualificatif = v["Qualificatif"] as? String ?? ""
                let lettreCle = v["LettreCle"] as? String ?? ""
                let coefficientEnft = Int(v["CoefficientEnft"] as? String ?? "0") ?? 0
                let image = v["Image"] as? String ?? ""
                var needMontant = false
                if v["Montant"] as? String == nil{
                    needMontant = true
                }
                let montant = v["Montant"] as? String ?? "0,00"
                
                let newPrest = Prestation(nom: ordre, coefficient: coefficient, description: description, lettreCle: lettreCle,qualificatif:qualificatif, coefficientEnft: coefficientEnft, image: image, montant: montant)
                if needMontant{
                    newPrest.findMontantByLettreCle()
                }
                prestations.append(newPrest)
            }
        }
        prestations = prestations.sorted(by: {$0.nom < $1.nom})
        
        
        
        return dispatchPrestation(prestations)
    }
    
    class func dispatchPrestation(_ allPrestations: [Prestation]) -> (favoris:[Prestation], favorisPlus: [[String:[Prestation]]]) {
        var favoris:[Prestation] = []
        var favorisPlus:[String:[Prestation]] = [:]
        var arrayFavoris = [[String:[Prestation]]]()
        
        var isPlusPassed = false
        var index = 1
        var parent = ""
        favorisPlus["-favoris"] = []
        for presation in allPrestations {
            let description = presation.description ?? "Aucune description disponible"
            
            if description.range(of: "Plus...") != nil{
                isPlusPassed = true
            }
            
            if !isPlusPassed {
                favorisPlus["-favoris"]?.append(presation)
                favoris.append(presation)
            }else{
                index = 1
                if description.range(of: "-") != nil {
                    index = description.characters.distance(from: description.startIndex, to: (description.range(of: "-")?.lowerBound)!)
                }
                
                if index == 0 {
                    arrayFavoris.append(favorisPlus)
                    parent = description
                    favorisPlus = [String:[Prestation]]()
                    favorisPlus[parent] = []
                }else{
                    favorisPlus[parent]?.append(presation)
                }
            }
        }
        arrayFavoris.append(favorisPlus)
        
        
        return (favoris, arrayFavoris)
    }

}
