//
//  UILabel+Extensions.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import UIKit
import SimpleLogger

extension UILabel {
    
    func configureAsQuoteLabelWithText(text: String?, andChangeOrientation changeOrientation: ChangeOrientation) -> UILabel {
        
        guard let valid_Text: String = text where valid_Text.characters.count > 1 else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid input text object")
            return self
        }
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .Left
        
        let baseFontSize: CGFloat = 14
        let baseFont = UIFont.systemFontOfSize(baseFontSize)
        let trailingFontSize: CGFloat = 16
        let trailingFont = UIFont.boldSystemFontOfSize(trailingFontSize)
        let fontColor = changeOrientation.orientationColor()
        
        let mutableAttributedString: NSMutableAttributedString = NSMutableAttributedString.attributedStringWithString(valid_Text) { (attributedString) in
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, valid_Text.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: fontColor, range: NSMakeRange(0, valid_Text.characters.count))
            attributedString.addAttribute(NSFontAttributeName, value: baseFont, range: NSMakeRange(0, valid_Text.characters.count - 2))
            attributedString.addAttribute(NSFontAttributeName, value: trailingFont, range: NSMakeRange(valid_Text.characters.count - 2, 2))
        }
        
        self.backgroundColor = UIColor.clearColor()
        self.attributedText = mutableAttributedString
        
        return self
    }
}