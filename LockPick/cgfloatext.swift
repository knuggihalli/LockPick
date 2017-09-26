//
//  cgfloatext.swift
//  LockPick
//
//  Created by Kavun Nuggihalli on 4/15/16.
//  Copyright © 2016 ConsiderCode LLC. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    public static func random() -> CGFloat{
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    public static func random(min min: CGFloat, max: CGFloat) -> CGFloat{
        return CGFloat.random() * (max-min) + min
    }
}
