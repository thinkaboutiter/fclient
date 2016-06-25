//
//  UIViewController+Extensions.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Alerts

extension UIViewController {
    
    // MARK: - Error Alerts
    
    /**
     Show alert for error object with custom button and handler. Default alert title is "Error"
     - parameter error: Error object we are displaying alert for
     - parameter actionTitle: custom title for the action button
     - parameter actionHandler: custom handler
     */
    func showAlertForError(
        error: NSError,
        actionTitle: String = NSLocalizedString("OK", comment: "Generic error alertActionButton title"),
        actionHandler: ((action: UIAlertAction) -> Void)? = nil)
    {
        let alertMessage: String = error.localizedDescription
        self.showErrorAlertWithMessage(alertMessage, actionTitle: actionTitle, actionHandler: actionHandler)
    }
    
    /**
     Show alert for error object with additional button and handler. Default alert title is "Error"
     - parameter message: Alert message we want to display
     - parameter actionTitle: custom title for the action button
     - parameter actionHandler: custom handler
     */
    func showErrorAlertWithMessage(
        message: String,
        actionTitle: String = NSLocalizedString("OK", comment: "Generic error alertActionButton title"),
        actionHandler: ((action: UIAlertAction) -> Void)? = nil)
    {
        let alertTitle: String = NSLocalizedString("Error", comment: "Generic error alert title")
        
        self.showAlertWithTitle(alertTitle, alertMessage: message, actionTitle: actionTitle, actionHandler: actionHandler)
    }
    
    /**
     Show alert with button and handler.
     - parameter alertTitle: Alert title
     - parameter alertMessage: Alert message we want to display
     - parameter actionTitle: custom title for the action button
     - parameter actionHandler: custom handler
     */
    func showAlertWithTitle(
        alertTitle: String? = NSLocalizedString("Alert", comment: "Generic alert title"),
        alertMessage: String?,
        actionTitle: String = NSLocalizedString("OK", comment: "Generic alertActionButton title"),
        actionHandler: ((action: UIAlertAction) -> Void)? = nil)
    {
        // present alert to the user
        let alertController: UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let alertAction: UIAlertAction = UIAlertAction(title: actionTitle, style: .Default, handler: actionHandler)
        
        alertController.addAction(alertAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}