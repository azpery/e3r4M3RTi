//
//  date.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 31/05/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import Foundation
extension NSDate {
    func dateFromString(date: String, format: String) -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
    
}