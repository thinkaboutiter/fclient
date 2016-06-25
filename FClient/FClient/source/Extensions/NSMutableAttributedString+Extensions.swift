//
//  NSMutableAttributedString+Extensions.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    class func attributedStringWithString(string: String?, applyAttributes: ((attributedString: NSMutableAttributedString) -> Void)) -> NSMutableAttributedString {
        let attrStr: NSMutableAttributedString = NSMutableAttributedString(string: string ?? "")
        attrStr.beginEditing()
        applyAttributes(attributedString: attrStr)
        attrStr.endEditing()
        return attrStr
    }
}