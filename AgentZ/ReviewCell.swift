//
//  ReviewCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/30/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {

    var titleLabel: UILabel!
    var commentLabel: UILabel!
    
    var flagLabel: UILabel!
    
    override init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "ReviewCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        titleLabel = UILabel(frame: CGRectZero)
        commentLabel = UILabel(frame: CGRectZero)

        titleLabel.font = UIFont.systemFontOfSize(17)
        commentLabel.font = UIFont.systemFontOfSize(13)
        commentLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(commentLabel)
        
        self.selectionStyle = UITableViewCellSelectionStyle.Default
        
        flagLabel = UILabel(frame: CGRectZero)
        flagLabel.font = UIFont.systemFontOfSize(15)
        contentView.addSubview(flagLabel)
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
