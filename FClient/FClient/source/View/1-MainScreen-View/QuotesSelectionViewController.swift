//
//  QuotesSelectionViewController.swift
//  FClient
//
//  Created by Boyan Yankov on W25 26/06/2016 Sun.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SimpleLogger

class QuotesSelectionViewController: BaseViewController, QuotesSelectionViewModelConsumable {
    
    // MARK: Properties
    
    private(set) var viewModel: QuotesSelectionViewModel? {
        didSet {
            self.viewModel?.updateView(self)
        }
    }
    
    @IBOutlet weak var quotesSelectionTableView: UITableView!
    
    // MARK: Cascaded accessors
    
    func updateViewModel(viewModel: QuotesSelectionViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: Intitialization
    
    required init(withViewModel viewModel: QuotesSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        Logger.logInfo().logMessage("\(self) \(#line) \(#function) » \(String(QuotesSelectionViewController.self)) deinitialized")
    }
    
    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.quotesSelectionTableView.delegate = self
        self.quotesSelectionTableView.dataSource = self
        
        self.quotesSelectionTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: String(UITableViewCell.self))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - UITableViewDataSource protocol

extension QuotesSelectionViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let valid_ViewModel: QuotesSelectionViewModel = self.viewModel else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid \(String(QuotesSelectionViewModel.self)) object")
            return 0
        }
        
        return valid_ViewModel.availableQuoteSymbols.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(String(UITableViewCell.self), forIndexPath: indexPath)
        
        guard let valid_ViewModel: QuotesSelectionViewModel = self.viewModel else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid \(String(QuotesSelectionViewModel.self)) object")
            return cell
        }
        
        let quoteSymbol: QuoteSymbol = valid_ViewModel.availableQuoteSymbols[indexPath.row]
        
        cell.textLabel?.text = quoteSymbol.rawValue
        
        // determine if cell is selected
        if let _ = valid_ViewModel.selectedQuoteSymbols.indexOf(quoteSymbol) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate protocol

extension QuotesSelectionViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // check ViewModel
        guard let valid_ViewModel: QuotesSelectionViewModel = self.viewModel else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid \(String(QuotesSelectionViewModel.self)) object")
            return
        }
        
        // check cell
        guard let valid_Cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath) else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid cell selection for indexPath: \(indexPath)")
            return
        }
        
        let quoteSymbol: QuoteSymbol = valid_ViewModel.availableQuoteSymbols[indexPath.row]
        let newSelectedQuoteSymbols: [QuoteSymbol]
        
        // check if this symbol has been already selected - remove it if so
        if let _ = valid_ViewModel.selectedQuoteSymbols.indexOf(quoteSymbol) {
            // remove symbol from selected ones
             newSelectedQuoteSymbols = valid_ViewModel.selectedQuoteSymbols.filter({ (element: QuoteSymbol) -> Bool in
                return element != quoteSymbol
            })
            
            // mark cell as not selected
            valid_Cell.accessoryType = .None
        }
        // add new symbol to selected list
        else {
            newSelectedQuoteSymbols = valid_ViewModel.selectedQuoteSymbols + [quoteSymbol]
            
            // mark cell as selected
            valid_Cell.accessoryType = .Checkmark
        }
        
        // update slectedQuoteSybols on ViewModel object
        valid_ViewModel.updatedSelectedQuoteSymbols(newSelectedQuoteSymbols)
        
        // TODO: update data on MainVC model so it is displayed
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
