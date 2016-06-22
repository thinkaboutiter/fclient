//
//  Quote+CoreDataProperties.swift
//  FClient
//
//  Created by Boyan Yankov on W25 22/06/2016 Wed.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Quote {

    @NSManaged var ask: String?
    @NSManaged var bid: String?
    @NSManaged var change: NSNumber?
    @NSManaged var changeOrientation: NSNumber?
    @NSManaged var changePercentage: NSNumber?
    @NSManaged var currency: String?
    @NSManaged var date: NSDate?
    @NSManaged var displayName: String?
    @NSManaged var high: String?
    @NSManaged var low: String?
    @NSManaged var configuration: Configuration?

}
