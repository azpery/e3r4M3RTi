//
//  Chart.swift
//  OremiaMobile2
//
//  Created by Zumatec on 17/03/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
class Chart :  NSObject, APIControllerProtocol{
    var idpatient: Int = 0
    var date: String = ""
    var localisation: Int = 0
    var layer: String = ""
    var chart = [Chart]()
    var callback:(()->Void)?
    lazy var api:APIController = APIController(delegate: self)

    override init() {
        super.init()
    }
    init(idpatient:Int, callback:()->Void) {
        super.init()
        self.api.sendRequest("SELECT * FROM chart WHERE idpatient=\(idpatient)")
        self.callback = callback
    }
    init(idpatient:Int,date:String,localisation:Int,layer: String) {
        super.init()
        self.idpatient=idpatient
        self.date=date
        self.localisation=localisation
        self.layer=layer
    }
    func chartWithJSON(allResults: NSArray) {
        if allResults.count>0 {
            for result in allResults {
                let idpatient : Int = result["idpatient"] as? Int ?? 0
                let date = result["date"] as? String ?? ""
                let localisation = result["localisation"] as? String ?? ""
                let layer = result["layer"] as? String ?? ""

                let newChart = Chart(idpatient: idpatient, date: date, localisation: Int(localisation)!, layer: layer)
                chart.append(newChart)
            }
        }
    }
    
    func localisationFromIndexPath(var indexPath:Int)->Int{
        if indexPath <= 7 {
            indexPath = 18 - indexPath
        }else if indexPath > 7 && indexPath <= 15 {
            indexPath = 13 + indexPath
        }else if indexPath > 15 && indexPath <= 23 {
            indexPath = 64 - indexPath
        }else if indexPath > 23  {
            indexPath = 7 + indexPath
        }
        return indexPath
    }
    
    func indexPathFromLocalisation(var localisation:Int)->Int{
        if localisation <= 18 {
            localisation = 18 - localisation
        }else if localisation > 20 && localisation <= 28 {
            localisation = 13 - localisation
        }else if localisation > 30 && localisation <= 38 {
            localisation = localisation - 7
        }else if localisation > 41  {
            localisation = 64 - localisation
        }
        return localisation
    }
    
    func imageFromIndexPath(var indexPath:Int, var layer:String, imageView:UIImageView){
        if layer != "" {
            layer = "-\(layer)"
        }
        if indexPath <= 7 {
            
            indexPath = 18 - indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "\(indexPath)")
            }
        }else if indexPath > 7 && indexPath <= 15 {
            indexPath = 3 + indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "\(indexPath)")
            }
            imageView.transform = CGAffineTransformMakeScale(-1, 1)
        }else if indexPath > 15 && indexPath <= 23 {
            indexPath = 64 - indexPath
        }else if indexPath > 23  {
            indexPath = 17 + indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "\(indexPath)")
            }
            imageView.transform = CGAffineTransformMakeScale(-1, 1)
        }
        
    }
    
    func layerFromIndexPath(indexPath:Int)->String{
        var layer = ""
        for chart in self.chart{
            if chart.localisation == self.localisationFromIndexPath(indexPath){
                layer = chart.layer
            }
        }
        return layer
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            if resultsArr.count > 0 {
                self.chartWithJSON(resultsArr)
                if let cb = self.callback{
                    self.callback!()
                }
            }
        })
    }
    func handleError(results: Int) {
        if results == 1{
                dispatch_async(dispatch_get_main_queue(), {

                })
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
    }
}