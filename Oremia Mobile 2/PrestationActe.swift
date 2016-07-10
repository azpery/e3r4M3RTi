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
    
    init(nom:Int,coefficient:Int,description: String,lettreCle: String, qualificatif:String, coefficientEnft:Int,image:String,montant:String, numDent:Int, dateActe:String) {
        self.dateActe = dateActe
        self.numDent = numDent
        super.init(nom: nom, coefficient: coefficient, description: description, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: coefficientEnft, image: image, montant: montant)
    }
    class func prestationActesWithJSON(allResults: NSArray) -> [PrestationActe] {
        var prestations = [PrestationActe]()
        if allResults.count>0 {
            for  value in allResults {
                let nom =  value["nom"] as? String  ?? "Prestation_0"
                let ordre = Int(nom.replace("Prestation_", withString: "")) ?? 0
                let coefficient = Int(value["Coefficient"] as? String ?? "0") ?? 0
                let description = value["Description"] as? String  ?? ""
                let lettreCle = value["LettreCle"] as? String ?? ""
                let qualificatif = value["Qualificatif"] as? String ?? ""
                let coefficientEnft = Int(value["CoefficientEnft"] as? String ?? "0") ?? 0
                let image = value["Image"] as? String ?? ""
                let montant = value["Montant"] as? String ?? "0,00"
                let numDent = Int(value["NumDent"] as? String ?? "0") ?? 0
                let dateActe = value["dateActe"] as? String ?? "0/0/0"
                let newPrest = PrestationActe(nom: ordre, coefficient: coefficient, description: description, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: coefficientEnft, image: image, montant: montant, numDent: numDent, dateActe: dateActe)
                prestations.append(newPrest)
            }
        }
        return prestations
    }
    class func prestationToFormattedOutput(patient:patients,prestations:[PrestationActe]) -> NSString?{
        do{
            var vretour = [String:[String:AnyObject]]()
            vretour["Entete"] = ["Naissance":patient.dateNaissance,"Nom":patient.nom,"Prenom":patient.prenom,"TiersComplementaire":"0","TiersPrincipal":"0"]
            var i = 0
            for presta  in prestations {
                vretour["Prestation_\(i)"] = ["Coefficient":presta.coefficient,"Description":presta.description,"LettreCle":presta.lettreCle,"Montant":presta.montant,"dateActe":presta.dateActe,"Image":presta.image,"NumDent":presta.numDent, "Qualificatif":presta.qualificatif]
                i += 1
            }
            let data = try NSJSONSerialization.dataWithJSONObject(vretour, options: NSJSONWritingOptions.PrettyPrinted)
            let string = NSString(data: data, encoding: NSUTF8StringEncoding)
            return string
            
        }
        catch{
            return nil
        }
        
    }
    
}