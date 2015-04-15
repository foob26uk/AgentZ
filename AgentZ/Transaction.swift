//
//  Transaction.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/25/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import Foundation

class Transaction {
    
    // TODO: log and message should be objects
    
    /* TODO:
    broker should be able to add fields in transaction template (e.g. additional date)
    agent should be able to add/edit fields in transaction, before initial submission to broker
    these optional fields are deletable but any such activity is logged
    */
    
    // TODO: if seller agent and buyer agent both under same broker, duplicate transaction created?
    
    // non-displayed properties
    var transactionCount: Int = -1
    var transactionID: String = "" // the object's objectID in Parse (can tell if transaction saved online or not)
    var agent: PFUser = PFUser.currentUser() // the agent in Parse
    var agentName: String = ""
    var creationDate: NSDate = NSDate() // the object's createdAt in Parse
    
    var brokerFollowupRequired: Bool = false
    var agentFollowupRequired: Bool = false
    var status: String = "new"
    /*
    new: agent created, not yet submitted to broker for initial review
    active: transaction is in normal process, under contract
    inactive: transaction is older than certain date, and should be either closed, failed, or voided
    closed: transaction closed
    failed: transaction did not close, ended by another party i.e not broker or agent
    voided: transaction did not close, ended by broker or agent
    */
        
    // should use JSON? then can use libraries to read from template files
    // should store this template on parse server and get it from there
    var properties: [[[String]]] =
    [
        [
            ["Agent Information"], // first element is always title of section in table view
            ["commission", ""],
            ["representation", "no", "RADIO", "broker/agent represents buyer only"],
            ["representation", "no", "RADIO", "broker/agent represents seller only"],
            ["representation", "no", "RADIO", "dual agency: agent represents buyer"],
            ["representation", "no", "RADIO", "dual agency: agent represents seller"],
            ["representation", "no", "RADIO", "dual agency: agent represents both"],
            ["representation", "no", "RADIO", "broker/agent represents neither party"]
        ],
        [
            ["Property Information"],
            ["address", "|||", "ADDRESS"],

            ["built prior to 1978?", "no", "CHECKBOX"],
            ["if so, buyer received lead-based paint disclosure?", "no", "CHECKBOX"],
            ["and, buyer received lead-based paint info pamphelet?", "no", "CHECKBOX"],
            
            ["MLS id", ""],
            ["sale price", ""],
            ["down payment", ""],

            ["sale type", "", "PICKER", "seller", "short sale", "bank owned", "3rd party approval"],
            ["property type", "", "PICKER", "residental", "new construction", "commercial", "land", "referral"]
        ],
        [
            ["Seller Information"],
            ["name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""],
            ["seller represents themself", "no", "CHECKBOX"]
        ],
        [
            ["Buyer Information"],
            ["name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""],
            ["buyer represents themself", "no", "CHECKBOX"]
        ],
        [
            ["Contract Dates"],
            ["offer date", "", "DATE"],
            ["acceptance date", "", "DATE"],
            ["seller disclosure deadline", "", "DATE"],
            ["eval/inspection deadline", "", "DATE"],
            ["appraisal/financing deadline", "", "DATE"],
            ["settlement deadline", "", "DATE"]
        ],
        [
            ["Other Brokerage Referral Commission, if any"],
            ["brokerage name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""],
            ["amount", ""]
        ],
        [
            ["Trust Account Deposit Information"],
            ["amount", ""],
            ["re-enter amount", ""],
            ["check date", "", "DATE"],
            ["check number", ""],
            ["payer name", ""],
            ["payee name", ""],
            ["type of funds", "", "PICKER", "cash", "check", "money order", "cashier's check", "wire transfer"],
            ["paid to", "", "PICKER", "our brokerage", "title company", "builder", "selling brokerage", "listing brokerage", "buyer", "seller", "buyer transfer EM", "other", "NSF", "void", "stopped"],
            ["comments/memo", ""]
        ],
        [
            ["Other Brokerage Infomation"],
            ["brokerage name", ""],
            ["broker name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""]
        ],
        [
            ["Other Agent Infomation"],
            ["agent name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""]
        ],
        [
            ["Buyer Title/Escrow/Legal Closing Company"],
            ["closing officer name", ""],
            ["company name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""]
        ],
        [
            ["Seller Title/Escrow/Legal Closing Company"],
            ["same as buyer", "no", "CHECKBOX"],
            ["closing officer name", ""],
            ["company name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""]
        ],
        [
            ["Mortgage Company"],
            ["financing type", "no", "RADIO", "mortgage financing only"],
            ["financing type", "no", "RADIO", "seller financing only"],
            ["financing type", "no", "RADIO", "mortgage and seller financing"],
            ["loan officer name", ""],
            ["company name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""]
        ],
        [   // ?
            ["IRS Required 1099 Info For Other Buyer Rep's Selling Brokerage"],
            ["type", "no", "RADIO", "brokerage (corporation)"],
            ["type", "no", "RADIO", "individual owner"],
            ["name", ""],
            ["address", "|||", "ADDRESS"],
            ["EIN/SSN", ""]
        ],
        [
            ["Property Inspection Company"],
            ["inspection request", "no", "RADIO", "buyer requested inspection"],
            ["inspection request", "no", "RADIO", "buyer signed waiver declining inspection"],
            ["inspector name", ""],
            ["company name", ""],
            ["address", ""],
            ["phone", ""],
            ["email", ""]
        ],
        [
            ["Buyer Property Insurance Company"],
            ["agent name", ""],
            ["company name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""]
        ],
        [
            ["Home Warranty Company"],
            ["warranty request", "no", "RADIO", "buyer requested warranty"],
            ["warranty request", "no", "RADIO", "buyer signed waiver declining warranty"],
            ["representative name", ""],
            ["company name", ""],
            ["address", "|||", "ADDRESS"],
            ["phone", ""],
            ["email", ""]
        ]
    ]
    
    func getFormattedAddress() -> String { // for display
        var address: String = self.properties[1][1][1]
        var addressArray = address.componentsSeparatedByString("|")
        if addressArray.count == 4 {
            addressArray.insert(" ", atIndex: 3)
            addressArray.insert(", ", atIndex: 2)
            addressArray.insert("\n", atIndex: 1)
            return join("", addressArray)
        }
        return ""
    }
    
    func getFormattedRepresentation() -> String {
        var section: [[String]] = self.properties[0]
        for row in section {
            if row[0] == "representation" && row[1] == "yes" {
                return row[3]
            }
        }
        return ""
    }
}