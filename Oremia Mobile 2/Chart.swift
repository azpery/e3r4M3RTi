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
    var sql = ""
    var layer: [String] = [String]()
    var chart = [Chart]()
    var callback:(()->Void)?
    lazy var api:APIController = APIController(delegate: self)
    
    override init() {
        super.init()
    }
    init(idpatient:Int, callback:()->Void) {
        super.init()
        self.api.sendRequest("SELECT * FROM chart WHERE idpatient=\(idpatient) order by layer")
        self.callback = callback
    }
    init(idpatient:Int,date:String,localisation:Int,layer: String) {
        super.init()
        self.idpatient=idpatient
        self.date=date
        self.localisation=localisation
        self.layer.append(layer)
    }
    func chartWithJSON(allResults: NSArray) {
        if allResults.count>0 {
            for result in allResults {
                let localisation = Int(result["localisation"] as? String ?? "0") ?? 0
                if let c = self.chartFromLocalisation(localisation) {
                    let layer = result["layer"] as? String ?? ""
                    c.layer.append(layer)
                }else {
                    let idpatient : Int = result["idpatient"] as? Int ?? 0
                    let date = result["date"] as? String ?? ""
                    let layer = result["layer"] as? String ?? ""
                    let newChart = Chart(idpatient: idpatient, date: date, localisation: localisation, layer: layer)
                    chart.append(newChart)
                }
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
    

    func imagesFromIndexPath(indexPath:Int, layer:[String], cell:DentCollectionViewCell)->DentCollectionViewCell{
        var cpt = 0
        cell.dent8Layout.image = nil
        cell.dent7Layout.image = nil
        cell.dent6Layout.image = nil
        cell.dent5Layout.image = nil
        cell.dent4Layout.image = nil
        cell.dent3Layout.image = nil
        cell.dent2Layout.image = nil
        cell.dent1Layout.image = nil
        cell.dentLayout.image = nil
        if layer.count > 0 {
            self.imageFromIndexPath(indexPath, layer: "", imageView: cell.dentLayout)
            var imageView:UIImageView?
            for lay in layer{
                if cell.dent8Layout.image == nil{
                    imageView = cell.dent8Layout
                    cell.dent7Layout.image = nil
                }else if cell.dent7Layout.image == nil{
                    imageView = cell.dent7Layout
                    cell.dent6Layout.image = nil
                }else if cell.dent6Layout.image == nil{
                    imageView = cell.dent6Layout
                    cell.dent5Layout.image = nil
                }else if cell.dent5Layout.image == nil{
                    imageView = cell.dent5Layout
                    cell.dent4Layout.image = nil
                }else if cell.dent4Layout.image == nil{
                    imageView = cell.dent4Layout
                    cell.dent3Layout.image = nil
                }else if cell.dent3Layout.image == nil{
                    imageView = cell.dent3Layout
                    cell.dent2Layout.image = nil
                }else if cell.dent2Layout.image == nil{
                    imageView = cell.dent2Layout
                    cell.dent1Layout.image = nil
                }else if cell.dent1Layout.image == nil{
                    imageView = cell.dent1Layout
                    cell.dent8Layout.image = nil
                }else{
                    imageView = nil
                }
                if let img = imageView{
                    img.alpha = 0.7
                    if lay == "tfm-or" || lay == "tfm-metal" || lay == "tfm-fibre" || lay == "imp_xlocator" || lay == "imp_pilier"{
                        cell.dent8Layout.image =  nil
                        cell.dent6Layout.image = nil
                        cell.dent5Layout.image = nil
                        cell.dent4Layout.image = nil
                        cell.dent3Layout.image = nil
                        cell.dent2Layout.image = nil
                        cell.dent1Layout.image = nil
                        cell.dentLayout.image = nil
                    }
                    if(lay == "xabst"){
                        cell.dent8Layout.image =  nil
                        cell.dent6Layout.image = nil
                        cell.dent5Layout.image = nil
                        cell.dent4Layout.image = nil
                        cell.dent3Layout.image = nil
                        cell.dent2Layout.image = nil
                        cell.dent1Layout.image = nil
                        cell.dentLayout.image = nil
                        
                    } else if(lay != "arx"){
                        self.imageFromIndexPath(indexPath, layer: lay, imageView: img)
                    }
                    if lay == "tfm-or" || lay == "tfm-metal" || lay == "tfm-fibre" || lay == "imp_xlocator" || lay == "imp_pilier"{
                        cell.dentLayout.image = nil
                    }
                }
                cpt++
            }
        } else {
            self.imageFromIndexPath(indexPath, layer: "", imageView: cell.dent8Layout)
        }
        return cell
    }
    
    func imageFromIndexPath(var indexPath:Int, var layer:String, imageView:UIImageView){
        if layer != "" {
            layer = "-\(layer)"
        }
        imageView.transform = CGAffineTransformMakeScale(1, 1)
        if indexPath <= 7 {
            indexPath = 18 - indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            }
        }else if indexPath > 7 && indexPath <= 15 {
            indexPath = 3 + indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            }
            imageView.transform = CGAffineTransformMakeScale(-1, 1)
        }else if indexPath > 15 && indexPath <= 23 {
            indexPath = 64 - indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            }
        }else if indexPath > 23  {
            indexPath = 17 + indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            }
            imageView.transform = CGAffineTransformMakeScale(-1, 1)
        }
        imageView.layer.minificationFilter = kCAFilterTrilinear
        
    }
    
    func chartFromLocalisation(localisation:Int) -> Chart?{
        var vretour:Chart?
        for chart in self.chart{
            if chart.localisation == localisation {
                vretour = chart
            }
        }
        return vretour ?? nil
    }
    
    func layerFromIndexPath(indexPath:Int)->[String]{
        var layer = [String]()
        for chart in self.chart{
            if chart.localisation == self.localisationFromIndexPath(indexPath){
                layer = chart.layer
            }
        }
        return layer
    }
    
    func setLayerFromIndexPath(indexPath:Int, layers:[String]){
        for chart in self.chart{
            if chart.localisation == self.localisationFromIndexPath(indexPath){
                chart.layer = layers
            }
        }
    }
    
    func addLayersFromPrestation(prestations : [PrestationActe]){
        for p in prestations {
            let chart = Chart(idpatient: self.idpatient, date: p.dateActe, localisation: p.numDent, layer: p.image)
            self.chart.append(chart)
            if p.image != ""{
                self.sql += "('\(self.idpatient)', '\(ToolBox.getFormatedDateFromString(p.dateActe))', '\(p.numDent)', '\(p.image)'),"
            }
        }
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        let resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            if resultsArr.count > 0 {
                self.chartWithJSON(resultsArr)
                if let cb = self.callback{
                    cb()
                }
            } else {
                if let cb = self.callback{
                    cb()
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