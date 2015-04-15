//
//  AgentCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/31/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class AgentCell: UITableViewCell {

    var nameLabel: UILabel!
    var titleLabel: UILabel!
    var emailLabel: UILabel!
    var phoneLabel: UILabel!
    
    override init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "AgentCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.font = UIFont.boldSystemFontOfSize(15)

        titleLabel = UILabel(frame: CGRectZero)
        titleLabel.font = UIFont.systemFontOfSize(15)
        
        emailLabel = UILabel(frame: CGRectZero)
        emailLabel.font = UIFont.systemFontOfSize(15)

        phoneLabel = UILabel(frame: CGRectZero)
        phoneLabel.font = UIFont.systemFontOfSize(15)
        
        titleLabel.textAlignment = NSTextAlignment.Right
        
        self.selectionStyle = UITableViewCellSelectionStyle.Default
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(phoneLabel)
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
