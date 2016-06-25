//
//  String+Extensions.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation

extension String {
    
    func removeCharacters(characters: [Character]) -> String {
        return String(self.characters.filter({ !characters.contains($0) }))
    }
}