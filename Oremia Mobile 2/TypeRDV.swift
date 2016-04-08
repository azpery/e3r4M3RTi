//
//  TypeRDV.swift
//  OremiaMobile2
//
//  Created by Zumatec on 11/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import Foundation
class TypeRDV{
    var id:Int = 0
    var description:String = ""
    var couleur:String = ""
    var duree:Int = 0
    var ressources:String = ""
    var idPraticien:Int = 0
    init(id:Int,description:String,couleur:String,duree:Int,ressources:String,idPraticien:Int){
        self.id = id
        self.description = description
        self.couleur = couleur
        self.duree = duree
        self.ressources = ressources
        self.idPraticien = idPraticien
    }
    init(){
    }
    class func getTypeRDVById(types:[TypeRDV],id:Int) -> TypeRDV{
        var vretour:TypeRDV?
        for var i in types {
            if i.id == id {
                vretour = i
            }
        }
        return vretour ?? TypeRDV()
    }
    class func typesWithJSON(allResults: NSArray) -> [TypeRDV] {
        var types = [TypeRDV]()
        if allResults.count>0 {
            for result in allResults {
                let id = result["id"] as? Int ?? 0
                let description = result["description"] as? String ?? ""
                let couleur = result["couleur"] as? String ?? ""
                let duree = result["duree"] as? Int ?? 0
                let ressources = result["ressources"] as? String ?? ""
                let idPraticien = result["idpraticien"] as? Int ?? 0
                let newAlbum = TypeRDV(id: id, description: description, couleur: couleur, duree: duree, ressources: ressources, idPraticien: idPraticien)
                types.append(newAlbum)
            }
        }
        
        return types
    }
}