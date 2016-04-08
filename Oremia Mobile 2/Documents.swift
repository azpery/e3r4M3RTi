//
//  File.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 21/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import Foundation
class Document {
    var id: Int
    var nom: String
    var date: String
    
    init(id:Int,nom:String,date:String) {
        self.id=id
        self.nom=nom
        self.date=date
        
    }
    class func documentWithJSON(allResults: NSArray) -> [Document] {
        var document = [Document]()
        if allResults.count>0 {
            for result in allResults {
                let id = result["id"] as? Int
                let nom = result["nom"] as? String
                let date = result["date"] as? String
                
                let newAlbum = Document(id: id!, nom: nom!, date: date!)
                document.append(newAlbum)
            }
        }
        return document
    }
}