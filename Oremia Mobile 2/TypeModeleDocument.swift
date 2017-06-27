//
//  TypeModeleDocument.swift
//  OremiaMobile2
//
//  Created by Zumatec on 29/06/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
//
//  ModeleDocument.swift
//  OremiaMobile2
//
//  Created by Zumatec on 25/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import Foundation
class TypeModeleDocument {
    var idType: Int
    var nomType: String
    var nomFichier: String
    
    init(idType:Int,nomType:String,nomFichier:String) {
        self.idType=idType
        self.nomType=nomType
        self.nomFichier=nomFichier
        
    }
    class func convertSpecialChar(_ string: String!) -> String{
        var newString = string
        let char_dictionary = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'",
            "&#233;":"é"
        ];
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString?.replacingOccurrences(of: escaped_char, with: unescaped_char, options: NSString.CompareOptions.regularExpression, range: nil)
        }
        return newString!
        
    }
    class func typeDocumentWithJSON(_ allResults: NSArray) -> [TypeModeleDocument] {
        var document = [TypeModeleDocument]()
        if allResults.count>0 {
            for result in allResults {
                let r = result as! NSDictionary
                let idType = r["idtype"] as? Int ?? 0
                let nomType = self.convertSpecialChar(r["nomtype"] as? String) ?? ""
                let nomFichier = r["nomfichier"] as? String ?? ""
                
                let newAlbum = TypeModeleDocument(idType: idType, nomType: nomType , nomFichier: nomFichier)
                document.append(newAlbum)
            }
        }
        return document
    }
    
}
