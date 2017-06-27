//
//  date.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 31/05/2015.
//  Copyright (c) 2015 Zumatec. All rights reserved.
//

import Foundation
extension Date {
    func dateFromString(_ date: String, format: String) -> Date {
        let formatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.date(from: date)!
    }
    
}
