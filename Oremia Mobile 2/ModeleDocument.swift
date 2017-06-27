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
    class func documentWithJSON(_ allResults: NSArray) -> [ModeleDocument] {
        var document = [ModeleDocument]()
        if allResults.count>0 {
            for result in allResults {
                let r = result as! NSDictionary
                let id = r["iddocument"] as? Int
                _ = "Any-Hex/Java"
                let nom = self.convertSpecialChar(r["nomtype"] as? String)
                let date = r["date"] as? String
                
                let newAlbum = ModeleDocument(idDocument: id!, nomDocument: nom , date: date!)
                document.append(newAlbum)
            }
        }
        return document
    }
    
}
