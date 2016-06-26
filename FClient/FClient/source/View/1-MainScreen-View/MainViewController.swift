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
    
    private var listFRC: NSFetchedResultsController {
        return Quote.MR_fetchAllSortedBy(Quote.displayName_AttributeName, ascending: true, withPredicate: self.symbolsCompoundPredicate, groupBy: nil, delegate: self)
    }
    
    private var boxexFRC: NSFetchedResultsController {
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
        
        self.addRefreshButton()
        self.addPlusButton()
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
        
        self.quotesTableView.reloadData()
    }
}

// MARK: - NSFetchedResultsControllerDelegate protocol

extension MainViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.quotesTableView.beginUpdates()
    }
    
    func controller(
        controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        switch type {
        case .Insert:
            self.quotesTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            self.quotesTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        default:
            break
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
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.quotesTableView.endUpdates()
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
        guard let valid_FrcSections: [NSFetchedResultsSectionInfo] = self.boxexFRC.sections where valid_FrcSections.count > 0 else {
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
        
        valid_Cell.contentView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2)
        
        return valid_Cell
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
