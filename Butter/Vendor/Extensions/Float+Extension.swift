//
//  Float+Extension.swift
//  Popcorn-Time
//
//  Created by Giles Allensby on 14/10/2015.
//  Copyright © 2015 popcorntime. All rights reserved.
//

import Foundation

extension Float {
    func roundToInt() -> Int{
        let value = Int(self)
        let f = self - Float(value)
        if f < 0.5{
            return value
        } else {
            return value + 1
        }
    }
    
    func ceil() -> Int{
        let value = Int(self)
        let f = self - Float(value)
        if f > 0.0 {
            return value + 1
        } else {
            return value
        }
    }
}