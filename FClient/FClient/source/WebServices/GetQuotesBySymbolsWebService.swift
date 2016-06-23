//
//  GetQuotesBySymbolsWebService.swift
//  FClient
//
//  Created by Boyan Yankov on W25 23/06/2016 Thu.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import Alamofire
import SimpleLogger
import ObjectMapper

// MARK: - GetQuotesBySymbolsWebServiceError enum

enum GetQuotesBySymbolsWebServiceError: ErrorType {
    case GeneralError(error: NSError)
    
    static func domain() -> String {
        return "GetQuotesBySymbolsWebServiceErrorDomain"
    }
}

// MARK: - GetQuotesBySymbolsWebService

class GetQuotesBySymbolsWebService: BaseWebService {
    
    // MARK: Properties
    
    // MARK: Initialization
    
    override init() {
        super.init()
    }
    
    deinit {
        self.removeTaskObservers()
    }
    
    override func httpVerb() -> Alamofire.Method {
        return Method.GET
    }
    
    // MARK: Request
    
    override func instanceEndpoint() -> String {
        return "QuotesBox/quotes/GetQuotesBySymbols"
    }
    
    // MARK: Networking
    
    func fetchQuotesForSymbols(symbols: [QuoteSymbol], completion: (error: NSError?, resources: [QuoteResource]?) -> Void) {
        let symbolsParameter: String = symbols.map { (quoteSymbol: QuoteSymbol) -> String in
            return quoteSymbol.rawValue
        }.joinWithSeparator(",")
        
        // start WS
        self.alamofireRequest = Alamofire
            .request(
                self.httpVerb(),
                self.serviceEndpoint(),
                parameters: [
                    "languageCode": "en-US",
                    "symbols": symbolsParameter
                ],
                encoding: self.requestParametersEncoding(),
                headers: self.requestHeaders())
            .responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                
                // log response objects
                Logger.logNetwork().logMessage("\(self) \(#line) \(#function) » request:").logObject(response.request)
                Logger.logNetwork().logMessage("\(self) \(#line) \(#function) » allHTTPHeaderFields:").logObject(response.request?.allHTTPHeaderFields)
                Logger.logNetwork().logMessage("\(self) \(#line) \(#function) » response:").logObject(response.response)
                
                // check for success
                guard response.result.isSuccess else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Error fetching data").logObject(response.result.error)
                    
                    completion(error: response.result.error, resources: nil)
                    return
                }
                
                // check response object
                guard let validResponse: NSHTTPURLResponse = response.response else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid respone object")
                    
                    // create error object
                    let error: NSError = NSError(
                        domain: GetQuotesBySymbolsWebServiceError.domain(),
                        code: 418,
                        userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Invalid respone object", comment: "GetQuotesBySymbolsWebServiceError description")
                        ])
                    
                    completion(error: error, resources: nil)
                    return
                }
                
                // check status code
                guard 200...299 ~= validResponse.statusCode else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid status code: \(validResponse.statusCode)")
                    
                    // create error object
                    let error: NSError = NSError(
                        domain: GetQuotesBySymbolsWebServiceError.domain(),
                        code: validResponse.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Wrong status code: \(validResponse.statusCode)", comment: "GetQuotesBySymbolsWebServiceError description")
                        ])
                    
                    completion(error: error, resources: nil)
                    return
                }
                
                // check result object
                guard let validResultObject: [[String: AnyObject]] = response.result.value as? [[String: AnyObject]] else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid result object")
                    
                    // create error object
                    let error: NSError = NSError(
                        domain: GetQuotesBySymbolsWebServiceError.domain(),
                        code: 418,
                        userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Invalid result object", comment: "GetQuotesBySymbolsWebServiceError description")
                        ])
                    
                    completion(error: error, resources: nil)
                    return
                }
                
                let resources: [QuoteResource] = self.parseResponse(validResultObject)
                
                // send success completion
                completion(error: nil, resources: resources)
            })
    }
    
    private func parseResponse(response: [[String: AnyObject]]) -> [QuoteResource] {
        let resources: [QuoteResource] = response.flatMap { (element: [String : AnyObject]) -> QuoteResource? in
            if let valid_QuoteResource: QuoteResource = Mapper<QuoteResource>().map(element) {
                return valid_QuoteResource
            }
            return nil
        }
        
        Logger.logSuccess().logMessage("\(self) \(#line) \(#function) » Created \(resources.count) \(String(QuoteResource.self)) objects")
        
        return resources
    }
}