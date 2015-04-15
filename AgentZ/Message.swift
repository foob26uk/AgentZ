//
//  Message.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 2/6/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import Foundation

class Message {
    
    var author: PFUser
    var authorName: String
    var text: String
    var createdAt: NSDate
    
    init(author: PFUser, authorName: String, text: String, createdAt: NSDate) {
        self.author = author
        self.authorName = authorName
        self.text = text
        self.createdAt = createdAt
    }
}