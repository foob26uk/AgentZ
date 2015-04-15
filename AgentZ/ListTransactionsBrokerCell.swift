//
//  ListTransactionsBrokerCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/25/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class ListTransactionsBrokerCell: UITableViewCell {

    var addressLabel: UILabel!
    var dateLabel: UILabel!
    var statusLabel: UILabel!
    
    var agentLabel: UILabel!
    var reprLabel: UILabel!
    
    var cellView: UIView!

    var brokerFollowupLabel: UILabel!
    var agentFollowupLabel: UILabel!
    
    override init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "ListTransactionsBrokerCell")
        
        self.backgroundColor = UIColor(red: 226/255, green: 232/255, blue: 202/255, alpha: 1.0)
        
        addressLabel = UILabel(frame: CGRectZero)
        dateLabel = UILabel(frame: CGRectZero)
        statusLabel = UILabel(frame: CGRectZero)
        agentLabel = UILabel(frame: CGRectZero)
        reprLabel = UILabel(frame: CGRectZero)
        
        addressLabel.numberOfLines = 2
        
        addressLabel.font = UIFont.systemFontOfSize(15)
        dateLabel.font = UIFont.systemFontOfSize(13)
        statusLabel.font = UIFont.boldSystemFontOfSize(15)
        agentLabel.font = UIFont.boldSystemFontOfSize(15)
        reprLabel.font = UIFont.systemFontOfSize(13)
        
        dateLabel.textAlignment = NSTextAlignment.Right
        statusLabel.textAlignment = NSTextAlignment.Right
        
        cellView = UIView(frame: CGRectZero)
        
        cellView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        cellView.layer.borderColor = UIColor(white: 0.2, alpha: 0.5).CGColor
        cellView.layer.borderWidth = 0.7
        cellView.layer.cornerRadius = 2
        
        cellView.addSubview(addressLabel)
        cellView.addSubview(dateLabel)
        cellView.addSubview(statusLabel)
        cellView.addSubview(agentLabel)
        cellView.addSubview(reprLabel)
        
        contentView.addSubview(cellView)
                
        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected

        brokerFollowupLabel = UILabel(frame: CGRectZero)
        brokerFollowupLabel.font = UIFont.systemFontOfSize(15)
        brokerFollowupLabel.backgroundColor = UIColor.cyanColor()
        cellView.addSubview(brokerFollowupLabel)
        
        agentFollowupLabel = UILabel(frame: CGRectZero)
        agentFollowupLabel.font = UIFont.systemFontOfSize(15)
        agentFollowupLabel.backgroundColor = UIColor.yellowColor()
        cellView.addSubview(agentFollowupLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let labelHeight = CGFloat(20)
        
        addressLabel.frame = CGRectMake(10, 10, tableViewWidth / 2 - 10, labelHeight * 2)
        dateLabel.frame = CGRectMake(tableViewWidth / 2, 10, tableViewWidth / 2 - 10, labelHeight)
        //statusLabel.frame = CGRectMake(tableViewWidth / 2, dateLabel.frame.maxY, tableViewWidth / 2 - 10, labelHeight)
        
        agentLabel.frame = CGRectMake(10, addressLabel.frame.maxY, tableViewWidth - 20, 20)
        reprLabel.frame = CGRectMake(10, agentLabel.frame.maxY, tableViewWidth - 20, 20)

        cellView.frame = CGRectMake(0, 0, tableViewWidth, reprLabel.frame.maxY + 10)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
