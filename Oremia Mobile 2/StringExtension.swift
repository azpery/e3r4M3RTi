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
    func replace(_ target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
