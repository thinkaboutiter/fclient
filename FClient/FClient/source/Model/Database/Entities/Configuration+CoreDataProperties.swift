//
//  Configuration+CoreDataProperties.swift
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

extension Configuration {

    @NSManaged var title: String?
    @NSManaged var quotes: NSSet?

}
