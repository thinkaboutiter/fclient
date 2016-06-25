//
//  UIColor+Extensions.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import UIKit

/*
 source: https://gist.github.com/mbigatti/c6be210a6bbc0ff25972
 */

/**
 UIColor extension that add a whole bunch of utility functions like:
 - HTML/CSS RGB format conversion (i.e. 0x124672)
 - lighter color
 - darker color
 - color with modified brightness
 */
extension UIColor {
    
    /**
     Construct a UIColor using an HTML/CSS RGB formatted value and an alpha value
     - parameter rgbValue: RGB value
     - parameter alpha: color alpha value
     - returns: an UIColor instance that represent the required color
     */
    class func colorWithRGB(rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
        let red: CGFloat = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green: CGFloat = CGFloat((rgbValue & 0xFF00) >> 8) / 255
        let blue: CGFloat = CGFloat(rgbValue & 0xFF) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     Returns a lighter color by the provided percentage
     - parameter lighting: percent percentage
     - returns: lighter UIColor
     */
    func lighterColor(percent: Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 + percent/100));
    }
    
    /**
     Returns a darker color by the provided percentage
     - parameter darking: percent percentage
     - returns: darker UIColor
     */
    func darkerColor(percent: Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 - percent/100));
    }
    
    /**
     Return a modified color using the brightness factor provided
     - parameter factor: brightness factor
     - returns: modified color
     */
    func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        }
        else {
            return self;
        }
    }
    
    class func quoteChangeDirectionUpColor() -> UIColor {
        return UIColor.colorWithRGB(0x2D8704)
    }
    
    class func quoteChangeDirectionDownColor() -> UIColor {
        return UIColor.colorWithRGB(0xE40E0A)
    }
    
    class func quoteChangeDirecionUnchangedColor() -> UIColor {
        return UIColor.colorWithRGB(0x080808)
    }
}