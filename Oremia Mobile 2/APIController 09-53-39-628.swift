//
//  APIController.swift
//  Oremia mobile
//
//  Created by Zumatec on 07/03/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import Foundation
class APIController {
    var delegate: APIControllerProtocol
    var context: AnyObject?
    var itunesSearchTerm: String?
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    func sendRequest(searchString: String) {
        self.itunesSearchTerm = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        if let escapedSearchTerm = itunesSearchTerm!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=1"
            get(urlPath, searchString: "query=\(searchString)")
        }
    }
    func setConnexion() {
            let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=0"
            get(urlPath, searchString: "dbname=\(connexionString.db)&user=\(connexionString.login)&pw=\(connexionString.pw)")
    }
    func selectpraticien() {
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=2"
        get(urlPath, searchString: "query=select id,nom,prenom from praticiens&dbname=\(connexionString.db)&user=\(connexionString.login)&pw=\(connexionString.pw)")
    }
    func sendInsert(searchString: String) {
            let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?type=1"
            insert(urlPath, searchString: "query=\(searchString)")
    }
    func detectionServeur(urlPath:String){
        let myArray:[String] = preference.ipServer.componentsSeparatedByString(".") as [String]
        let numA = NSNumberFormatter().numberFromString(myArray[3])?.intValue
        let numB = NSNumberFormatter().numberFromString(myArray[2])?.intValue
        if numA < 99 {
            preference.ipServer = "\(myArray[0]).\(myArray[1]).\(myArray[2]).\(numA! + 1)"
        }
        if numB < 99 && numB > 99{
            preference.ipServer = "\(myArray[0]).\(myArray[1]).\(numB! + 1).\(myArray[03])"
        }
        if numA >= 99 && numB >= 99 {
            self.delegate.handleError(1)
        }
        let path = "http://\(preference.ipServer)/scripts/OremiaMobileHD/index.php?query="+itunesSearchTerm!+"&&db="+connexionString.db+"&&login="+connexionString.login+"&&pw="+connexionString.pw
//        get(path)
        
    }
    func insertImage(image:UIImage, idPatient:Int){
        let urlPath = "http://\(preference.ipServer)/scripts/OremiaMobileHD/?type=7&&idPatient=\(idPatient)&&idPraticien=\(preference.idUser)"
        sendImage(image, path: urlPath)
    }
    func lookupAlbum(collectionId: Int) {
        sendRequest("select * from patients")
    }
    func get(path: String, searchString:String) {
        if let url = NSURL(string: path) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let postString = searchString
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                println("Task completed")
                if(error != nil) {
                    println(error.localizedDescription)
                    self.delegate.handleError(1)
                    //self.detectionServeur(path)
                }else {
                    println(response)
                    let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("responseString = \(responseString)")
                    var err: NSError?
                    if (NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &err) != nil){
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
                        if(err != nil) {
                            println("JSON Error \(err!.localizedDescription)")
                        } else {
                            
//                            let results: NSArray = jsonResult["results"] as! NSArray
//                            println(results)
//                            let value: AnyObject = results.objectAtIndex(0)
                            self.delegate.didReceiveAPIResults(jsonResult)
                        }
                    } else {
                        
                        self.delegate.handleError(2)
                        //                        self.detectionServeur(path)
                    }
                }
            })
            task.resume()
        } else {
            delegate.handleError(1)
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
                println("Task completed")
                println(response)
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("responseString = \(responseString)")
                if(error != nil) {
                    println(error.localizedDescription)
                }
            })
            task.resume()
            
        }
    }
    func sendImage(image:UIImage, path: String){
        let url = NSURL(string: path)
        var imageData = UIImageJPEGRepresentation(image, 1)
        var request = NSMutableURLRequest(URL: url!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var boundary = NSString(format: "---------------------------14737809831466499882746641449")
        var contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
        request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
        var body = NSMutableData.alloc()
        // Image
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format:"Content-Disposition: form-data; name=\"htdocs\"; filename=\".jpg\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageData)
        body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        request.HTTPBody = body
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println(response)
            var returnString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            println("returnString \(returnString)")
        })
        task.resume()
    }
    func getRadioFromUrl(idRadio:Int) -> UIImage {
        var vretour = UIImage(data: NSData(contentsOfURL: NSURL(string: "http://\(preference.ipServer)/scripts/OremiaMobileHD/?type=5&&id=\(idRadio)")!)!)
        return vretour!
    }
    func getUrlFromDocument(idDocument:Int) -> NSURL {
        let vretour:NSURL? = NSURL(string : "http://\(preference.ipServer)/scripts/OremiaMobileHD/?type=6&&id=\(idDocument)")
        return vretour!
    }
}
protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
    func handleError(results: Int)
}