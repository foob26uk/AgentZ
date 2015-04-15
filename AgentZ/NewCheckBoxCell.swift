//
//  NewCheckBoxCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/29/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

// protocol used to inform its delegate of state change
protocol NewCheckBoxCellDelegate {
    func boxTapped(indexPathTag: Int)
}

class NewCheckBoxCell: UITableViewCell {

    var keyLabel: UILabel!
    var checkBoxLabel: UILabel!
    
    var delegate: NewCheckBoxCellDelegate? // the object that acts as delegate for this cell
    var indexPathTag: Int? // the tag of indexPath of tapped row
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "NewCheckBoxCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        keyLabel = UILabel(frame: CGRectZero)
        keyLabel.font = UIFont.systemFontOfSize(15)

        checkBoxLabel = UILabel(frame: CGRectZero)
        //checkBoxLabel.layer.borderColor = UIColor.blackColor().CGColor
        //checkBoxLabel.layer.borderWidth = 2.0
        checkBoxLabel.text = "\u{2610}"

        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected
        
        contentView.addSubview(keyLabel)
        contentView.addSubview(checkBoxLabel)
        
        var boxChecked = UITapGestureRecognizer(target: self, action: "boxTappedHandler:")
        addGestureRecognizer(boxChecked)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = newTableViewWidth - 10
        checkBoxLabel.frame = CGRectMake(5, 9, 15, 15)
        keyLabel.frame = CGRectMake(25, 0, width - 20, newTableCellHeight)
    }
    
    func boxTappedHandler(sender: UITapGestureRecognizer) {
        if delegate != nil && indexPathTag != nil {delegate!.boxTapped(indexPathTag!)} // notify the delegate that this item has been tapped
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
