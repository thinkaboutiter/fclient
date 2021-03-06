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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var quotesTableView: QuotesTableView!
    @IBOutlet weak var quotesCollectionView: UICollectionView!
    
    /*
     source: https://gist.github.com/Lucien/4440c1cba83318e276bb
     source: http://stackoverflow.com/questions/20554137/nsfetchedresultscontollerdelegate-for-collectionview
     */
    private var blockOperations: [NSBlockOperation] = []
    
    private var listFRC: NSFetchedResultsController {
        return Quote.MR_fetchAllSortedBy(Quote.displayName_AttributeName, ascending: true, withPredicate: self.symbolsCompoundPredicate, groupBy: nil, delegate: self)
    }
    
    private var boxesFRC: NSFetchedResultsController {
        return Quote.MR_fetchAllSortedBy(Quote.displayName_AttributeName, ascending: true, withPredicate: self.symbolsCompoundPredicate, groupBy: nil, delegate: self)
    }
    
    private var symbolsCompoundPredicate: NSCompoundPredicate? {
        guard let valid_ViewModel: MainViewModel = self.viewModel else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid \(String(MainViewModel.self)) object")
            return nil
        }
        
        var predicates: [NSPredicate] = []
        
        for quoteSymbol in valid_ViewModel.quoteSymbols {
            let predicate: NSPredicate = NSPredicate(format: "\(Quote.displayName_AttributeName) == %@", quoteSymbol.rawValue)
            predicates.append(predicate)
        }
        
        let compoundPredicate: NSCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        
        return compoundPredicate
    }
    
    private var timer: NSTimer?
    
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
        // Cancel all block operations when VC deallocates
        for operation: NSBlockOperation in self.blockOperations {
            operation.cancel()
        }
        
        self.blockOperations.removeAll(keepCapacity: false)
        
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
        // setup quotesTableView
        self.quotesTableView.delegate = self
        self.quotesTableView.dataSource = self
        self.quotesTableView.separatorStyle = .None
        
        self.quotesTableView.registerClass(QuotesTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: String(QuotesTableViewHeaderFooterView.self))
        
        // setup quotesCollectionView
        self.quotesCollectionView.hidden = true
        self.quotesCollectionView.delegate = self
        self.quotesCollectionView.dataSource = self
    }
    
    override func configureUI() {
        self.title = self.viewModel?.title
        
        // add test button during development
//        self.addRefreshButton()
        
        self.addPlusButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.configureTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addRefreshButton() {
        if let _ = self.navigationController {
            let refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(self.refreshButtonTapped(_:)))
            self.navigationItem.leftBarButtonItem = refreshButton
        }
    }
    
    private func addPlusButton() {
        if let _ = self.navigationController {
            let plusButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.plusButtonTapped(_:)))
            self.navigationItem.rightBarButtonItem = plusButton
        }
    }
    
    private let refreshTimeInterval: NSTimeInterval = 0.5
    private let refreshTolerance: NSTimeInterval = 0.05
    
    private func configureTimer(shouldStart shouldStart: Bool = true) {
        self.timer?.invalidate()
        self.timer = nil
        
        if shouldStart {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.refreshTimeInterval, target: self, selector: #selector(self.fetchQuotes), userInfo: nil, repeats: true)
            self.timer?.tolerance = self.refreshTolerance
            self.timer?.fire()
        }
    }
    
    // MARK: Actions
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.quotesTableView.hidden = false
            self.quotesCollectionView.hidden = true
            
        case 1:
            self.quotesTableView.hidden = true
            self.quotesCollectionView.hidden = false
        default:
            break
        }
    }
    
    @objc private func refreshButtonTapped(sender: UIBarButtonItem) {
        self.fetchQuotes()
    }
    
    @objc private func plusButtonTapped(sender: UIBarButtonItem) {
        
        guard let valid_ViewModel: MainViewModel = self.viewModel else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid \(String(MainViewModel.self)) object")
            return
        }
        
        guard let valid_QuotesSelectionVC: QuotesSelectionViewController = self.storyboard?.instantiateViewControllerWithIdentifier(String(QuotesSelectionViewController.self)) as? QuotesSelectionViewController else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to instantiate \(String(QuotesSelectionViewController.self)) object")
            return
        }
        
        // determine additionally selected symbols
        let selectedSymbols: [QuoteSymbol] = valid_ViewModel.quoteSymbols.filter { (element: QuoteSymbol) -> Bool in
            return !QuoteSymbol.initialQuoteSymbols().contains(element)
        }
        
        // create and set viewModel object on `valid_QuotesSelectionVC`
        let quotesSelectionVM: QuotesSelectionViewModel = QuotesSelectionViewModel(withAvailableQuoteSymbols: QuoteSymbol.additionalQuoteSymbols(), selectedQuoteSymbols: selectedSymbols)
        valid_QuotesSelectionVC.updateViewModel(quotesSelectionVM)
        
        // update selection consumable delegate
        valid_QuotesSelectionVC.updateQuoteSelectionConsumableDelegate(self)
        
        self.navigationController?.pushViewController(valid_QuotesSelectionVC, animated: true)
    }
    
    // MARK: Network
    
    @objc private func fetchQuotes() {
        guard let valid_ViewModel: MainViewModel = self.viewModel else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid \(String(MainViewModel.self)) object")
            return
        }
        
        valid_ViewModel.fetchQuotesForSymbols(valid_ViewModel.quoteSymbols) { (error: NSError?) in
            
            // check for error
            guard error == nil else {
                Logger.logError().logMessage("\(self) \(#line) \(#function) » unable to fetch quotes").logObject(error)
                
                // stop timer
                self.configureTimer(shouldStart: false)
                
                self.showAlertForError(error!, actionHandler: { (action: UIAlertAction) in
                    // completion if needed
                    self.configureTimer()
                })
                return
            }
            
            // refresh
            self.refreshUI()
        }
    }
    
    private func refreshUI() {
        Logger.logDebug().logMessage("\(self) \(#line) \(#function) » ")
        
        self.quotesTableView.reloadData()
        self.quotesCollectionView.reloadData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate protocol

extension MainViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        if controller == self.listFRC {
            self.quotesTableView.beginUpdates()
        }
        
        if controller == self.boxesFRC {
            self.blockOperations.removeAll(keepCapacity: false)
        }
    }
    
    func controller(
        controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        
        if controller == self.listFRC {
            switch type {
            case .Insert:
                self.quotesTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.quotesTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                break
            }
        }
        
        if controller == self.boxesFRC {
            switch type {
            case .Insert:
                self.blockOperations.append(
                    NSBlockOperation(block: { [unowned self] in
                        self.quotesCollectionView.insertSections(NSIndexSet(index: sectionIndex))
                    })
                )
                
            case .Delete:
                self.blockOperations.append(
                    NSBlockOperation(block: { [unowned self] in
                        self.quotesCollectionView.deleteSections(NSIndexSet(index: sectionIndex))
                    })
                )
                
            case .Update:
                self.blockOperations.append(
                    NSBlockOperation(block: { [unowned self] in
                        self.quotesCollectionView.reloadSections(NSIndexSet(index: sectionIndex))
                    })
                )
                
            default:
                break
            }
        }
    }
    
    func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        guard let valid_IndexPath: NSIndexPath = indexPath else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid indexPaht parameter")
            return
        }
        
        guard let valid_NewIndexPath: NSIndexPath = newIndexPath else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid newIndexPaht parameter")
            return
        }
        
        if controller == self.listFRC {
            switch type {
            case .Insert:
                self.quotesTableView.insertRowsAtIndexPaths([valid_IndexPath], withRowAnimation: .Fade)
                
            case .Delete:
                self.quotesTableView.deleteRowsAtIndexPaths([valid_IndexPath], withRowAnimation: .Fade)
                
            case .Move:
                if (valid_IndexPath.section != valid_NewIndexPath.section || valid_IndexPath.row != valid_NewIndexPath.row) {
                    self.quotesTableView.deleteRowsAtIndexPaths([valid_IndexPath], withRowAnimation: .Fade)
                    self.quotesTableView.insertRowsAtIndexPaths([valid_NewIndexPath], withRowAnimation: .Fade)
                    
                    self.quotesTableView.reloadSections(NSIndexSet(index: valid_IndexPath.section), withRowAnimation: .Fade)
                    self.quotesTableView.reloadSections(NSIndexSet(index: valid_NewIndexPath.section), withRowAnimation: .Fade)
                }
                
            case .Update:
                self.quotesTableView.reloadRowsAtIndexPaths([valid_IndexPath], withRowAnimation: .Fade)
            }
        }
        
        if controller == self.boxesFRC {
            switch type {
            case .Insert:
                self.blockOperations.append(
                    NSBlockOperation(block: { [unowned self] in
                        self.quotesCollectionView.insertItemsAtIndexPaths([valid_NewIndexPath])
                    })
                )
            
            case .Delete:
                self.blockOperations.append(
                    NSBlockOperation(block: { [unowned self] in
                        self.quotesCollectionView.deleteItemsAtIndexPaths([valid_IndexPath])
                    })
                )
                
            case .Move:
                self.blockOperations.append(
                    NSBlockOperation(block: { [unowned self] in
                        self.quotesCollectionView.moveItemAtIndexPath(valid_IndexPath, toIndexPath: valid_NewIndexPath)
                    })
                )
                
            case .Update:
                self.blockOperations.append(
                    NSBlockOperation(block: { [unowned self] in
                        self.quotesCollectionView.reloadItemsAtIndexPaths([valid_IndexPath])
                    })
                )
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        if controller == self.listFRC {
            self.quotesTableView.endUpdates()
        }
        
        if controller == self.boxesFRC {
            self.quotesCollectionView.performBatchUpdates({ () -> Void in
                for operation: NSBlockOperation in self.blockOperations {
                    operation.start()
                }
            },
            completion: { (finished) -> Void in
                self.blockOperations.removeAll(keepCapacity: false)
            })
        }
    }
}

