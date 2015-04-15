//
//  NewStandardCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/28/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class NewStandardCell: UITableViewCell {

    var keyLabel: UILabel!
    var valueTextField: UITextField!
   
    override init() {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "NewStandardCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        keyLabel = UILabel(frame: CGRectZero)
        valueTextField = UITextField(frame: CGRectZero)
        self.selectionStyle = UITableViewCellSelectionStyle.None

        keyLabel.font = UIFont.systemFontOfSize(13)
        valueTextField.clearButtonMode = UITextFieldViewMode.WhileEditing

        valueTextField.autocorrectionType = UITextAutocorrectionType.No
        valueTextField.spellCheckingType = UITextSpellCheckingType.No        

        contentView.addSubview(keyLabel)
        contentView.addSubview(valueTextField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let width = newTableViewWidth - 10
        keyLabel.frame = CGRectMake(5, 14, width, 16)
        valueTextField.frame = CGRectMake(5, keyLabel.frame.maxY, width, newTableCellHeight)
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
