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
            .response(completionHandler: { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) in
                
                // log response objects
                Logger.logNetwork().logMessage("\(self) \(#line) \(#function) » request:").logObject(request)
                Logger.logNetwork().logMessage("\(self) \(#line) \(#function) » request.allHTTPHeaderFields:").logObject(request?.allHTTPHeaderFields)
                Logger.logNetwork().logMessage("\(self) \(#line) \(#function) » response:").logObject(response)
                
                // check response object
                guard let valid_Response: NSHTTPURLResponse = response else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid respone object")
                    
                    // create error object
                    let error: NSError = NSError(
                        domain: GetQuotesBySymbolsWebServiceError.domain(),
                        code: 418,
                        userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Invalid response object", comment: "GetQuotesBySymbolsWebServiceError description")
                        ])
                    
                    completion(error: error, resources: nil)
                    return
                }
                
                // check status code
                guard 200...299 ~= valid_Response.statusCode else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid status code: \(valid_Response.statusCode)")
                    
                    // create error object
                    let error: NSError = NSError(
                        domain: GetQuotesBySymbolsWebServiceError.domain(),
                        code: valid_Response.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Wrong status code: \(valid_Response.statusCode)", comment: "GetQuotesBySymbolsWebServiceError description")
                        ])
                    
                    completion(error: error, resources: nil)
                    return
                }
                
                // TODO: Save session cookie
                
                // check data
                guard let valid_Data: NSData = data else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid data received")
                    
                    // create error object
                    let error: NSError = NSError(
                        domain: GetQuotesBySymbolsWebServiceError.domain(),
                        code: valid_Response.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Invalid data received", comment: "GetQuotesBySymbolsWebServiceError description")
                        ])
                    
                    completion(error: error, resources: nil)
                    return
                }
                
                // check serialized object
                guard let valid_SerializedJSON: AnyObject = self.serializeData(valid_Data) else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to serialize data")
                    
                    // create error object
                    let error: NSError = NSError(
                        domain: GetQuotesBySymbolsWebServiceError.domain(),
                        code: valid_Response.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Unable to serialize data", comment: "GetQuotesBySymbolsWebServiceError description")
                        ])
                    
                    completion(error: error, resources: nil)
                    return
                }
                
                guard let valid_JSONResponse: [[String: AnyObject]] = valid_SerializedJSON as? [[String: AnyObject]] else {
                    Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to serialize received data")
                    
                    // create error object
                    let error: NSError = NSError(
                        domain: GetQuotesBySymbolsWebServiceError.domain(),
                        code: valid_Response.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString(" Unable to serialize received data", comment: "GetQuotesBySymbolsWebServiceError description")
                        ])
                    
                    completion(error: error, resources: nil)
                    return
                }
                
                let resources: [QuoteResource] = self.parseResponse(valid_JSONResponse)
                
                // send success completion
                completion(error: nil, resources: resources)
            })
    }
    
    private func serializeData(data: NSData) -> AnyObject? {
        
        // check dataString
        guard let valid_DataString: String = String(data: data, encoding: NSUTF8StringEncoding) else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to decode data to string")
            return nil
        }
        
        let charactersToRemove: [Character] = ["(", ")"]
        let formattedString: String = valid_DataString.removeCharacters(charactersToRemove)
        
        // check JSONData
        guard let valid_JSONData: NSData = formattedString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to encode data")
            return nil
        }
        
        // try to create JSON object
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(valid_JSONData, options: .AllowFragments)
            return jsonObject
        }
        catch {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Serializing error: \(error)")
            return nil
        }
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