// MARK: - UITableViewDataSource protocol

extension MainViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let valid_FrcSections: [NSFetchedResultsSectionInfo] = self.listFRC.sections where valid_FrcSections.count > 0 else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid sections object on \(String(NSFetchedResultsController.self)) object")
            return 0
        }
        
        let sectionInfo: NSFetchedResultsSectionInfo = valid_FrcSections[0]
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let valid_Cell: QuoteTableViewCell = tableView.dequeueReusableCellWithIdentifier(String(QuoteTableViewCell.self), forIndexPath: indexPath) as? QuoteTableViewCell else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to dequeue \(String(QuoteTableViewCell.self)) object")
            return UITableViewCell()
        }
        
        // update actionConsumableDelegate
        valid_Cell.updateActionConsumableDelegate(self)
        
        return self.configuredQuoteTableViewCell(valid_Cell, atIndexPath: indexPath)
    }
    
    private func configuredQuoteTableViewCell(cell: QuoteTableViewCell, atIndexPath indexPath: NSIndexPath) -> QuoteTableViewCell {
        guard let valid_Quote: Quote = self.listFRC.objectAtIndexPath(indexPath) as? Quote else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to fetch \(String(Quote.self)) object")
            return cell
        }
        
        cell.updateUIWithQuote(valid_Quote)
        
        return cell
    }
}

