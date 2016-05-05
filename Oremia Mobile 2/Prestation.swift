//
//  Prestation.swift
//  OremiaMobile2
//
//  Created by Zumatec on 28/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
class Prestation{
    var nom: String
    var coefficient:Int
    var description: String
    var lettreCle: String
    var coefficientEnft:Int
    var image:String
    var montant:String
    
    init(nom:String,coefficient:Int,description: String,lettreCle: String,coefficientEnft:Int,image:String,montant:String) {
        self.nom = nom
        self.coefficient = coefficient
        self.description = description
        self.lettreCle = lettreCle
        self.coefficientEnft = coefficientEnft
        self.image = image
        self.montant = montant
    }
    class func prestationWithJSON(allResults: NSArray) -> [Prestation] {
        var prestations = [Prestation]()
        if allResults.count>0 {
            for value in allResults {
                let nom =  ""
                let coefficient = Int(value["Coefficient"] as? String ?? "0") ?? 0
                let description = value["Description"] as? String  ?? ""
                let lettreCle = value["LettreCle"] as? String ?? ""
                let coefficientEnft = Int(value["CoefficientEnft"] as? String ?? "0") ?? 0
                let image = value["Image"] as? String ?? ""
                let montant = value["Montant"] as? String ?? ""
                
                let newPrest = Prestation(nom: nom, coefficient: coefficient, description: description, lettreCle: lettreCle, coefficientEnft: coefficientEnft, image: image, montant: montant)
                prestations.append(newPrest)
            }
        }
        return prestations
    }

}