//
//  MainViewModel.swift
//  FClient
//
//  Created by Boyan Yankov on W25 22/06/2016 Wed.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

// MARK: - OverviewViewModelConsumable Protocol
// Api for the View to Consume
protocol MainViewModelConsumable: class {
    init(withViewModel viewModel: MainViewModel)
    var viewModel: MainViewModel? { get }
}

// MARK: - MainViewModelError enum

enum MainViewModelError: ErrorType {
    case GeneralError(error: NSError)
    
    static func domain() -> String {
        return "MainViewModelErrorDomain"
    }
}

// MARK: - QuoteSymbol enum

enum QuoteSymbol: String {
    // initial
    case EURUSD
    case GBPUSD
    case USDCHF
    case USDJPY
    
    // additional
    case AUDUSD
    case USDCAD
    case GBPJPY
    case EURGBP
    case EURJPY
    case AUDCAD
    
    static func initialQuoteSymbols() -> [QuoteSymbol] {
        return [
            EURUSD,
            GBPUSD,
            USDCHF,
            USDJPY
        ]
    }
    
    static func additionalQuoteSymbols() -> [QuoteSymbol] {
        return [
            AUDUSD,
            USDCAD,
            GBPJPY,
            EURGBP,
            EURJPY,
            AUDCAD
        ]
    }
    
    static func allQuoteSymbols() -> [QuoteSymbol] {
        return QuoteSymbol.initialQuoteSymbols() + QuoteSymbol.additionalQuoteSymbols()
    }
}

// MARK: - ChangeOrientation enum

enum ChangeOrientation: Int {
    case Up = 1
    case Down = 2
    case Unchanged = 3
    
    func orientationColor() -> UIColor {
        switch self {
        case .Up:
            return UIColor.quoteChangeDirectionUpColor()
        
        case .Down:
            return UIColor.quoteChangeDirectionDownColor()
            
        case .Unchanged:
            return UIColor.quoteChangeDirecionUnchangedColor()
        }
    }
}

// MARK: - MainViewModel

class MainViewModel: ViewModelable {
    
    // MARK: ViewType
    
    typealias ViewType = MainViewModelConsumable
    
    // MARK: Properties
    
    var title: String? {
        return NSLocalizedString("Quotes", comment: "MainViewModel title")
    }
    
    // view
    private(set) weak var view: MainViewModel.ViewType?
    
    private(set) var quoteSymbols: [QuoteSymbol] = QuoteSymbol.initialQuoteSymbols() {
        didSet {
//            Logger.logDebug().logMessage("\(self) \(#line) \(#function) » quoteSymbols updated: \(self.quoteSymbols)")
            
            // delete session cookie
            self.deleteSessionCookie()
        }
    }
    private lazy var getQuotesBySymbolsWebService: GetQuotesBySymbolsWebService = {
       return GetQuotesBySymbolsWebService()
    }()
    
    // MARK: Cascaded accessors
    
    func updateView(view: ViewType) {
        self.view = view
    }
    
    func updateQuoteSymbols(newValue: [QuoteSymbol]) {
        self.quoteSymbols = newValue
    }
    
    // MARK: Initialization
    
    init() {
        
    }
    
    deinit {
        Logger.logInfo().logMessage("\(self) \(#line) \(#function) » \(String(MainViewModel.self)) deinitialized")
    }
    
    // MARK: - Network
    
    func fetchQuotesForSymbols(quoteSymbols: [QuoteSymbol], completion: (error: NSError?) -> Void) {
        // start WebService
        self.getQuotesBySymbolsWebService.fetchQuotesForSymbols(quoteSymbols) { (error: NSError?, resources: [QuoteResource]?) in
            
            // check error object
            guard error == nil else {
                completion(error: error!)
                return
            }
            
            // check resources object
            guard let valid_Resources: [QuoteResource] = resources else {
                // create error object
                let error: NSError = NSError(
                    domain: MainViewModelError.domain(),
                    code: 418,
                    userInfo: [
                        NSLocalizedDescriptionKey: NSLocalizedString("Invalid response object", comment: "MainViewModelError localized desctiption")
                    ])
                
                completion(error: error)
                return
            }
            
            self.handleWebServiceResponse(valid_Resources, completion: completion)
        }
    }
    
    private func handleWebServiceResponse(response: [QuoteResource], completion: (error: NSError?) -> Void) {
        
        // cache QuoteResource to database
        // dispatch group
        let saveGroup: dispatch_group_t = dispatch_group_create()
        
        for quoteResource in response {
            dispatch_group_enter(saveGroup)
            
            // create Quote object
            Quote.createOrUpdateWithResource(quoteResource, completion: { 
                dispatch_group_leave(saveGroup)
            })
        }
        
        // when ready proceed with completion
        dispatch_group_notify(saveGroup, dispatch_get_main_queue(), {
            completion(error: nil)
        })
    }
    
    private func deleteSessionCookie() {
        // get `sharedHTTPCookieStorage`
        let cookieSorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        // check for cookies
        guard let valid_Cookies: [NSHTTPCookie] = cookieSorage.cookies else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » sharedHTTPCookieStorage has no cookies")
            return
        }
        
        var sessionCookie: NSHTTPCookie?
        
        // enumerate `valid_Cookies`
        for cookie in valid_Cookies {
            
            // check for session cookie
            if cookie.name == AppConstants.WebServiceProperties.sessionCookieName {
                sessionCookie = cookie
                break
            }
        }
        
        if let validSessionCookie: NSHTTPCookie = sessionCookie {
            cookieSorage.deleteCookie(validSessionCookie)
            
            Logger.logWarning().logMessage("\(self) \(#line) \(#function) » Session cookie deleted")
        }
        
    }
}