//
//  ImageExtension.swift
//  OremiaMobile2
//
//  Created by Zumatec on 23/06/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}