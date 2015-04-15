//
//  NewRadioCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/29/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

// protocol used to inform its delegate of state change
protocol NewRadioCellDelegate {
    func radioTapped(indexPathTag: Int)
}

class NewRadioCell: UITableViewCell {

    var keyLabel: UILabel!
    var radioLabel: UILabel!
    
    var delegate: NewRadioCellDelegate? // the object that acts as delegate for this cell
    var indexPathTag: Int? // the tag of indexPath of tapped row
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "NewRadioCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        keyLabel = UILabel(frame: CGRectZero)
        keyLabel.font = UIFont.systemFontOfSize(15)
        
        radioLabel = UILabel(frame: CGRectZero)
        radioLabel.text = "\u{25CE}"
        
        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected
        
        contentView.addSubview(keyLabel)
        contentView.addSubview(radioLabel)
        
        var radioTapped = UITapGestureRecognizer(target: self, action: "radioTappedHandler:")
        addGestureRecognizer(radioTapped)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = newTableViewWidth - 10
        radioLabel.frame = CGRectMake(5, 0, 20, newTableCellHeight)
        keyLabel.frame = CGRectMake(25, 0, width - 20, newTableCellHeight)
    }
    
    func radioTappedHandler(sender: UITapGestureRecognizer) {
        if delegate != nil && indexPathTag != nil {delegate!.radioTapped(indexPathTag!)} // notify the delegate that this item has been tapped
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
