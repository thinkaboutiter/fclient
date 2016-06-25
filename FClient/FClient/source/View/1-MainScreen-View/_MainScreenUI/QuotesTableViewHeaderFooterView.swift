//
//  QuotesTableViewHeaderFooterView.swift
//  FClient
//
//  Created by Boyan Yankov on W25 25/06/2016 Sat.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SnapKit

class QuotesTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    // MARK: Properties
    
    private lazy var symbolHolderView: UIView = {
        let lazy_HolderView: UIView = UIView()
        lazy_HolderView.translatesAutoresizingMaskIntoConstraints = false
        lazy_HolderView.backgroundColor = UIColor.quoteSectionHeaderViewBackgroundColor()
        return lazy_HolderView
    }()
    
    private lazy var symbolLabel: UILabel = {
        let lazy_Label: UILabel = UILabel()
        lazy_Label.translatesAutoresizingMaskIntoConstraints = false
        lazy_Label.textColor = UIColor.whiteColor()
        lazy_Label.textAlignment = .Left
        lazy_Label.font = UIFont.systemFontOfSize(14)
        lazy_Label.backgroundColor = UIColor.clearColor()
        
        lazy_Label.text = "Symbol"
        
        return lazy_Label
    }()
    
    private lazy var bidHolderView: UIView = {
        let lazy_HolderView: UIView = UIView()
        lazy_HolderView.translatesAutoresizingMaskIntoConstraints = false
        lazy_HolderView.backgroundColor = UIColor.quoteSectionHeaderViewBackgroundColor()
        return lazy_HolderView

    }()
    
    private lazy var bidLabel: UILabel = {
        let lazy_Label: UILabel = UILabel()
        lazy_Label.translatesAutoresizingMaskIntoConstraints = false
        lazy_Label.textColor = UIColor.whiteColor()
        lazy_Label.textAlignment = .Left
        lazy_Label.font = UIFont.systemFontOfSize(14)
        lazy_Label.backgroundColor = UIColor.clearColor()
        
        lazy_Label.text = "Bid"
        
        return lazy_Label
    }()
    
    private lazy var askHolderView: UIView = {
        let lazy_HolderView: UIView = UIView()
        lazy_HolderView.translatesAutoresizingMaskIntoConstraints = false
        lazy_HolderView.backgroundColor = UIColor.quoteSectionHeaderViewBackgroundColor()
        return lazy_HolderView
    }()
    
    private lazy var askLabel: UILabel = {
        let lazy_Label: UILabel = UILabel()
        lazy_Label.translatesAutoresizingMaskIntoConstraints = false
        lazy_Label.textColor = UIColor.whiteColor()
        lazy_Label.textAlignment = .Left
        lazy_Label.font = UIFont.systemFontOfSize(14)
        lazy_Label.backgroundColor = UIColor.clearColor()
        
        lazy_Label.text = "Ask"
        
        return lazy_Label
    }()
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    private func commonInit() {
        self.contentView.addSubview(self.symbolHolderView)
        self.contentView.addSubview(self.bidHolderView)
        self.contentView.addSubview(self.askHolderView)
        
        self.symbolHolderView.addSubview(self.symbolLabel)
        self.bidHolderView.addSubview(self.bidLabel)
        self.askHolderView.addSubview(self.askLabel)
    }
    
    // MARK: - Life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.symbolHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.whiteColor())
        self.bidHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.whiteColor())
        self.askHolderView.configureAsQuoteHolderViewWithBorderColor(UIColor.whiteColor())
    }
    
    override func updateConstraints() {
        
        // position symbolHolderView
        self.symbolHolderView.snp_updateConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top)
            make.leading.equalTo(self.contentView.snp_leading)
            make.bottom.equalTo(self.contentView.snp_bottom)
            make.width.equalTo(self.contentView.snp_width).multipliedBy(0.2)
        }
        
        self.symbolLabel.snp_updateConstraints { (make) in
            make.centerY.equalTo(self.symbolHolderView.snp_centerY)
            make.leading.equalTo(self.symbolHolderView.snp_leading).offset(8)
            make.trailing.equalTo(self.symbolHolderView.snp_trailing).offset(-8)
        }
        
        // position bidHolderView
        self.bidHolderView.snp_updateConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top)
            make.leading.equalTo(self.symbolHolderView.snp_trailing)
            make.bottom.equalTo(self.contentView.snp_bottom)
            make.width.equalTo(self.contentView.snp_width).multipliedBy(0.4)
        }
        
        self.bidLabel.snp_updateConstraints { (make) in
            make.centerY.equalTo(self.bidHolderView.snp_centerY)
            make.leading.equalTo(self.bidHolderView.snp_leading).offset(8)
            make.trailing.equalTo(self.bidHolderView.snp_trailing).offset(-8)
        }
        
        // position askHolderView
        self.askHolderView.snp_updateConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top)
            make.trailing.equalTo(self.contentView.snp_trailing)
            make.bottom.equalTo(self.contentView.snp_bottom)
            make.width.equalTo(self.contentView.snp_width).multipliedBy(0.4)
        }
        
        self.askLabel.snp_updateConstraints { (make) in
            make.centerY.equalTo(self.askHolderView.snp_centerY)
            make.leading.equalTo(self.askHolderView.snp_leading).offset(8)
            make.trailing.equalTo(self.askHolderView.snp_trailing).offset(-8)
        }
        
        super.updateConstraints()
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
