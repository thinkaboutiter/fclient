//
//  AppDelegate.swift
//  FClient
//
//  Created by Boyan Yankov on W25 21/06/2016 Tue.
//  Copyright © 2016 Boyan Yankov. All rights reserved.
//

import UIKit
import SimpleLogger
import MagicalRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    private let sqliteStoreName: String = "Model.sqlite"

    // MARK: - Life cycle

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.configureSimpleLogger()
        
        // setup core data stack
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed(self.sqliteStoreName)
        
        // log sqlite file location
        Logger.logCache().logMessage("\(self) \(#line) \(#function) » DB file location: \(NSPersistentStore.MR_urlForStoreName(self.sqliteStoreName))")
        
        // initial configuration
        self.setupInitialConfiguration()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        MagicalRecord.cleanUp()
    }

    // MARK: - Configurations (private)
    
    private func configureSimpleLogger() {
        // enable logging
        #if DEBUG
            SimpleLogger.enableLogging(true)
        #endif
    }
    
    private func setupInitialConfiguration() {
        
        // check to see if there is a Configuration object in data base, if not create one
        if Configuration.MR_findFirstByAttribute(Configuration.title_AttributeName, withValue: Configuration.defaultTitle) == nil {
            
            Logger.logInfo().logMessage("\(self) \(#line) \(#function) » Creating default configuration")
            
            MagicalRecord.saveWithBlockAndWait({ (context: NSManagedObjectContext) in
                guard let newConfiguration: Configuration = Configuration.MR_createEntityInContext(context) else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to create \(String(Configuration.self)) object")
                    return
                }
                
                // set title
                newConfiguration.title = Configuration.defaultTitle
                
                // create initial Quotes
                for quoteSymbol in QuoteSymbol.initialQuoteSymbols() {
                    
                    guard let newQuote: Quote = Quote.MR_createEntityInContext(context) else {
                        Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to create \(String(Quote.self)) object")
                        break
                    }
                    
                    newQuote.currency = quoteSymbol.rawValue
                    newQuote.displayName = quoteSymbol.rawValue
                    
                    // set relation
                    newQuote.configuration = newConfiguration
                }
            })
        }
        else {
            Logger.logInfo().logMessage("\(self) \(#line) \(#function) » Default configuration is present")
        }
    }
}

