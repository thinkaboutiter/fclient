//
//  BaseWebService.swift
//  FClient
//
//  Created by Boyan Yankov on W25 23/06/2016 Thu.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import Alamofire
import SimpleLogger

class BaseWebService {
    
    // MARK: - Properties
    
    var alamofireRequest: Alamofire.Request?
    
    // MARK: - Initialization
    
    init() {
        self.addTaskObservers()
    }
    
    deinit {
        self.removeTaskObservers()
    }
    
    /** httpVerb method */
    func httpVerb() -> Alamofire.Method {
        assert(false, "subclasses should override")
        return Method.GET
    }
    
    /** Request parameters encoding */
    func requestParametersEncoding() -> Alamofire.ParameterEncoding {
        return ParameterEncoding.URL
    }
    
    // MARK: Request
    
    /** Base endpoint for all services */
    class func baseEndpoint() -> String {
        return AppConstants.WebServiceProperties.baseURLString
    }
    
    /** Endpoint for particular web service */
    func instanceEndpoint() -> String {
        assert(false, "subclasses should override")
        return String()
    }
    
    /** Service endpoint complete URL */
    func serviceEndpoint() -> String {
        let baseEndpoint = self.dynamicType.baseEndpoint()
        let instanceEndpoint = self.instanceEndpoint()
        
        return "\(baseEndpoint)\(instanceEndpoint)"
    }
    
    /** Add parameters to the request. */
    func requestParameters() -> [String : AnyObject]? {
        assert(false, "subclasses should override")
        return nil
    }
    
    /** Request headers */
    func requestHeaders() -> [String : String]? {
        return BaseWebService.defaultRequestHeaders()
    }
    
    private class func defaultRequestHeaders() -> [String : String]? {
        
        // check sessionCookie
        guard let valid_SessionCookie: NSHTTPCookie = BaseWebService.getSessionCookie() else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid Session cookie")
            return nil
        }
        
        return [AppConstants.WebServiceProperties.sessionCookieName : valid_SessionCookie.value]
    }
    
    private static var sessionCookie: NSHTTPCookie?
    
    private class func getSessionCookie() -> NSHTTPCookie? {
        if let _ = BaseWebService.sessionCookie {
            return BaseWebService.sessionCookie
        }
        else {
            BaseWebService.sessionCookie = BaseWebService.findSessionCookie()
            return BaseWebService.sessionCookie
        }
    }
    
    private class func findSessionCookie() -> NSHTTPCookie? {
        // get `sharedHTTPCookieStorage`
        let cookieSorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        // check for cookies
        guard let valid_Cookies: [NSHTTPCookie] = cookieSorage.cookies else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » sharedHTTPCookieStorage has no cookies")
            return nil
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
        
        return sessionCookie
    }
    
    // MARK: - Life cycle
    
    func addTaskObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.startNetworkActivityIndicator), name: Notifications.Task.DidResume, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.stopNetworkActivityIndicator), name: Notifications.Task.DidSuspend, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.stopNetworkActivityIndicator), name: Notifications.Task.DidCancel, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.stopNetworkActivityIndicator), name: Notifications.Task.DidComplete, object: nil)
    }
    
    func removeTaskObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notifications.Task.DidResume, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notifications.Task.DidSuspend, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notifications.Task.DidCancel, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notifications.Task.DidComplete, object: nil)
    }
    
    // MARK: - Network Activity Indicator
    
    @objc func startNetworkActivityIndicator() {
        if !UIApplication.sharedApplication().networkActivityIndicatorVisible {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
    }
    
    @objc func stopNetworkActivityIndicator() {
        if UIApplication.sharedApplication().networkActivityIndicatorVisible {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}
