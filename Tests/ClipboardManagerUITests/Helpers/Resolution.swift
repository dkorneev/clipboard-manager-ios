//
//  Resolution.swift
//  ClipboardManagerUITests
//
//  Created by Denis Korneev on 12/01/2018.
//

import Foundation
import CoreGraphics

class Resolution {
    static var iphoneSE: CGRect {
        get {
            return CGRect(x: 0, y: 0, width: 320, height: 568)
        }
    }
    
    static var iphone7: CGRect {
        get {
            return CGRect(x: 0, y: 0, width: 375, height: 667)
        }
    }
}
