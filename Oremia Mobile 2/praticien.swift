//
//  Album.swift
//  Oremia mobile
//
//  Created by Zumatec on 08/03/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import Foundation
class Praticien {
    var id: Int
    var nom: String
    var prenom: String
    var licence:Int
    
    init(id:Int,nom:String,prenom:String, licence:Int) {
        self.id = id
        self.nom = nom
        self.prenom = prenom
        self.licence = licence
    }
    class func praticienWithJSON(allResults: NSArray) -> [Praticien] {
        var praticien = [Praticien]()
        if allResults.count>0 {
            for result in allResults {
                let id : Int = result["id"] as? Int ?? 0
                let nom = result["nom"] as? String ?? ""
                let prenom = result["prenom"] as? String ?? ""
                let licence = result["licence"] as? Int ?? 0
                let newAlbum = Praticien(id: id, nom: nom, prenom: prenom, licence: licence)
                praticien.append(newAlbum)
            }
        }
        return praticien
    }
}