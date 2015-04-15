//
//  ProfileCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/28/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    var keyLabel: UILabel!
    var valueLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "ProfileCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        keyLabel = UILabel(frame: CGRectZero)
        valueLabel = UILabel(frame: CGRectZero)
        
        keyLabel.font = UIFont.systemFontOfSize(13)
        valueLabel.font = UIFont.systemFontOfSize(17)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected
        
        contentView.addSubview(keyLabel)
        contentView.addSubview(valueLabel)
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
