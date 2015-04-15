//
//  Document.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 2/9/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import Foundation

class Document {
    
    var name: String
    var description: String
    var thumbnail: UIImage?
    var fileData: NSData?
    
    init (name: String, description: String) {
        self.name = name
        self.description = description
    }
}