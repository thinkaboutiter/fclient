//
//  ViewModelable.swift
//  FClient
//
//  Created by Boyan Yankov on W25 22/06/2016 Wed.
//  Copyright © 2016 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation

/**
 * Adopted by all `viewModel` objects implicitly
 */
protocol ViewModelable: class {
    /**
     * Associateted **Type** of `View` object
     */
    associatedtype ViewType
    
    /**
     * `View` object baked by `ViewModel`
     */
    var view: ViewType? { get }
    
    /**
     * API for modifying the `View` object
     */
    func updateView(newView: ViewType)
    
    /**
     * Title of `View` object.
     * In case of **UIViewController** - `self.title`
     */
    var title: String? { get }
}
