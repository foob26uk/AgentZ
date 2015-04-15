//
//  NewPickerCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 2/5/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

protocol NewPickerCellDelegate {
    func pickerTapped(indexPathTag: Int)
}

class NewPickerCell: UITableViewCell {
    
    var keyLabel: UILabel!
    var valueLabel: UILabel!
    
    var delegate: NewPickerCellDelegate?
    var indexPathTag: Int?
    
    override init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "NewPickerCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        keyLabel = UILabel(frame: CGRectZero)
        keyLabel.font = UIFont.systemFontOfSize(15)
        valueLabel = UILabel(frame: CGRectZero)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected
        
        contentView.addSubview(keyLabel)
        contentView.addSubview(valueLabel)
        
        var pickerTapped = UITapGestureRecognizer(target: self, action: "pickerTappedHandler:")
        addGestureRecognizer(pickerTapped)
    }
    
    func pickerTappedHandler(sender: UITapGestureRecognizer) {
        if delegate != nil && indexPathTag != nil {delegate!.pickerTapped(indexPathTag!)}
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
