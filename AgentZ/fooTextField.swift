//
//  fooTextField.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 4/3/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import Foundation

class fooTextField: UITextField {
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10.0, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.textRectForBounds(bounds)
    }
    
}