
//
//  APIController.swift
//  Oremia mobile
//
//  Created by Zumatec on 07/03/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import Foundation
@objc class APIController:NSObject {
    var delegate: APIControllerProtocol?
    var context: AnyObject?
    var itunesSearchTerm: String?
    var canStartPinging = false

    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    override init() {
        
    }
    func getIniFile(type: String) {
            let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=14"
            get(urlPath, searchString: "query=\(type)")
    }
    func checkFileUpdate() {
        let urlPath = "http://\(preference.ipServer)/scripts/updater.php"
        get(urlPath, searchString: "query='')")
    }
    func sendRequest(searchString: String) {
        self.itunesSearchTerm = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if let _ = itunesSearchTerm!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=1"
            get(urlPath, searchString: "query=\(searchString)")
        }
    }
    func getCalDavRessources(var date:NSDate? = nil){
        if date == nil {
            date = NSDate()
        }
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/getEvents.php?idP=\(preference.idUser)&date=\(ToolBox.getFormatedDate(date!))"
        get(urlPath, searchString: "query=\("")")
    }
    func setCalDavRessources(uid:String,ipp:Int,statut:Int,dtstart:String,dtend:String,summary:String,title:String, type:Int){
        if let newsummary = summary.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let newTitle = title.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/setEvent.php?UID=\(uid)&IPP=\(ipp)&STATUT=\(statut)&DTSTART=\(dtstart)&DTEND=\(dtend)&SUMMARY=\(newsummary)&TITLE=\(newTitle!)&idP=\(preference.idUser)&TYPE=\(type)"
            get(urlPath, searchString: "query=\("")")
        }
    }
    func setConnexion() {
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=0"
        get(urlPath, searchString: "dbname=\(connexionString.db)&user=\(connexionString.login)&pw=\(connexionString.pw)")
    }
    func selectpraticien() {
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=2"
        get(urlPath, searchString: "query=select id,nom,prenom from praticiens&dbname=\(connexionString.db)&user=\(connexionString.login)&pw=\(connexionString.pw) order by id")
    }
    func sendInsert(searchString: String) {
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=1"
        insert(urlPath, searchString: "query=\(searchString)")
    }
    func insertImage(image:UIImage, idPatient:Int){
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/?type=7&&idPatient=\(idPatient)&&idPraticien=\(preference.idUser)"
        sendImage(image, path: urlPath)
    }
    func lookupAlbum(collectionId: Int) {
        sendRequest("select * from patients")
    }
    func pingServer(){
        let url = "\(preference.ipServer)"
        SimplePingHelper.ping(url, target: self.delegate, sel: "pingResult:")
    }

    func get(path: String, searchString:String) {
        if let url = NSURL(string: path) {
            
            let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 3600)
            request.HTTPMethod = "POST"
            let postString = searchString
            let postLength:NSString = String( postString.characters.count )
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)!
            let body = request.HTTPBody!.description
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if(error != nil) {
                            print(error!.localizedDescription)
                            self.delegate!.handleError(1)
                        }else {
                            print(response)
                            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("responseString = \(responseString)")
                            var jsonResult: NSDictionary?
                            do {
                                jsonResult = (try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
                                if jsonResult != nil {
                                    self.delegate!.didReceiveAPIResults(jsonResult!)
                                } else {
                                    self.delegate!.handleError(1)
                                }
                            } catch {
                                self.delegate!.handleError(1)
                            }
                        }
                    } else if httpResponse.statusCode == 404{
                        self.delegate!.handleError(1)
                    }else if httpResponse.statusCode == 406{
                        self.delegate!.handleError(2)
                    }else if httpResponse.statusCode == 502{
                        self.delegate!.didReceiveAPIResults(["results":"Success"])
                    }else {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            if let vc = UIApplication.topViewController(){
                                let alert = UIAlertController(title: "Alerte", message: "Une erreur est survenue lors de l'accès à l'URL:\(path) du serveur.\n Requête :\(searchString).\n Si cette erreur s'affiche, il est possible que l'application plante ou qu'il y ait certains disfonctionnements.\n Veuillez nous excuser pour la gêne occasionnée et contactez le service technique si ce problème persiste. \n Erreur \(httpResponse.statusCode)", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                vc.presentViewController(alert, animated: true, completion: nil)
                                
                            }
                        })
                    }
                }else  {
                    self.delegate!.handleError(1)
                }
            })
            task.resume()
        } else {
            delegate!.handleError(1)
        }
    }

    func insert(path:String, searchString:String){
        if let url = NSURL(string: path) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let postString = searchString
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                print("Task completed")
                print(response)
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("responseString = \(responseString)")
                if(error != nil) {
                    print(error!.localizedDescription)
                }
            })
            task.resume()
            
        }
    }
    func sendImage(image:UIImage, path: String){
        let url = NSURL(string: path)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let boundary = NSString(format: "---------------------------14737809831466499882746641449")
        let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
        request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
        let body = NSMutableData.init()
        // Image
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format:"Content-Disposition: form-data; name=\"htdocs\"; filename=\".jpg\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageData!)
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        request.HTTPBody = body
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print(response)
            let returnString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("returnString \(returnString)")
            var err: NSError?
            var jsonResult:NSDictionary
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        if(err != nil) {
                            throw err!
                        } else {
                            
                            //                            let results: NSArray = jsonResult["results"] as! NSArray
                            //                            println(results)
                            //                            let value: AnyObject = results.objectAtIndex(0)
                            self.delegate!.handleError(Int(jsonResult["results"]!["currval"] as! String)!)
                        }
                    } catch {
                        self.delegate!.handleError(0)
                        
                    }
                } else {
                    
                    if let vc = UIApplication.topViewController(){
                        let alert = UIAlertController(title: "Alerte", message: "Une erreur est survenue lors de l'accès à l'URL:\(path) du serveur.\n Si cette erreur s'affiche, il est possible que l'application plante ou qu'il y ait certains disfonctionnements.\n Veuillez nous excuser pour la gêne occasionnée et contactez le service technique si ce problème persiste.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        vc.presentViewController(alert, animated: true, completion: nil)
                        self.delegate!.handleError(2)
                    }

                }
            }
            
            
            
            
        })
        task.resume()
    }
    func getRadioFromUrl(idRadio:Int) -> UIImage {
        let vretour = UIImage(data: NSData(contentsOfURL: NSURL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+radio+as+image+from+radios+where+id=\(idRadio)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)!)!)
        return vretour!
    }
    func getUrlFromDocument(idDocument:Int) -> NSURL {
        let vretour:NSURL? = NSURL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/?type=6&&id=\(idDocument)")
        return vretour!
    }
    func updateServerAdress(adress:String){
        let file = "/file.txt"
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true){
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingString(file)
            let text = adress
            
            do {
                //writing
                try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            } catch _ {
            };
            
            //reading
            print(try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding))
        }
        
    }
    func readServerAdress() -> String {
        let file = "/file.txt"
        var text2 = ""
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true){
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingString(file);
            //reading
            text2 = (try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)) ?? ""
        }
        return text2
    }
    func updatepreference(newPref:String){
        let file = "/pref.txt"
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true){
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingString(file)
            let text = newPref
            
            do {
                //writing
                try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            } catch _ {
            };
            
            //reading
            print(try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding))
        }
        
    }
    func readPreference() -> String {
        let file = "/pref.txt"
        var text2 = ""
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true){
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingString(file);
            //reading
            text2 = (try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)) ?? ""
        }
        print(text2)
        return text2
    }
    func getPref(nomPref:String) ->[String]{
        var vretour = []
        var cachePref = ""
        let preference = self.readPreference()
        var lespref = preference.characters.split{$0 == ";"}.map(String.init)
        var calendarArray = preference.characters.split{$0 == ";"}.map(String.init)
        var nameValue = [String]()
        let nbprf = calendarArray.count
        for (var i = 0; i < nbprf; i++){
            lespref = calendarArray[i].characters.split{$0 == ":"}.map(String.init)
            nameValue = calendarArray[i].characters.split{$0 == ":"}.map(String.init)
            if(nameValue[0] == nomPref){
                vretour = nameValue[1].characters.split{$0 == ","}.map(String.init)
            }else {
                cachePref += lespref[0]+":"+lespref[1]+";"
            }
        }
        return vretour as! [String]
    }
    func addPref(nomPref:String, prefs:[String]){
        
        var lesCal = ""
        var cachePref = ""
        let preference = self.readPreference()
        var lespref = preference.characters.split{$0 == ";"}.map(String.init)
        var calendarArray = preference.characters.split{$0 == ";"}.map(String.init)
        var nameValue = [String]()
        let nbprf = calendarArray.count
        for (var i = 0; i < nbprf; i++){
            lespref = calendarArray[i].characters.split{$0 == ":"}.map(String.init)
            nameValue = calendarArray[i].characters.split{$0 == ":"}.map(String.init)
            if(nameValue[0] != nomPref) {
                cachePref += lespref[0]+":"+lespref[1]+";"
            }
        }
        var u = 0
        for k in prefs {
            if u == 0 && u != prefs.count - 1{
                lesCal += k
            }
            if (u == prefs.count - 1 && u > 0){
                lesCal += ","+k+";"
            }
            if (u == prefs.count - 1 && u == 0){
                lesCal += k+";"
            }
            if (u > 0 && u != prefs.count-1){
                lesCal += ","+k
            }
            u++
        }
        self.updatepreference(nomPref+":"+lesCal+cachePref)
        self.readPreference()
    }
    
    class func loadFileSync(url: NSURL,fileType:String,nom:String, id:Int, completion:(path:String, error:NSError!) -> Void)->NSURL {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent("\(nom)[\(id)].\(fileType)")
         if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
                completion(path: destinationUrl.path!, error:nil)
            } else {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(path: destinationUrl.path!, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(path: destinationUrl.path!, error:error)
        }
        return destinationUrl
    }
    


}



@objc protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
    func handleError(results: Int)
}