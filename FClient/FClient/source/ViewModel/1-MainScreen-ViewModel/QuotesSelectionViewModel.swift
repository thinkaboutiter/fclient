//
//  QuotesSelectionViewModel.swift
//  FClient
//
//  Created by Boyan Yankov on W25 26/06/2016 Sun.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

// MARK: - QuotesSelectionViewModelConsumable Protocol
// Api for the View to Consume
protocol QuotesSelectionViewModelConsumable: class {
    init(withViewModel viewModel: QuotesSelectionViewModel)
    var viewModel: QuotesSelectionViewModel? { get }
}

// MARK: - QuotesSelectionViewModel

class QuotesSelectionViewModel: ViewModelable {
    
    // MARK: ViewType
    
    typealias ViewType = QuotesSelectionViewModelConsumable
    
    // MARK: Properties
    
    var title: String? {
        return NSLocalizedString("Add quote", comment: "QuotesSelectionViewModel title")
    }
    
    // view
    private(set) weak var view: QuotesSelectionViewModel.ViewType?
    
    let availableQuoteSymbols: [QuoteSymbol]
    private(set) var selectedQuoteSymbols: [QuoteSymbol] {
        didSet {
            Logger.logDebug().logMessage("\(self) \(#line) \(#function) » selectedQuoteSymbols updated: \(self.selectedQuoteSymbols)")
        }
    }
    
    // MARK: Cascaded accessors
    
    func updateView(view: ViewType) {
        self.view = view
    }
    
    func updatedSelectedQuoteSymbols(newValue: [QuoteSymbol]) {
        self.selectedQuoteSymbols = newValue
    }
    
    // MARK: Initialization
    
    init(withAvailableQuoteSymbols availableSymbols: [QuoteSymbol], selectedQuoteSymbols selectedSymbols: [QuoteSymbol]) {
        self.availableQuoteSymbols = availableSymbols
        self.selectedQuoteSymbols = selectedSymbols
    }
    
    deinit {
        Logger.logInfo().logMessage("\(self) \(#line) \(#function) » \(String(MainViewModel.self)) deinitialized")
    }
}

