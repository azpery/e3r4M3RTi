//
//  PrestationActe.swift
//  OremiaMobile2
//
//  Created by Zumatec on 28/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
class PrestationActe:Prestation{
    var numDent:Int
    var dateActe:String
    
    init(nom:String,coefficient:Int,description: String,lettreCle: String,coefficientEnft:Int,image:String,montant:String, numDent:Int, dateActe:String) {
        self.dateActe = dateActe
        self.numDent = numDent
        super.init(nom: nom, coefficient: coefficient, description: description, lettreCle: lettreCle, coefficientEnft: coefficientEnft, image: image, montant: montant)
    }
    class func prestationActesWithJSON(allResults: NSArray) -> [PrestationActe] {
        var prestations = [PrestationActe]()
        if allResults.count>0 {
            for  value in allResults {
                    let nom =  ""
                    let coefficient = Int(value["Coefficient"] as? String ?? "0") ?? 0
                    let description = value["Description"] as? String  ?? ""
                    let lettreCle = value["LettreCle"] as? String ?? ""
                    let coefficientEnft = Int(value["CoefficientEnft"] as? String ?? "0") ?? 0
                    let image = value["Image"] as? String ?? ""
                    let montant = value["Montant"] as? String ?? "0,00"
                    let numDent = Int(value["NumDent"] as? String ?? "0") ?? 0
                    let dateActe = value["dateActe"] as? String ?? "0/0/0"
                    let newPrest = PrestationActe(nom: nom, coefficient: coefficient, description: description, lettreCle: lettreCle, coefficientEnft: coefficientEnft, image: image, montant: montant, numDent: numDent, dateActe: dateActe)
                    prestations.append(newPrest)
                }
        }
        return prestations
    }
    
}