//
//  ModeleDocument.swift
//  OremiaMobile2
//
//  Created by Zumatec on 25/11/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import Foundation
class ModeleDocument {
    var idDocument: Int
    var nomDocument: String
    var date: String
    
    init(idDocument:Int,nomDocument:String,date:String) {
        self.idDocument=idDocument
        self.nomDocument=nomDocument
        self.date=date
        
    }
    class func convertSpecialChar(string: String!) -> String{
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
            newString = newString.stringByReplacingOccurrencesOfString(escaped_char, withString: unescaped_char, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        }
        return newString
        
    }
    class func documentWithJSON(allResults: NSArray) -> [ModeleDocument] {
        var document = [ModeleDocument]()
        if allResults.count>0 {
            for result in allResults {
                let id = result["iddocument"] as? Int
                _ = "Any-Hex/Java"
                let nom = self.convertSpecialChar(result["nomtype"] as? String)
                let date = result["date"] as? String
                
                let newAlbum = ModeleDocument(idDocument: id!, nomDocument: nom , date: date!)
                document.append(newAlbum)
            }
        }
        return document
    }
    
}