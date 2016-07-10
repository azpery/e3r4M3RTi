//
//  StringExtension.swift
//  OremiaMobile2
//
//  Created by Zumatec on 05/07/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import Foundation
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}