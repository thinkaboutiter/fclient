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
    
    static func allQuoteSymbols() -> [QuoteSymbol] {
        return [
            EURUSD,
            GBPUSD,
            USDCHF,
            USDJPY,
            AUDUSD,
            USDCAD,
            GBPJPY,
            EURGBP,
            EURJPY,
            AUDCAD
        ]
    }
}

// MARK: - ChangeOrientation enum

enum ChangeOrientation: UInt {
    case Up = 1
    case Down = 2
    case Unchanged = 3
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
    
    // MARK: Cascaded accessors
    
    func updateView(view: ViewType) {
        self.view = view
    }
    
    // MARK: Initialization
    
    init() {
        
    }
    
    deinit {
        Logger.logInfo().logMessage("\(self) \(#line) \(#function) » \(String(MainViewModel.self)) deinitialized")
    }
}