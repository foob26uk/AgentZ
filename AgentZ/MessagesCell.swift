//
//  MessagesCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 2/2/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class MessagesCell: UITableViewCell {
    
    var keyLabel: UILabel!
    var valueLabel: UILabel!
    var dateLabel: UILabel!
    
    var cellView: UIView!
    
    override init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "MessagesCell")
        
        self.backgroundColor = UIColor(red: 210/255, green: 203/255, blue: 177/255, alpha: 1.0)
        
        keyLabel = UILabel(frame: CGRectZero)
        valueLabel = UILabel(frame: CGRectZero)
        dateLabel = UILabel(frame: CGRectZero)
        
        keyLabel.font = UIFont.boldSystemFontOfSize(13)
        dateLabel.font = UIFont.systemFontOfSize(13)
        dateLabel.textAlignment = NSTextAlignment.Right
        valueLabel.font = UIFont.systemFontOfSize(15)
        valueLabel.numberOfLines = 0
        
        cellView = UIView(frame: CGRectZero)
        
        cellView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        cellView.layer.borderColor = UIColor(white: 0.2, alpha: 0.5).CGColor
        cellView.layer.borderWidth = 0.7
        cellView.layer.cornerRadius = 5
        
        cellView.addSubview(keyLabel)
        cellView.addSubview(valueLabel)
        cellView.addSubview(dateLabel)
        
        contentView.addSubview(cellView)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected
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
