//
//  ToolBox.swift
//  OremiaMobile2
//
//  Created by Zumatec on 06/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import Foundation
@objc class ToolBox:NSObject{
    static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    static func shakeIt(view:UIView) {
        let anim = CAKeyframeAnimation( keyPath:"transform" )
        anim.values = [
            NSValue( CATransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( CATransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
        ]
        anim.autoreverses = true
        anim.repeatCount = 2
        anim.duration = 7/100
        
        view.layer.addAnimation( anim, forKey:nil )
    }
    static func getFormatedDate(date:NSDate)->String{
    
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        print(year)
        print(month)
        print(day)
        return "\(year)-\(month)-\(day)"
    }
    static func getFormatedDateWithSlash(date:NSDate)->String{
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        print(year)
        print(month)
        print(day)
        return "\(day)/\(month)/\(year)"
    }
    
    static func setDefaultBackgroundMessage(tableView:UITableView, elements:Int, message:String){
        let messageLbl = UILabel( frame:CGRectMake(0, 0,
            tableView.bounds.size.width,
            tableView.bounds.size.height))
        if (elements == 0) {
            //set the message
            messageLbl.text = message
        }else{
            messageLbl.text = ""
        }
        messageLbl.font = UIFont(name: "Avenir Next", size: 30)
        messageLbl.textColor = ToolBox.UIColorFromRGB(0x878787)
        //center the text
        messageLbl.textAlignment = NSTextAlignment.Center
        //auto size the text
        messageLbl.sizeToFit()
        tableView.backgroundView = messageLbl
        //no separator
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    static func setDefaultBackgroundMessageForCollection(tableView:UICollectionView, elements:Int, message:String){
        let messageLbl = UILabel( frame:CGRectMake(0, 0,
            tableView.bounds.size.width,
            tableView.bounds.size.height))
        if (elements == 0) {
            //set the message
            messageLbl.text = message
        }else{
            messageLbl.text = ""
        }
        messageLbl.font = UIFont(name: "Avenir Next", size: 30)
        messageLbl.textColor = ToolBox.UIColorFromRGB(0x878787)
        //center the text
        messageLbl.textAlignment = NSTextAlignment.Center
        //auto size the text
        messageLbl.sizeToFit()
        tableView.backgroundView = messageLbl
        //no separator
    }
}