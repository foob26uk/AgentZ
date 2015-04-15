//
//  LogEntry.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 2/6/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import Foundation

class LogEntry {

    var author: PFUser
    var authorName: String
    var createdAt: NSDate
    
    var sectionName: String
    var propertyName: String
    var oldValue: String
    var newValue: String
    var propertyType: String

    init(author: PFUser, authorName: String, createdAt: NSDate, sectionName: String, propertyName: String, oldValue: String, newValue: String, propertyType: String) {
        self.author = author
        self.authorName = authorName
        self.createdAt = createdAt
        self.sectionName = sectionName
        self.propertyName = propertyName
        self.oldValue = oldValue
        self.newValue = newValue
        self.propertyType = propertyType
    }
}