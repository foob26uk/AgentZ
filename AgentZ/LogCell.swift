//
//  LogCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 2/1/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {
    
    var authorLabel: UILabel!
    var createdAtLabel: UILabel!
    
    var addressLabel: UILabel!
    var dataLabel: UILabel!
    
    var cellView: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "LogCell")
        
        self.backgroundColor = UIColor(red: 210/255, green: 203/255, blue: 177/255, alpha: 1.0)
        
        authorLabel = UILabel(frame: CGRectZero)
        createdAtLabel = UILabel(frame: CGRectZero)
        addressLabel = UILabel(frame: CGRectZero)
        dataLabel = UILabel(frame: CGRectZero)
        
        authorLabel.font = UIFont.boldSystemFontOfSize(13)
        createdAtLabel.font = UIFont.systemFontOfSize(13)
        addressLabel.font = UIFont.systemFontOfSize(15)
        dataLabel.font = UIFont.systemFontOfSize(15)

        dataLabel.numberOfLines = 0

        createdAtLabel.textAlignment = NSTextAlignment.Right
        
        cellView = UIView(frame: CGRectZero)
        
        cellView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        cellView.layer.borderColor = UIColor(white: 0.2, alpha: 0.5).CGColor
        cellView.layer.borderWidth = 0.7
        cellView.layer.cornerRadius = 2
        
        cellView.addSubview(authorLabel)
        cellView.addSubview(createdAtLabel)
        cellView.addSubview(addressLabel)
        cellView.addSubview(dataLabel)
        
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