// MARK: - UITableViewDelegate protocol

extension MainViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView: QuotesTableViewHeaderFooterView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(String(QuotesTableViewHeaderFooterView.self)) as? QuotesTableViewHeaderFooterView else {
            return nil
        }
        
        return headerView
    }
}

// MARK: - UICollectionViewDataSource protocol

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let valid_FrcSections: [NSFetchedResultsSectionInfo] = self.boxesFRC.sections where valid_FrcSections.count > 0 else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid sections object on \(String(NSFetchedResultsController.self)) object")
            return 0
        }
        
        let sectionInfo: NSFetchedResultsSectionInfo = valid_FrcSections[0]
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let valid_Cell: QuoteCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(String(QuoteCollectionViewCell.self), forIndexPath: indexPath) as? QuoteCollectionViewCell else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » unable to downcast reusableCell to `\(String(QuoteCollectionViewCell.self))`")
            return UICollectionViewCell()
        }
        
        // update actionConsumableDelegate
        valid_Cell.updateActionConsumableDelegate(self)
        
        return self.configuredQuoteCollectionViewCell(valid_Cell, atIndexPath: indexPath)
    }
    
    private func configuredQuoteCollectionViewCell(cell: QuoteCollectionViewCell, atIndexPath indexPath: NSIndexPath) -> QuoteCollectionViewCell {
        guard let valid_Quote: Quote = self.boxesFRC.objectAtIndexPath(indexPath) as? Quote else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Unable to fetch \(String(Quote.self)) object")
            return cell
        }
        
        cell.updateUIWithQuote(valid_Quote)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate protocol

