//
//  ToolBox.swift
//  OremiaMobile2
//
//  Created by Zumatec on 06/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import Foundation
@objc class ToolBox:NSObject{
    static func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    static func shakeIt(_ view:UIView) {
        let anim = CAKeyframeAnimation( keyPath:"transform" )
        anim.values = [
            NSValue( caTransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
        ]
        anim.autoreverses = true
        anim.repeatCount = 2
        anim.duration = 7/100
        
        view.layer.add( anim, forKey:nil )
    }
    static func getFormatedDate(_ date:Date)->String{
    
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        return "\(year ?? 1999)-\( month ?? 01)-\(day ?? 01)"
    }
    static func getFormatedDateWithSlash(_ date:Date)->String{
        
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        return "\(year ?? 1999)/\( month ?? 01)/\(day ?? 01)"
    }
    
    static func isDateGreaterThanToday(_ date: Date)->Bool{
        var vretour = false
        let dateToday = Date()
        if date.compare(dateToday) == ComparisonResult.orderedDescending {
            vretour = true
        }
        return vretour
    }
    
    static func getDateFromString(_ dateStr:String)->Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateStr)
        return date
    }
    
    static func getFormatedDateFromString(_ dateStr:String, pattern:String = "dd/MM/yyyy")->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        let date = dateFormatter.date(from: dateStr)
        return self.getFormatedDate(date ?? Date())
    }
    
    static func setDefaultBackgroundMessage(_ tableView:UITableView, elements:Int, message:String){
        let messageLbl = UILabel( frame:CGRect(x: 0, y: 0,
            width: tableView.bounds.size.width,
            height: tableView.bounds.size.height))
        if (elements == 0) {
            messageLbl.text = message
        }else{
            messageLbl.text = ""
        }
        messageLbl.font = UIFont(name: "Avenir Next", size: 30)
        messageLbl.textColor = ToolBox.UIColorFromRGB(0x878787)
        messageLbl.textAlignment = NSTextAlignment.center
        messageLbl.sizeToFit()
        tableView.backgroundView = messageLbl
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    static func setDefaultBackgroundMessageForCollection(_ tableView:UICollectionView, elements:Int, message:String){
        let messageLbl = UILabel( frame:CGRect(x: 0, y: 0,
            width: tableView.bounds.size.width,
            height: tableView.bounds.size.height))
        if (elements == 0) {
            messageLbl.text = message
        }else{
            messageLbl.text = ""
        }
        messageLbl.font = UIFont(name: "Avenir Next", size: 30)
        messageLbl.textColor = ToolBox.UIColorFromRGB(0x878787)
        messageLbl.textAlignment = NSTextAlignment.center
        messageLbl.sizeToFit()
        tableView.backgroundView = messageLbl
    }
    
    static func startActivity(_ view: UIView) -> DTIActivityIndicatorView{
        let activityIndicator = DTIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.indicatorColor = UIColor.black
        activityIndicator.indicatorStyle = DTIIndicatorStyle.convInv(.spotify)
        activityIndicator.startActivity()
        return activityIndicator
    }
    
    static func stopActivity(_ activityIndicator:DTIActivityIndicatorView){
        activityIndicator.stopActivity()
        activityIndicator.removeFromSuperview()
    }
    
    static func calcAge(_ birthday:String) -> Int{
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar = Calendar.current
        let age = calendar.component(.year, from: birthdayDate!)
        return age
    }
    
    
}
