//
//  NSLocale+Extension.swift
//  Butter
//
//  Created by Moorice on 07-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import Foundation

extension NSLocale {

    static func get2LetterLanguageCode() -> String {
        let languageSplitted = NSLocale.preferredLanguages()[0].componentsSeparatedByString("-")
        if languageSplitted.count > 1 {
            return languageSplitted[0]
        } else {
            return "en"
        }
    }
    
}