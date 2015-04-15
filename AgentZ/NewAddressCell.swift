//
//  NewAddressCell.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/28/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class NewAddressCell: UITableViewCell {

    var keyLabel: UILabel!
    var streetTextField: UITextField!
    var cityTextField: UITextField!
    var stateTextField: UITextField!
    var zipTextField: UITextField!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "NewAddressCell")
        
        self.backgroundColor = UIColor.clearColor()
        
        keyLabel = UILabel(frame: CGRectZero)
        keyLabel.font = UIFont.systemFontOfSize(13)
        
        streetTextField = UITextField(frame: CGRectZero)
        cityTextField = UITextField(frame: CGRectZero)
        stateTextField = UITextField(frame: CGRectZero)
        zipTextField = UITextField(frame: CGRectZero)
        
        streetTextField.placeholder = "street"
        cityTextField.placeholder = "city"
        stateTextField.placeholder = "state"
        zipTextField.placeholder = "zip"
        
        streetTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        cityTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        stateTextField.clearsOnBeginEditing = true
        zipTextField.clearsOnBeginEditing = true
        
        streetTextField.autocapitalizationType = UITextAutocapitalizationType.Words
        streetTextField.autocorrectionType = UITextAutocorrectionType.No
        streetTextField.spellCheckingType = UITextSpellCheckingType.No

        cityTextField.autocapitalizationType = UITextAutocapitalizationType.Words
        cityTextField.autocorrectionType = UITextAutocorrectionType.No
        cityTextField.spellCheckingType = UITextSpellCheckingType.No
        
        stateTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        stateTextField.autocorrectionType = UITextAutocorrectionType.No
        stateTextField.spellCheckingType = UITextSpellCheckingType.No

        zipTextField.autocapitalizationType = UITextAutocapitalizationType.None
        zipTextField.autocorrectionType = UITextAutocorrectionType.No
        zipTextField.spellCheckingType = UITextSpellCheckingType.No
        
        self.selectionStyle = UITableViewCellSelectionStyle.None // doesn't highlight when selected

        contentView.addSubview(keyLabel)
        contentView.addSubview(streetTextField)
        contentView.addSubview(cityTextField)
        contentView.addSubview(stateTextField)
        contentView.addSubview(zipTextField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = newTableViewWidth - 10
        keyLabel.frame = CGRectMake(5, 14, width, 16)
        streetTextField.frame = CGRectMake(5, keyLabel.frame.maxY, width, newTableCellHeight)
        cityTextField.frame = CGRectMake(5, streetTextField.frame.maxY, width - 52 - 62, newTableCellHeight)
        stateTextField.frame = CGRectMake(5 + width - 52 - 62, streetTextField.frame.maxY, 52, newTableCellHeight)
        zipTextField.frame = CGRectMake(5 + width - 62, streetTextField.frame.maxY, 62, newTableCellHeight)
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
