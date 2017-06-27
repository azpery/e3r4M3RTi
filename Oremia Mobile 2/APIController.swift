
//
//  APIController.swift
//  Oremia mobile
//
//  Created by Zumatec on 07/03/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import Foundation
@objc class APIController:NSObject, NSURLConnectionDelegate{
    var delegate: APIControllerProtocol?
    var context: AnyObject?
    var itunesSearchTerm: String?
    var canStartPinging = false
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    override init() {
        
    }
    func getIniFile(_ type: String) {
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=14"
        get(urlPath, searchString: "query=\(type)")
    }
    func checkFileUpdate(_ success: @escaping (AnyObject)->Bool = {defaut->Bool in return false}, failure: @escaping (AnyObject)->Bool = {defaut->Bool in return false}) {
        let urlPath = "http://\(preference.ipServer)/scripts/updater.php"
        get(urlPath, searchString: "query='')", success: success, failure: failure)
    }
    func sendRequest(_ searchString: String, success: @escaping (NSDictionary)->Bool = {defaut->Bool in return false}){
        self.itunesSearchTerm = searchString.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.caseInsensitive, range: nil)
        if let _ = itunesSearchTerm!.addingPercentEscapes(using: String.Encoding.utf8) {
            let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=1"
            get(urlPath, searchString: "query=\(searchString)", success: success)
        }
    }
    func insertActes(_ patient:patients, actes: [PrestationActe], success: @escaping  (NSDictionary)->Bool = {defaut->Bool in return false}) -> Bool {
        do{
            
            let uuid = UUID().uuidString
            if let string = PrestationActe.prestationToFormattedOutput(patient, prestations: actes){
                let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=17"
                get(urlPath, searchString: "idPatient=\(patient.id)&idPraticien=\(preference.idUser)&UID=\(uuid)&arr=\(string)", success: success)
                return true
            }else{
                return false
            }
            
        }
        
    }
    func getCalDavRessources(_ date:Date? = nil, calendars:[String]? = [""]){
        var date = date
        var cals = ""
        if calendars != nil {
            cals = "&calendars="
            for c in calendars! {
                cals += "\(c),"
            }
        }
        
        if date == nil {
            date = Date()
        }
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/getEvents.php?idP=\(preference.idUser)&date=\(ToolBox.getFormatedDate(date!))\(cals)"
        get(urlPath.addingPercentEscapes(using: String.Encoding.utf8)!, searchString: "query=\("")")
    }
    func setCalDavRessources(_ uid:String,ipp:Int,statut:Int,dtstart:String,dtend:String,summary:String,title:String, type:Int, date:Date? = Date()){
        let date = date
        if let newsummary = summary.addingPercentEscapes(using: String.Encoding.utf8) {
            let newTitle = title.addingPercentEscapes(using: String.Encoding.utf8)
            let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/setEvent.php?UID=\(uid)&IPP=\(ipp)&STATUT=\(statut)&DTSTART=\(dtstart)&DTEND=\(dtend)&SUMMARY=\(newsummary)&TITLE=\(newTitle!)&idP=\(preference.idUser)&TYPE=\(type)&date=\(ToolBox.getFormatedDate(date!))"
            get(urlPath, searchString: "query=\("")")
        }
    }
    func setConnexion() {
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=0"
        get(urlPath, searchString: "dbname=\(connexionString.db)&user=\(connexionString.login)&pw=\(connexionString.pw)")
    }
    func checkLicence(_ success: @escaping (Bool)->Void? = {defaut->Void in}){
        let urlPath = "https://licences.oremia.com/licences/checkSetup2.php?id=\(preference.licence)"
        get(urlPath, searchString: "",success: {defaut->Bool in
            let licence = defaut["licences"] as? NSDictionary
            if let l = licence {
                if let date = l["3"] as? String{
                    if let d = ToolBox.getDateFromString(date){
                        if ToolBox.isDateGreaterThanToday(d){
                            success(true)
                        }else{
                            success(false)
                        }
                    }else{
                        success(false)
                    }
                }else{
                    success(false)
                }
            }else{
                success(false)
            }
        return true})
    }
    func selectpraticien() {
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=2"
        get(urlPath, searchString: "query=select id,nom,prenom,licence  from praticiens order by id&dbname=\(connexionString.db)&user=\(connexionString.login)&pw=\(connexionString.pw)")
    }
    func sendInsert(_ searchString: String) {
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=1"
        insert(urlPath, searchString: "query=\(searchString)")
    }
    func insertImage(_ image:UIImage, idPatient:Int, isNewPp:Bool = true){
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/?type=7&&idPatient=\(idPatient)&&idPraticien=\(preference.idUser)&&isNewPp=\(isNewPp ? 1 : 0)"
        sendImage(image, path: urlPath)
    }
    func signDocument(_ sPrat:String, sPatient:String, idDoc:Int, idPatient:Int, selectedRow: Int, success: @escaping (Int)->Bool = {defaut->Bool in return false}){
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/documentSigner.php?idDocument=\(idDoc)&&idType=\(selectedRow)&&idPatient=\(idPatient)&&idPraticien=\(preference.idUser)"
        let query = "sPrat=\(percentEscapeString(sPrat))&sPatient=\(percentEscapeString(sPatient))"
        insert(urlPath, searchString:query,  success: success)
    }
    func lookupAlbum(_ collectionId: Int) {
        sendRequest("select * from patients")
    }
    func pingServer(){
        let url = "\(preference.ipServer)"
        SimplePingHelper.ping(url, target: self.delegate, sel: Selector("pingResult:"))
    }
    
    func get(_ path: String, searchString:String, success: @escaping (NSDictionary)->Bool = {defaut->Bool in return false}, failure: @escaping (AnyObject)->Bool = {defaut->Bool in return false}) {
        print(path)
        if let url = URL(string: path ) {
            
            let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 3600)
            request.httpMethod = "POST"
            let postString = searchString
            let postLength:NSString = String( postString.characters.count ) as NSString
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.httpBody = postString.data(using: String.Encoding.utf8)!
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let session = URLSession.shared
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if(error != nil) {
                            print(error!.localizedDescription)
                            if(!failure(1 as AnyObject)){
                                self.delegate?.handleError(1)
                            }
                        }else {
                            print(response ?? "error")
                            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            print("responseString = \(responseString ?? "error")")
                            var jsonResult: NSDictionary?
                            do {
                                jsonResult = (try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                                if jsonResult != nil {
                                    if success(jsonResult!) == false {
                                        self.delegate?.didReceiveAPIResults(jsonResult!)
                                    }
                                } else {
                                    if(!failure(1 as AnyObject)){
                                        self.delegate?.handleError(1)
                                    }
                                }
                            } catch {
                                self.delegate?.handleError(1)
                            }
                        }
                    } else if httpResponse.statusCode == 404{
                        if(!failure(1 as AnyObject)){
                            self.delegate?.handleError(1)
                        }
                    }else if httpResponse.statusCode == 406{
                        if(!failure(1 as AnyObject)){
                            self.delegate?.handleError(2)
                        }
                    }else if httpResponse.statusCode == 502{
                        self.delegate?.didReceiveAPIResults(["results":"Success"])
                    }else {
                        
                        DispatchQueue.main.async(execute: {
                            if let vc = UIApplication.topViewController(){
                                let alert = UIAlertController(title: "Alerte", message: "Une erreur est survenue lors de l'accès à l'URL:\(path) du serveur.\n Requête :\(searchString).\n Si cette erreur s'affiche, il est possible que l'application plante ou qu'il y ait certains disfonctionnements.\n Veuillez nous excuser pour la gêne occasionnée et contactez le service technique si ce problème persiste. \n Erreur \(httpResponse.statusCode)", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                vc.present(alert, animated: true, completion: nil)
                                
                            }
                        })
                    }
                }else  {
                    if(!failure(1 as AnyObject)){
                        self.delegate?.handleError(1)
                    }
                }
            })
            task.resume()
        } else {
            print(path)
            if(!failure(1 as AnyObject)){
                self.delegate?.handleError(1)
            }
        }
    }
    
    func insert(_ path:String, searchString:String, success: @escaping (Int)->Bool = {defaut->Bool in return false}){
        if let url = URL(string: path) {
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let postString = searchString
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                print("Task completed")
                print(response ?? "pouet")
                let responseString = NSString(data: data ?? Data(), encoding: String.Encoding.utf8.rawValue)!
                print("responseString = \(responseString)")
                let idInserted = Int(responseString as String)
                _ = success(idInserted ?? 0)
                if(error != nil) {
                    print(error!.localizedDescription)
                }
            })
            task.resume()
            
        }
    }
    func percentEscapeString(_ string: String) -> String {
        return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                       string as CFString,
                                                       nil,
                                                       ":/?@!$&'()*+,;=" as CFString,
                                                       CFStringBuiltInEncodings.UTF8.rawValue) as String;
    }
    func sendImage(_ image:UIImage, path: String){
        let url = URL(string: path)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let request = NSMutableURLRequest(url: url!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        let boundary = NSString(format: "---------------------------14737809831466499882746641449")
        let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
        request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
        let body = NSMutableData.init()
        // Image
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition: form-data; name=\"htdocs\"; filename=\".jpg\"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(imageData!)
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        request.httpBody = body as Data
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            print(response ?? "Pas de réponse")
            let returnString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("returnString \(returnString ?? "Pas de réponse")")
            var jsonResult:NSDictionary
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                     do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                            
                            //                            let results: NSArray = jsonResult["results"] as! NSArray
                            //                            println(results)
                            //                            let value: AnyObject = results.objectAtIndex(0)
                        let json = jsonResult["results"]! as? NSDictionary
                            self.delegate!.handleError(Int(json?["currval"] as! String)!)
                        
                    } catch {
                        self.delegate!.handleError(0)
                        
                    }
                } else {
                    
                    if let vc = UIApplication.topViewController(){
                        let alert = UIAlertController(title: "Alerte", message: "Une erreur est survenue lors de l'accès à l'URL:\(path) du serveur.\n Si cette erreur s'affiche, il est possible que l'application plante ou qu'il y ait certains disfonctionnements.\n Veuillez nous excuser pour la gêne occasionnée et contactez le service technique si ce problème persiste.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        vc.present(alert, animated: true, completion: nil)
                        self.delegate!.handleError(2)
                    }
                    
                }
            }
            
            
            
            
        })
        task.resume()
    }
    func getRadioFromUrl(_ idRadio:Int) -> UIImage {
        let vretour = UIImage(data: try! Data(contentsOf: URL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/image.php?query=select+radio+as+image+from+radios+where+id=\(idRadio)&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw)!))
        return vretour!
    }
    func getUrlFromDocument(_ idDocument:Int) -> URL {
        let vretour:URL? = URL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/?type=6&&id=\(idDocument)")
        return vretour!
    }
    func updateServerAdress(_ adress:String){
        let file = "/file.txt"
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true){
            let dir = dirs[0] //documents directory
            let path = dir + file
            let text = adress
            
            do {
                //writing
                try text.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
            } catch _ {
            };
            
            //reading
            print(try! String(contentsOfFile: path, encoding: String.Encoding.utf8))
        }
        
    }
    func readServerAdress() -> String {
        let file = "/file.txt"
        var text2 = ""
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true){
            let dir = dirs[0] //documents directory
            let path = dir + file;
            //reading
            text2 = (try? String(contentsOfFile: path, encoding: String.Encoding.utf8)) ?? ""
        }
        return text2
    }
    func updatepreference(_ newPref:String){
        let file = "/pref.txt"
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true){
            let dir = dirs[0] //documents directory
            let path = dir + file
            let text = newPref
            
            do {
                //writing
                try text.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
            } catch _ {
            };
            
            //reading
            print(try! String(contentsOfFile: path, encoding: String.Encoding.utf8))
        }
        
    }
    func readPreference() -> String {
        let file = "/pref.txt"
        var text2 = ""
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true){
            let dir = dirs[0] //documents directory
            let path = dir + file;
            //reading
            text2 = (try? String(contentsOfFile: path, encoding: String.Encoding.utf8)) ?? ""
        }
        print(text2)
        return text2
    }
    func getPref(_ nomPref:String) ->[String]{
        var vretour:[String] = []
        var cachePref = ""
        let preference = self.readPreference()
        var lespref = preference.characters.split{$0 == ";"}.map(String.init)
        var calendarArray = preference.characters.split{$0 == ";"}.map(String.init)
        var nameValue = [String]()
        let nbprf = calendarArray.count
        for i in (0 ..< nbprf){
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
    func addPref(_ nomPref:String, prefs:[String]){
        
        var lesCal = ""
        var cachePref = ""
        let preference = self.readPreference()
        var lespref = preference.characters.split{$0 == ";"}.map(String.init)
        var calendarArray = preference.characters.split{$0 == ";"}.map(String.init)
        var nameValue = [String]()
        let nbprf = calendarArray.count
        for i in (0 ..< nbprf){
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
            u += 1
        }
        self.updatepreference(nomPref+":"+lesCal+cachePref)
        _ = self.readPreference()
    }
    
    class func loadFileSync(_ url: URL,fileType:String,nom:String, id:Int, completion:(_ path:String, _ error:NSError?) -> Void)->URL {
        var nom = nom
        nom = nom.replace("/", withString: "-")
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let destinationUrl = documentsUrl.appendingPathComponent("\(nom)[\(id)].\(fileType)")
        if let dataFromURL = try? Data(contentsOf: url){
            if (try? dataFromURL.write(to: destinationUrl, options: [.atomic])) != nil {
                completion(destinationUrl.path, nil)
            } else {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
        return destinationUrl
    }
    
    func getIduser()->Int
    {
        return preference.idUser
    }
    
    
    //Delegate
    func connection(_ connection:NSURLConnection,  protectionSpace:URLProtectionSpace) -> Bool{
        return protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust;
    }
    
    func connection(_ connection:NSURLConnection, challenge:URLAuthenticationChallenge) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust){
            challenge.sender!.use(URLCredential(trust:challenge.protectionSpace.serverTrust!), for: challenge)
                challenge.sender!.continueWithoutCredential(for: challenge);
        }
    }
    
}



@objc protocol APIControllerProtocol {
    func didReceiveAPIResults(_ results: NSDictionary)
    func handleError(_ results: Int)
}
