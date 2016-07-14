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
    
    static func isDateGreaterThanToday(date: NSDate)->Bool{
        var vretour = false
        let dateToday = NSDate()
        if date.compare(dateToday) == NSComparisonResult.OrderedDescending {
            vretour = true
        }
        return vretour
    }
    
    static func getDateFromString(dateStr:String)->NSDate?{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString(dateStr)
        return date
    }
    
    static func getFormatedDateFromString(dateStr:String, pattern:String = "dd/MM/yyyy")->String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = pattern
        let date = dateFormatter.dateFromString(dateStr)
        return self.getFormatedDate(date ?? NSDate())
    }
    
    static func setDefaultBackgroundMessage(tableView:UITableView, elements:Int, message:String){
        let messageLbl = UILabel( frame:CGRectMake(0, 0,
            tableView.bounds.size.width,
            tableView.bounds.size.height))
        if (elements == 0) {
            messageLbl.text = message
        }else{
            messageLbl.text = ""
        }
        messageLbl.font = UIFont(name: "Avenir Next", size: 30)
        messageLbl.textColor = ToolBox.UIColorFromRGB(0x878787)
        messageLbl.textAlignment = NSTextAlignment.Center
        messageLbl.sizeToFit()
        tableView.backgroundView = messageLbl
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    static func setDefaultBackgroundMessageForCollection(tableView:UICollectionView, elements:Int, message:String){
        let messageLbl = UILabel( frame:CGRectMake(0, 0,
            tableView.bounds.size.width,
            tableView.bounds.size.height))
        if (elements == 0) {
            messageLbl.text = message
        }else{
            messageLbl.text = ""
        }
        messageLbl.font = UIFont(name: "Avenir Next", size: 30)
        messageLbl.textColor = ToolBox.UIColorFromRGB(0x878787)
        messageLbl.textAlignment = NSTextAlignment.Center
        messageLbl.sizeToFit()
        tableView.backgroundView = messageLbl
    }
    
    static func startActivity(view: UIView) -> DTIActivityIndicatorView{
        let activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.blackColor()
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
        return activityIndicator
    }
    
    static func stopActivity(activityIndicator:DTIActivityIndicatorView){
        activityIndicator.stopActivity()
        activityIndicator.removeFromSuperview()
    }
    
    static func calcAge(birthday:String) -> Int{
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let birthdayDate = dateFormater.dateFromString(birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let now: NSDate! = NSDate()
        let calcAge = calendar.components(.Year, fromDate: birthdayDate!, toDate: now, options: [])
        let age = calcAge.year
        return age
    }
}