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

class Quote: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass
    
    static let currency_AttributeName: String = "currency"
    static let displayName_AttributeName: String = "displayName"

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
