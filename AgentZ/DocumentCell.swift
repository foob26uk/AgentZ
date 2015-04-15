//
//  DocumentCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 2/9/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {

    var nameLabel: UILabel!
    var descriptionLabel: UILabel!
    var thumbnail: UIImageView!
    
    override init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "DocumentCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.font = UIFont.boldSystemFontOfSize(15)
        
        descriptionLabel = UILabel(frame: CGRectZero)
        descriptionLabel.font = UIFont.systemFontOfSize(15)
        descriptionLabel.numberOfLines = 2
        
        
        thumbnail = UIImageView(frame: CGRectZero)
        //thumbnail.layer.borderWidth = 1
        
        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected

        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(thumbnail)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let width = tableViewWidth - 70
        nameLabel.frame = CGRectMake(70, 0, width, 20)
        descriptionLabel.frame = CGRectMake(70, 20, width, 40)
        thumbnail.frame = CGRectMake(0, 0, 60, 60)
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
