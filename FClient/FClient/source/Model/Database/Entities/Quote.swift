//
//  Quote.swift
//  FClient
//
//  Created by Boyan Yankov on W25 22/06/2016 Wed.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper
import SimpleLogger
import MagicalRecord

class Quote: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass
    
    static let currency_AttributeName: String = "currency"
    static let displayName_AttributeName: String = "displayName"
    
    class func createOrUpdateWithResource(resource: QuoteResource, completion: (() -> Void)? = nil) {
        
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext) in
            // fetch configurtation
            guard let valid_Configuration: Configuration = Configuration.MR_findFirstByAttribute(Configuration.title_AttributeName, withValue: Configuration.defaultTitle) else {
                Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to find \(String(Configuration.self)) object in database")
                return
            }
            
            // fetch or create Quote object
            let quote: Quote = Quote.MR_findFirstOrCreateByAttribute(Quote.currency_AttributeName, withValue: resource.currency!, inContext: context)
            
            // update
            quote.updateWithMappable(resource, andConfiguration: valid_Configuration)
            
        }) { (success: Bool, error: NSError?) in
            // this executes on main thread
            completion?()
        }
    }
    
    private func updateWithMappable(input: QuoteResource, andConfiguration configuration: Configuration) {
        self.ask = input.ask
        self.bid = input.bid
        
        if let _ = input.change {
            self.change = NSNumber(double: input.change!)
        }
        
        if let _ = input.changeOrientation {
            self.changeOrientation = NSNumber(integer: input.changeOrientation!)
        }
        
        if let _ = input.changePercentage {
            self.changePercentage = NSNumber(double: input.changePercentage!)
        }
        
        self.currency = input.currency
        self.date = input.date
        self.displayName = input.displayName
        self.high = input.high
        self.low = input.low
        
        // set relation
        self.configuration = configuration
    }
}

struct QuoteResource: Mappable {
    
    // MARK: Properties
    
    var ask: String?
    var bid: String?
    var change: Double?
    var changeOrientation: Int?
    var changePercentage: Double?
    var currency: String?
    var date: NSDate?
    var displayName: String?
    var high: String?
    var low: String?
    
    // MARK: Initialization

    init?(_ map: Map) {
        /*
         This failable initializer can be used for JSON validation prior to object serialization.
         Returning nil within the function will prevent the mapping from occuring.
         */
        
        // validations
        // `ask`
        if map.JSONDictionary["Ask"] == nil {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to create \(String(QuoteResource.self)) object - Invalid `Ask` value")
            return nil
        }
        
        // `bid`
        if map.JSONDictionary["Bid"] == nil {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to create \(String(QuoteResource.self)) object - Invalid `Bid` value")
            return nil
        }
        
        // `changeOrientation`
        if map.JSONDictionary["ChangeOrientation"] == nil {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to create \(String(QuoteResource.self)) object - Invalid `ChangeOrientation` value")
            return nil
        }
        
        // `currency`
        if map.JSONDictionary["Currency"] == nil {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to create \(String(QuoteResource.self)) object - Invalid `Currency` value")
            return nil
        }
        
        // `displayName`
        if map.JSONDictionary["DisplayName"] == nil {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to create \(String(QuoteResource.self)) object - Invalid `DisplayName` value")
            return nil
        }
    }
    
    // MARK: Mapping
    
    mutating func mapping(map: Map) {
        self.ask <- map["Ask"]
        self.bid <- map["Bid"]
        self.change <- map["Change"]
        self.changeOrientation <- map["ChangeOrientation"]
        self.changePercentage <- map["ChangePercentage"]
        self.currency <- map["Currency"]
        
        // we do not map `date` since it is not in UNIX timestamp
        
        self.displayName <- map["DisplayName"]
        self.high <- map["High"]
        self.low <- map["Low"]
    }
}
