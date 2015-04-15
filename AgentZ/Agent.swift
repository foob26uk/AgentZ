//
//  Agent.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/25/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import Foundation

class Agent {

    var name: String = ""
    var title: String = ""
    var profileImage: NSData? = nil
    
    var properties: [[String]] =
    [
        ["address", "", "ADDRESS"], // stored as street|city|state|zip
        ["phone", "", "PHONE"], // stored as 10 digit numeric string
        ["email", "", "EMAIL"],
        ["username", "", "USERNAME"],
        ["password", "*******", "PASSWORD"],
    ]

    class func getFormattedPhone(phone: String) -> String {
        if count(phone) != 10 {
            return ""
        }
        
        var phoneNumberArray = Array(phone)
        phoneNumberArray.insert("-", atIndex: 6)
        phoneNumberArray.insert(" ", atIndex: 3)
        phoneNumberArray.insert(")", atIndex: 3)
        phoneNumberArray.insert("(", atIndex: 0)
        
        return String(phoneNumberArray)
    }
    
    class func getFormattedAddress(address: String) -> String {
        var addressArray = address.componentsSeparatedByString("|")

        if count(addressArray) == 4 {
            addressArray.insert(" ", atIndex: 3)
            addressArray.insert(", ", atIndex: 2)
            addressArray.insert("\n", atIndex: 1)
            return join("", addressArray)
        }

        return ""
    }
    
    class func getStreet(address: String) -> String {
        let addressArray = address.componentsSeparatedByString("|")
        if count(addressArray) == 4 {
            return addressArray[0]
        }
        return ""
    }

    class func getCity(address: String) -> String {
        let addressArray = address.componentsSeparatedByString("|")
        if count(addressArray) == 4 {
            return addressArray[1]
        }
        return ""
    }
    
    class func getState(address: String) -> String {
        let addressArray = address.componentsSeparatedByString("|")
        if count(addressArray) == 4 {
            return addressArray[2]
        }
        return ""
    }
    
    class func getZip(address: String) -> String {
        let addressArray = address.componentsSeparatedByString("|")
        if count(addressArray) == 4 {
            return addressArray[3]
        }
        return ""
    }
}