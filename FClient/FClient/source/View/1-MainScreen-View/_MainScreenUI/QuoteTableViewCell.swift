//
//  QuoteTableViewCell.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SimpleLogger

protocol QuoteTableViewCellActionConsumable: class {
    func quoteTableViewCellBuyButtonTapped(sender: QuoteTableViewCell)
    func quoteTableViewCellSellButtonTapped(sender: QuoteTableViewCell)
}

class QuoteTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var symbolHolderView: UIView!
    @IBOutlet weak var symbolLabel: UILabel!
    
    // bidView
    @IBOutlet weak var bidHolderView: UIView!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var bidOrientationImageView: UIImageView!
    @IBOutlet weak var sellButton: UIButton!
    
    // askView
    @IBOutlet weak var askHolderView: UIView!
    @IBOutlet weak var askLabel: UILabel!
    @IBOutlet weak var askOrientationImageView: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    
    private(set) weak var actionConsumableDelegate: QuoteTableViewCellActionConsumable?
    
    // MARK: Cascaded Accessors
    
    func updateActionConsumableDelegate(newDelegate: QuoteTableViewCellActionConsumable) {
        self.actionConsumableDelegate = newDelegate
    }

    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .None
        
        // configure holderViews
        self.symbolHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.quoteHolderViewBorderColor())
        self.bidHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.quoteHolderViewBorderColor())
        self.askHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.quoteHolderViewBorderColor())
        
        // configure buttons
        self.sellButton.configureAsQuoteActionButtonWithTitle("Sell")
        self.buyButton.configureAsQuoteActionButtonWithTitle("Buy")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUIWithQuote(quote: Quote)  {
        self.symbolLabel.text = quote.displayName
        
        guard let valid_ChangeOrientationNumber: NSNumber = quote.changeOrientation,
            let valid_ChangeOrientation: ChangeOrientation = ChangeOrientation(rawValue: valid_ChangeOrientationNumber.integerValue)
        else {
            Logger.logError().logMessage("\(self) \(#line) \(#function) » Invalid changeOrientation value found on \(String(Quote.self)) object")
            
            // update labels with no custom formatting
            self.bidLabel.text = quote.bid
            self.askLabel.text = quote.ask
            
            return
        }
        
        self.bidLabel.configureAsQuoteLabelWithText(quote.bid, andChangeOrientation: valid_ChangeOrientation)
        self.askLabel.configureAsQuoteLabelWithText(quote.ask, andChangeOrientation: valid_ChangeOrientation)
        
        // TODO: configure bidOrientationImageView
        // TODO: configure askOrientationImageView
    }
    
    // MARK: Actions
    
    @IBAction func sellButtonTapped(sender: UIButton) {
        self.actionConsumableDelegate?.quoteTableViewCellSellButtonTapped(self)
    }
    
    @IBAction func buyButtonTapped(sender: UIButton) {        
        self.actionConsumableDelegate?.quoteTableViewCellBuyButtonTapped(self)
    }
}
