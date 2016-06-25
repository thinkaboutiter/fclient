//
//  MainViewController.swift
//  FClient
//
//  Created by Boyan Yankov on W25 21/06/2016 Tue.
//  Copyright © 2016 Boyan Yankov. All rights reserved.
//

import UIKit
import SimpleLogger
import MagicalRecord

// MARK: - MainViewController

class MainViewController: BaseViewController, MainViewModelConsumable {

    // MARK: Properties
    
    private(set) var viewModel: MainViewModel? {
        didSet {
            self.viewModel?.updateView(self)
        }
    }
    
    // MARK: Cascaded accessors
    
    func updateViewModel(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: Intitialization
    
    required init(withViewModel viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        Logger.logInfo().logMessage("\(self) \(#line) \(#function) » \(String(MainViewController.self)) deinitialized")
    }
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // set viewModel object
        self.viewModel = MainViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.checkCoreDataObjects()
    }
    
    override func configureUI() {
        self.title = self.viewModel?.title
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchQuotes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func refreshButtonTapped(sender: UIButton) {
        self.fetchQuotes()
    }
    
    // MARK: Network
    
    private func fetchQuotes() {
        guard let valid_ViewModel: MainViewModel = self.viewModel else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid \(String(MainViewModel.self)) object")
            return
        }
        
        valid_ViewModel.fetchQuotesForSymbols(valid_ViewModel.quoteSymbols) { (error: NSError?) in
            
            // check for error
            guard error == nil else {
                Logger.logError().logMessage("\(self) \(#line) \(#function) » unable to fetch quotes").logObject(error)
                
                self.showAlertForError(error!, actionHandler: { (action: UIAlertAction) in
                    // completion if needed
                })
                return
            }
            
            // refresh
            self.refreshUI()
        }
    }
    
    private func refreshUI() {
        Logger.logDebug().logMessage("\(self) \(#line) \(#function) » ")
    }

/*
    // testing
    private func checkCoreDataObjects() {
        
        guard let valid_Configuration: Configuration = Configuration.MR_findFirstByAttribute(Configuration.title_AttributeName, withValue: Configuration.defaultTitle) else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to find \(String(Configuration.self)) object in database")
            return
        }
        
        Logger.logCache().logMessage("\(self) \(#line) \(#function) » \(String(Configuration.self)) object found").logObject(valid_Configuration)
    }
 */
}
