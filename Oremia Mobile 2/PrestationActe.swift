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
    var note:String=""
    
    init(nom:Int,coefficient:Int,description: String,lettreCle: String, qualificatif:String, coefficientEnft:Int,image:String,montant:String, numDent:Int, dateActe:String) {
        self.dateActe = dateActe
        self.numDent = numDent
        super.init(nom: nom, coefficient: coefficient, description: description, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: coefficientEnft, image: image, montant: montant)
        self.extractNote()
    }
    class func prestationActesWithJSON(_ allResults: NSArray) -> [PrestationActe] {
        var prestations = [PrestationActe]()
        if allResults.count>0 {
            for  value in allResults {
                let v = value as! NSDictionary
                let nom =  v["nom"] as? String  ?? "Prestation_0"
                let ordre = Int(nom.replace("Prestation_", withString: "")) ?? 0
                let coefficient = Int(v["Coefficient"] as? String ?? "0") ?? 0
                let description = v["Description"] as? String  ?? ""
                let lettreCle = v["LettreCle"] as? String ?? ""
                let qualificatif = v["Qualificatif"] as? String ?? ""
                let coefficientEnft = Int(v["CoefficientEnft"] as? String ?? "0") ?? 0
                let image = v["Image"] as? String ?? ""
                let montant = v["Montant"] as? String ?? "0,00"
                let numDent = Int(v["NumDent"] as? String ?? "0") ?? 0
                let dateActe = v["dateActe"] as? String ?? "0/0/0"
                let newPrest = PrestationActe(nom: ordre, coefficient: coefficient, description: description, lettreCle: lettreCle, qualificatif:qualificatif, coefficientEnft: coefficientEnft, image: image, montant: montant, numDent: numDent, dateActe: dateActe)
                prestations.append(newPrest)
            }
        }
        return prestations
    }
    class func prestationToFormattedOutput(_ patient:patients,prestations:[PrestationActe]) -> NSString?{
        do{
            var vretour = [String:[String:AnyObject]]()
            vretour["Entete"] = ["Naissance":patient.dateNaissance as AnyObject,"Nom":patient.nom as AnyObject,"Prenom":patient.prenom as AnyObject,"TiersComplementaire":"0" as AnyObject,"TiersPrincipal":"0" as AnyObject]
            var i = 1
            for presta  in prestations {
                vretour["Prestation_\(i)"] = ["Coefficient":presta.coefficient as AnyObject,"Description":presta.getDescription() as AnyObject,"LettreCle":presta.lettreCle as AnyObject,"Montant":presta.montant as AnyObject,"dateActe":presta.dateActe as AnyObject,"Image":presta.image as AnyObject,"NumDent":presta.numDent as AnyObject, "Qualificatif":presta.qualificatif as AnyObject]
                i += 1
            }
            let data = try JSONSerialization.data(withJSONObject: vretour, options: JSONSerialization.WritingOptions.prettyPrinted)
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            return string
            
        }
        catch{
            return nil
        }
        
    }
    
    func getDescription()->String{
        if note != "" {
            return self.description+"\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t#RNID="+self.note
        }
        return self.description
    }
    
    func extractNote(){
        if self.description.contains("#RNID="){
            let range = self.description.range(of: "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t#RNID=")!
            let original = self.description
    self.description = original.substring(to: range.lowerBound)
            self.note = original.substring(from: range.upperBound)
        }
    }
    
}
