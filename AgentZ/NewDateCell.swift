//
//  NewDateCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/29/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

protocol NewDateCellDelegate {
    func dateTapped(indexPathTag: Int)
}

class NewDateCell: UITableViewCell {

    var keyLabel: UILabel!
    var valueLabel: UILabel!
    
    var delegate: NewDateCellDelegate? // the object that acts as delegate for this cell
    var indexPathTag: Int? // the tag of indexPath of tapped row
    
    override init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "NewDateCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        keyLabel = UILabel(frame: CGRectZero)
        valueLabel = UILabel(frame: CGRectZero)
        
        keyLabel.font = UIFont.systemFontOfSize(15)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected
        
        contentView.addSubview(keyLabel)
        contentView.addSubview(valueLabel)
        
        var dateTapped = UITapGestureRecognizer(target: self, action: "dateTappedHandler:")
        addGestureRecognizer(dateTapped)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = newTableViewWidth - 10
        let dateWidth = CGFloat(85)
        
        valueLabel.frame = CGRectMake(5, 0, dateWidth, newTableCellHeight)
        keyLabel.frame = CGRectMake(5 + dateWidth + 10, 0, width - dateWidth, newTableCellHeight)
    }
    
    func dateTappedHandler(sender: UITapGestureRecognizer) {
        if delegate != nil && indexPathTag != nil {delegate!.dateTapped(indexPathTag!)} // notify the delegate that this item has been tapped
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
