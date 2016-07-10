//
//  ChartForChildren.swift
//  OremiaMobile2
//
//  Created by Zumatec on 10/07/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
class ChartForChildren : Chart{
    override func localisationFromIndexPath(var indexPath:Int)->Int{

        if indexPath <= 7 && indexPath > 2 {
            indexPath = 58 - indexPath
        }else if indexPath > 7 && indexPath <= 12 {
            indexPath = 43 + indexPath
        }else if indexPath > 18 && indexPath <= 23 {
            indexPath = 104 - indexPath
        }else if indexPath > 23 && indexPath <= 28 {
            indexPath = 57 + indexPath
        }
        return indexPath
    }
    
//    func indexPathFromLocalisation(var localisation:Int)->Int{
//        if localisation <= 18 {
//            localisation = 18 - localisation
//        }else if localisation > 20 && localisation <= 28 {
//            localisation = 13 - localisation
//        }else if localisation > 30 && localisation <= 38 {
//            localisation = localisation - 7
//        }else if localisation > 41  {
//            localisation = 64 - localisation
//        }
//        return localisation
//    }
    
    override func imageFromIndexPath(var indexPath:Int, var layer:String, imageView:UIImageView){
        if layer != "" {
            layer = "-\(layer)"
        }
        if indexPath <= 7 && indexPath > 2 {
            indexPath = 58 - indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "\(indexPath)")
            }
        }else if indexPath > 7 && indexPath <= 12 {
            indexPath = 43 + indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "\(indexPath)")
            }
            imageView.transform = CGAffineTransformMakeScale(-1, 1)
        }else if indexPath > 18 && indexPath <= 23 {
            indexPath = 104 - indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "\(indexPath)")
            }
        }else if indexPath > 23 && indexPath <= 28 {
            indexPath = 57 + indexPath
            if let image = UIImage(named: "\(indexPath)\(layer)"){
                imageView.image = image
            } else {
                imageView.image = UIImage(named: "\(indexPath)")
            }
            imageView.transform = CGAffineTransformMakeScale(-1, 1)
        }
        imageView.layer.minificationFilter = kCAFilterTrilinear
        
    }
}