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
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    // bidView
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var bidOrientationImageView: UIImageView!
    @IBOutlet weak var sellButton: UIButton!
    
    // askView
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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUIWithQuote(quote: Quote)  {
        self.symbolLabel.text = quote.displayName
        self.bidLabel.text = quote.bid
        
        // TODO: configure bidOrientationImageView
        
        self.askLabel.text = quote.ask
        
        // TODO: configure askOrientationImageView
        
        // TODO: configure colors using `changeOrientation` on passed quote parameter
    }
    
    // MARK: Actions
    
    @IBAction func sellButtonTapped(sender: UIButton) {
        Logger.logDebug().logMessage("\(self) \(#line) \(#function) » ")
        
        self.actionConsumableDelegate?.quoteTableViewCellSellButtonTapped(self)
    }
    
    @IBAction func buyButtonTapped(sender: UIButton) {
        Logger.logDebug().logMessage("\(self) \(#line) \(#function) » ")
        
        self.actionConsumableDelegate?.quoteTableViewCellBuyButtonTapped(self)
    }
}
