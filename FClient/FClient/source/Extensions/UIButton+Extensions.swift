//
//  UIButton+Extensions.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func configureAsQuoteActionButtonWithTitle(title: String) -> UIButton {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .Center
        
        let fontSize: CGFloat = 14
        let font = UIFont.systemFontOfSize(fontSize)
        let fontColor = UIColor.whiteColor()
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString.attributedStringWithString(title) { (attributedString) in
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, title.characters.count))
            attributedString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, title.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: fontColor, range: NSMakeRange(0, title.characters.count))
        }
        
        self.setAttributedTitle(attrString, forState: .Normal)
        
        self.backgroundColor = UIColor.quoteActionButtonBackgroundColor()
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
        
        return self
    }
}