extension MainViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegateFlowLayout protocol

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    private var quotesCollectionViewEdgeInsets: UIEdgeInsets {
        let top: CGFloat = 0
        let left: CGFloat = 20
        let bottom: CGFloat = 12
        let right: CGFloat = 20
        return UIEdgeInsetsMake(top, left, bottom, right)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let cellSide: CGFloat = (
            CGRectGetWidth(UIScreen.mainScreen().bounds)
                - self.quotesCollectionViewEdgeInsets.left
                - self.quotesCollectionViewEdgeInsets.right
                - self.quotesCollectionViewEdgeInsets.bottom) * 0.5
        
        return CGSizeMake(cellSide, cellSide * 0.75)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return self.quotesCollectionViewEdgeInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.quotesCollectionViewEdgeInsets.bottom
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.quotesCollectionViewEdgeInsets.bottom
    }
}

// MARK: - QuoteTableViewCellActionConsumable protocol

extension MainViewController: QuoteTableViewCellActionConsumable {
    
    func quoteTableViewCellSellButtonTapped(sender: QuoteTableViewCell) {
        self.showAlertWithTitle(sender.symbolLabel.text, alertMessage: sender.bidLabel.text) { (action) in
            // completion if needed
        }
    }
    
    func quoteTableViewCellBuyButtonTapped(sender: QuoteTableViewCell) {
        self.showAlertWithTitle(sender.symbolLabel.text, alertMessage: sender.askLabel.text) { (action) in
            // completion if needed
        }
    }
}

// MARK: - QuoteTableViewCellActionConsumable protocol

extension MainViewController: QuoteCollectionViewCellActionConsumable {
    
    func quoteCollectionViewCellSellButtonTapped(sender: QuoteCollectionViewCell) {
        self.showAlertWithTitle(sender.symbolLabel.text, alertMessage: sender.bidLabel.text) { (action) in
            // completion if needed
        }
    }
    
    func quoteCollectionViewCellBuyButtonTapped(sender: QuoteCollectionViewCell) {
        self.showAlertWithTitle(sender.symbolLabel.text, alertMessage: sender.askLabel.text) { (action) in
            // completion if needed
        }
    }
}

// MARK: - QuotesSelectionConsumable protocol

extension MainViewController: QuotesSelectionConsumable {
    
    func quoteSelectionUpdated(newSelection: [QuoteSymbol]) {
        guard let valid_ViewModel: MainViewModel = self.viewModel else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid \(String(MainViewModel.self)) object")
            return
        }
        
        valid_ViewModel.updateQuoteSymbols(QuoteSymbol.initialQuoteSymbols() + newSelection)
    }
}
