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
    class func getTypeRDVById(_ types:[TypeRDV],id:Int) -> TypeRDV{
        var vretour:TypeRDV?
        for i in types {
            if i.id == id {
                vretour = i
            }
        }
        return vretour ?? TypeRDV()
    }
    class func typesWithJSON(_ allResults: NSArray) -> [TypeRDV] {
        var types = [TypeRDV]()
        if allResults.count>0 {
            for result in allResults {
                let r = result as! NSDictionary
                let id = r["id"] as? Int ?? 0
                let description = r["description"] as? String ?? ""
                let couleur = r["couleur"] as? String ?? ""
                let duree = r["duree"] as? Int ?? 0
                let ressources = r["ressources"] as? String ?? ""
                let idPraticien = r["idpraticien"] as? Int ?? 0
                let newAlbum = TypeRDV(id: id, description: description, couleur: couleur, duree: duree, ressources: ressources, idPraticien: idPraticien)
                types.append(newAlbum)
            }
        }
        
        return types
    }
}
