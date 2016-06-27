//
//  QuoteCollectionViewCell.swift
//  FClient
//
//  Created by Boyan Yankov on W25 26/06/2016 Sun.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SimpleLogger

protocol QuoteCollectionViewCellActionConsumable: class {
    func quoteCollectionViewCellBuyButtonTapped(sender: QuoteCollectionViewCell)
    func quoteCollectionViewCellSellButtonTapped(sender: QuoteCollectionViewCell)
}

class QuoteCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    // symbolHolderView
    @IBOutlet weak var symbolHolderView: UIView!
    @IBOutlet weak var symbolLabel: UILabel!
    
    // bidHolderView
    @IBOutlet weak var bidHolderView: UIView!
    @IBOutlet weak var bidTitleLabel: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var sellButton: UIButton!
    
    // askHolderView
    @IBOutlet weak var askHolderView: UIView!
    @IBOutlet weak var askTitleLabel: UILabel!
    @IBOutlet weak var askLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    private(set) weak var actionConsumableDelegate: QuoteCollectionViewCellActionConsumable?
    
    // MARK: Cascaded Accessors
    
    func updateActionConsumableDelegate(newDelegate: QuoteCollectionViewCellActionConsumable) {
        self.actionConsumableDelegate = newDelegate
    }
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.symbolHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.quoteHolderViewBorderColor())
        self.symbolHolderView.backgroundColor = UIColor.quoteHolderViewBorderColor()
        self.bidHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.quoteHolderViewBorderColor())
        self.askHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.quoteHolderViewBorderColor())
        
        // configure buttons
        self.sellButton.configureAsBoxQuoteActionButtonWithTitle("Sell")
        self.buyButton.configureAsBoxQuoteActionButtonWithTitle("Buy")
    }
    
    func updateUIWithQuote(quote: Quote)  {
        self.symbolLabel.configureAsBoxQuoteSymbolLabelWithText(quote.displayName)
        
        guard let valid_ChangeOrientationNumber: NSNumber = quote.changeOrientation,
            let valid_ChangeOrientation: ChangeOrientation = ChangeOrientation(rawValue: valid_ChangeOrientationNumber.integerValue)
        else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid changeOrientation value found on \(String(Quote.self)) object")
            
            // update labels with no custom formatting
            self.bidLabel.text = quote.bid
            self.askLabel.text = quote.ask
            
            return
        }
        
        self.bidLabel.configureAsBoxQuoteLabelWithText(quote.bid, andChangeOrientation: valid_ChangeOrientation)
        self.askLabel.configureAsBoxQuoteLabelWithText(quote.ask, andChangeOrientation: valid_ChangeOrientation)
        
        // TODO: configure bidOrientationImageView
        // TODO: configure askOrientationImageView
    }
    
    // MARK: Actions
    
    @IBAction func sellButtonTapped(sender: UIButton) {
        self.actionConsumableDelegate?.quoteCollectionViewCellSellButtonTapped(self)
    }
    
    @IBAction func buyButtonTapped(sender: UIButton) {
        self.actionConsumableDelegate?.quoteCollectionViewCellBuyButtonTapped(self)
    }
}
