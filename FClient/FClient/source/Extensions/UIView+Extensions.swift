//
//  UIView+Extensions.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func configureAsQuoteHolderView() -> UIView {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.quoteHolderViewBorderColor().CGColor
        self.clipsToBounds = true
        
        return self
    }
}