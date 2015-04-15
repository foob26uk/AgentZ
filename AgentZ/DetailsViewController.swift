//
//  DetailsViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/28/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NewCheckBoxCellDelegate, NewRadioCellDelegate, NewDateCellDelegate, NewPickerCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // FUTURE TODO
    // ability to delete and add rows, of type standard, address, or date
    // ability to reorganize sections and rows?
    // add misc section for etc information?
    // differentiate between sections completely filled and otherwise? like a check mark
    
    var transaction: Transaction!
    var transactionIndex: Int!
    var transactionUpdated: Bool!
    
    var headerHeight = CGFloat(40)
    var tabBarHeight: CGFloat!
    
    var detailsTableView: UITableView = UITableView()
    
    var expandSection: [Bool]!
    
    var logVC: LogViewController!
    
    var tableHeaderView: UIView!
    var agentTableHeaderLabel: UILabel!
    var statusTableHeaderLabel: UILabel!
    var agents: [PFUser]!
    
    let bgColor = UIColor(red: 210/255, green: 203/255, blue: 177/255, alpha: 0.95)
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItems = []
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 210/255, green: 203/255, blue: 177/255, alpha: 1.0)

        // to pass data to the other VCs
        let tb = self.tabBarController!
        let vcArray = tb.viewControllers as! [UIViewController]
        
        let _logVC = vcArray[3] as! LogViewController
        _logVC.transactionIndex = transactionIndex
        logVC = _logVC
        loadLogFromOnline()

        let reviewVC = vcArray[4] as! ReviewViewController
        reviewVC.transactionIndex = transactionIndex
        reviewVC.logVC = _logVC
        loadReviewFromOnline(reviewVC)
        
        let docsVC = vcArray[2] as! DocumentsViewController
        docsVC.transactionIndex = transactionIndex
        docsVC.logVC = _logVC
        loadDocumentsFromOnline(docsVC)
        
        let messagesVC = vcArray[1] as! MessagesViewController
        messagesVC.transactionIndex = transactionIndex
        loadMessagesFromOnline(messagesVC)
        
        transaction = transactions[transactionIndex]
        
        tabBarHeight = self.tabBarController!.tabBar.bounds.height
        detailsTableView.frame = CGRect(x: 5, y: navBarMaxY, width: newTableViewWidth, height: screenHeight - tabBarHeight - navBarMaxY)
        
        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        
        detailsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        detailsTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(detailsTableView)
        
        expandSection = [Bool](count: transaction.properties.count, repeatedValue: false)
        expandSection[0] = true
        
        let screenTapped = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        self.view.addGestureRecognizer(screenTapped)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        initializeTableHeader()
    }
    
    func initializeTableHeader() {
        if agent.title != "agent" {
            let tableHeaderHeight = CGFloat(80)
            tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: newTableViewWidth, height: tableHeaderHeight))
            tableHeaderView.backgroundColor = UIColor.clearColor()
            
            agentTableHeaderLabel = UILabel(frame: CGRect(x: 5, y: 0, width: newTableViewWidth - 10, height: tableHeaderHeight / 2))
            agentTableHeaderLabel.text = transaction.agentName
            agentTableHeaderLabel.font = UIFont.boldSystemFontOfSize(17)
            agentTableHeaderLabel.textAlignment = NSTextAlignment.Center
            tableHeaderView.addSubview(agentTableHeaderLabel)
            
            statusTableHeaderLabel = UILabel(frame: CGRect(x: 5, y: agentTableHeaderLabel.frame.maxY, width: newTableViewWidth - 10, height: tableHeaderHeight / 2))
            statusTableHeaderLabel.text = transaction.status
            statusTableHeaderLabel.font = UIFont.boldSystemFontOfSize(17)
            statusTableHeaderLabel.textAlignment = NSTextAlignment.Center
            tableHeaderView.addSubview(statusTableHeaderLabel)
            
            agentTableHeaderLabel.userInteractionEnabled = true
            let agentTapped = UITapGestureRecognizer(target: self, action: "selectAgent:")
            agentTableHeaderLabel.addGestureRecognizer(agentTapped)
            
            statusTableHeaderLabel.userInteractionEnabled = true
            let statusTapped = UITapGestureRecognizer(target: self, action: "selectStatus:")
            statusTableHeaderLabel.addGestureRecognizer(statusTapped)
            
            detailsTableView.tableHeaderView = tableHeaderView
        }
    }
    
    var keyboardHeight: CGFloat!
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            keyboardHeight = endFrame?.size.height ?? 0.0
        }

        detailsTableView.frame = CGRectMake(5, navBarMaxY, newTableViewWidth, screenHeight - keyboardHeight - navBarMaxY)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        detailsTableView.frame = CGRectMake(5, navBarMaxY, newTableViewWidth, screenHeight - tabBarHeight - navBarMaxY)
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func loadLogFromOnline() {
        var findParseLog: PFQuery = PFQuery(className: "Log")
        findParseLog.whereKey("transaction", equalTo: PFTransactions[transactionIndex])
        
        findParseLog.orderByDescending("createdAt")
        findParseLog.limit = 20
        
        findParseLog.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                self.logVC.log =  []
                
                for object in objects {
                    let theLogEntry = LogEntry(
                        author: object.objectForKey("author") as! PFUser,
                        authorName: object.objectForKey("authorName") as! String,
                        createdAt: object.createdAt,
                        sectionName: object.objectForKey("sectionName") as! String,
                        propertyName: object.objectForKey("propertyName") as! String,
                        oldValue: object.objectForKey("oldValue") as! String,
                        newValue: object.objectForKey("newValue") as! String,
                        propertyType: object.objectForKey("propertyType") as! String)
                    
                    self.logVC.log.append(theLogEntry)
                }
                
                if objects.count < findParseLog.limit {
                    self.logVC.setLoadMore = false
                }
            } else {
                println("Error downloading parse log")
            }
        }
    }
    
    func loadReviewFromOnline(reviewVC: ReviewViewController) {
        var findRequirements: PFQuery = PFQuery(className: "Review")
        findRequirements.whereKey("transaction", equalTo: PFTransactions[transactionIndex])
        
        findRequirements.orderByAscending("text")
        findRequirements.limit = 100 // default
        
        findRequirements.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                reviewVC.transactionRequirements = objects as! [PFObject]
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    func loadDocumentsFromOnline(docsVC: DocumentsViewController) {
        var findParseDocuments: PFQuery = PFQuery(className: "Document")
        findParseDocuments.whereKey("transaction", equalTo: PFTransactions[transactionIndex])
        findParseDocuments.selectKeys(["name", "description", "thumbnail"])
        findParseDocuments.whereKey("deleted", notEqualTo: true)
        
        findParseDocuments.orderByDescending("createdAt")
        findParseDocuments.limit = 20
        
        findParseDocuments.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                docsVC.docs = []
                
                for object in objects {
                    let _name = object.objectForKey("name") as! String
                    let _description = object.objectForKey("description") as! String
                    let _doc = Document(name: _name, description: _description)
                    let _thumbnail = object.objectForKey("thumbnail") as? PFFile
                    if let thumbnail = _thumbnail {
                        thumbnail.getDataInBackgroundWithBlock {
                            (tempData: NSData!, error: NSError!) -> Void in
                            if error == nil {
                                _doc.thumbnail = UIImage(data: tempData)
                            } else {
                                NSLog("%@", error)
                            }
                        }
                    }
                    docsVC.docs.append(_doc)
                    docsVC.docObjects.append(object as! PFObject)
                }
                
                if objects.count < findParseDocuments.limit {
                    docsVC.setLoadMore = false
                }
                
            } else {
                println("Error downloading documents info")
            }
        }
    }
    
    func loadMessagesFromOnline(messagesVC: MessagesViewController) {
        var findParseMessages: PFQuery = PFQuery(className: "Message")
        findParseMessages.whereKey("transaction", equalTo: PFTransactions[transactionIndex])
        
        findParseMessages.orderByDescending("createdAt")
        findParseMessages.limit = 20
        
        findParseMessages.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if error == nil {
                messagesVC.messages =  []
                
                for object in objects {
                    let author = object.objectForKey("author") as! PFUser
                    let authorName = object.objectForKey("authorName") as! String
                    let text = object.objectForKey("text") as! String
                    let createdAt = object.createdAt
                    let msg = Message(author: author, authorName: authorName, text: text, createdAt: createdAt)
                    
                    messagesVC.messages.append(msg)
                }
                messagesVC.messages = messagesVC.messages.reverse()
                
                if objects.count < findParseMessages.limit {
                    messagesVC.setLoadMore = false
                }
            } else {
                println("Error downloading parse messages")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expandSection[section] {
            return transaction.properties[section].count - 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let textArray = transaction.properties[indexPath.section][indexPath.row + 1]
        
        if textArray.count == 2 {
            return 60 // standard
        } else if textArray[2] == "ADDRESS" {
            return 90.1
        } else { // DATE, CHECKBOX, RADIO
            return 30
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let textArray = transaction.properties[indexPath.section][indexPath.row + 1]
        
        var cell: UITableViewCell?
        
        if textArray.count == 2 {
            cell = detailsTableView.dequeueReusableCellWithIdentifier("NewStandardCell") as? NewStandardCell
            if cell == nil {cell = NewStandardCell()}
        } else if textArray[2] == "ADDRESS" {
            cell = detailsTableView.dequeueReusableCellWithIdentifier("NewAddressCell") as? NewAddressCell
            if cell == nil {cell = NewAddressCell()}
        } else if textArray[2] == "DATE" {
            cell = detailsTableView.dequeueReusableCellWithIdentifier("NewDateCell") as? NewDateCell
            if cell == nil {cell = NewDateCell()}
        } else if textArray[2] == "CHECKBOX" {
            cell = detailsTableView.dequeueReusableCellWithIdentifier("NewCheckBoxCell") as? NewCheckBoxCell
            if cell == nil {cell = NewCheckBoxCell()}
        } else if textArray[2] == "RADIO" {
            cell = detailsTableView.dequeueReusableCellWithIdentifier("NewRadioBoxCell") as? NewRadioCell
            if cell == nil {cell = NewRadioCell()}
        }  else if textArray[2] == "PICKER" {
            cell = detailsTableView.dequeueReusableCellWithIdentifier("NewRadioBoxCell") as? NewPickerCell
            if cell == nil {cell = NewPickerCell()}
        } else {
            println("Panic: cellForRowAtIndexPath error")
        }
        
        return cell!
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let textArray = transaction.properties[indexPath.section][indexPath.row + 1]
        
        cell.backgroundColor = UIColor.clearColor()
        
        if textArray.count == 2 {
            let theCell = cell as! NewStandardCell
            theCell.valueTextField.delegate = self
            theCell.keyLabel.text = textArray[0]
            theCell.valueTextField.placeholder = textArray[0]
            theCell.valueTextField.text = textArray[1]
            theCell.valueTextField.tag = indexPath.section | indexPath.row << 16
            // to get values back
            // section = tag & 0xFFFF
            // row = (tag >> 16) & 0xFFFF
        } else if textArray[2] == "ADDRESS" {
            let theCell = cell as! NewAddressCell
            theCell.keyLabel.text = "address"
            theCell.streetTextField.delegate = self
            theCell.cityTextField.delegate = self
            theCell.stateTextField.delegate = self
            theCell.zipTextField.delegate = self
            
            var address = textArray[1]
            var addressArray = address.componentsSeparatedByString("|")
            theCell.streetTextField.text = addressArray[0]
            theCell.cityTextField.text = addressArray[1]
            theCell.stateTextField.text = addressArray[2]
            theCell.zipTextField.text = addressArray[3]
        
            let tagValue = indexPath.section | indexPath.row << 16
            theCell.streetTextField.tag = tagValue
            theCell.cityTextField.tag = tagValue
            theCell.stateTextField.tag = tagValue
            theCell.zipTextField.tag = tagValue
        } else if textArray[2] == "DATE" {
            let theCell = cell as! NewDateCell
            theCell.keyLabel.text = textArray[0]
            if textArray[1] == "" {
                theCell.valueLabel.text = "MM-dd-yyyy"
                theCell.valueLabel.font = UIFont.systemFontOfSize(14)
                theCell.valueLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
            } else {
                theCell.valueLabel.text = textArray[1]
                theCell.valueLabel.font = UIFont.systemFontOfSize(15)
                theCell.valueLabel.textColor = UIColor.blackColor()
            }
            theCell.delegate = self
            theCell.indexPathTag = indexPath.section | indexPath.row << 16
        } else if textArray[2] == "CHECKBOX" {
            let theCell = cell as! NewCheckBoxCell
            theCell.keyLabel.text = textArray[0]
            if textArray[1] == "yes" {
                theCell.checkBoxLabel.text = "\u{2612}"
            } else if textArray[1] == "no" {
                theCell.checkBoxLabel.text = "\u{2610}"
            } else {
                println("Panic: checkbox error")
            }
            theCell.delegate = self
            theCell.indexPathTag = indexPath.section | indexPath.row << 16
        } else if textArray[2] == "RADIO" {
            let theCell = cell as! NewRadioCell
            theCell.keyLabel.text = textArray[3]
            if textArray[1] == "yes" {
                theCell.radioLabel.text = "\u{25C9}"
            } else if textArray[1] == "no" {
                theCell.radioLabel.text = "\u{25CE}"
            } else {
                println("Panic: radio error")
            }
            theCell.delegate = self
            theCell.indexPathTag = indexPath.section | indexPath.row << 16
        }  else if textArray[2] == "PICKER" {
            let theCell = cell as! NewPickerCell
            theCell.keyLabel.text = "\(textArray[0]):"
            
            let width = newTableViewWidth - 10
            theCell.keyLabel.frame = CGRectMake(5, 0, width, newTableCellHeight)
            theCell.keyLabel.sizeToFit()
            theCell.keyLabel.frame.size.height = CGFloat(newTableCellHeight)
            theCell.valueLabel.frame = CGRectMake(theCell.keyLabel.frame.maxX + 5, 0, width - theCell.keyLabel.frame.width + 5, newTableCellHeight)
            
            if textArray[1] == "" {
                theCell.valueLabel.text = "[tap to select]"
                theCell.valueLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
            } else {
                theCell.valueLabel.text = textArray[1]
                theCell.valueLabel.textColor = UIColor.blackColor()
            }
            theCell.delegate = self
            theCell.indexPathTag = indexPath.section | indexPath.row << 16
        } else {
            println("Panic: willDisplayCell error")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return transaction.properties.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: newTableViewWidth, height: headerHeight))
        headerView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        
        var headerLabel = UILabel(frame: CGRect(x: 5, y: 0, width: newTableViewWidth - 10, height: headerHeight))
        headerLabel.text = transaction.properties[section][0][0]
        headerLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(headerLabel) // there is also insertSubview that animates differently
        
        // for expanding/contracting sections
        headerView.userInteractionEnabled = true
        let headerViewTapped = UITapGestureRecognizer(target: self, action: "expandOrContractSection:")
        headerView.tag = section
        headerView.addGestureRecognizer(headerViewTapped)
        
        return headerView
    }

    func expandOrContractSection(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            let section = view.tag
            if expandSection[section] {expandSection[section] = false}
            else {expandSection[section] = true}
            
            detailsTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.None)
        } else {println("Panic: expandOrContractSection error")}
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let section: Int = textField.tag & 0xFFFF
        let row: Int = (textField.tag >> 16) & 0xFFFF
        let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
        
        let textArray = transaction.properties[section][row + 1]
        if textArray.count == 2 {
            if let theCell = detailsTableView.cellForRowAtIndexPath(indexPath) as? NewStandardCell {
                if transaction.properties[section][row + 1][1] != theCell.valueTextField.text {
                    logChange(section, row: row + 1, oldValue: transaction.properties[section][row + 1][1], newValue: theCell.valueTextField.text)
                    transaction.properties[section][row + 1][1] = theCell.valueTextField.text
                }
            }
        } else if textArray[2] == "ADDRESS" {
            if let theCell = detailsTableView.cellForRowAtIndexPath(indexPath) as? NewAddressCell {
                var newAddress = "\(theCell.streetTextField.text)|\(theCell.cityTextField.text)|\(theCell.stateTextField.text)|\(theCell.zipTextField.text)"
                if transaction.properties[section][row + 1][1] != newAddress {
                    logChange(section, row: row + 1, oldValue: transaction.properties[section][row + 1][1], newValue: newAddress)
                    transaction.properties[section][row + 1][1] = newAddress
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // arrays are weird in swift, when assignment, there is copying
        let textArray = transaction.properties[indexPath.section][indexPath.row + 1]
        let section = indexPath.section
        let row = indexPath.row
        if textArray.count == 2 {
            let theCell = cell as! NewStandardCell
            if transaction.properties[section][row + 1][1] != theCell.valueTextField.text {
                logChange(section, row: row + 1, oldValue: transaction.properties[section][row + 1][1], newValue: theCell.valueTextField.text)
                transaction.properties[section][row + 1][1] = theCell.valueTextField.text
            }
        } else if textArray[2] == "ADDRESS" {
            let theCell = cell as! NewAddressCell
            var newAddress = "\(theCell.streetTextField.text)|\(theCell.cityTextField.text)|\(theCell.stateTextField.text)|\(theCell.zipTextField.text)"
            if transaction.properties[section][row + 1][1] != newAddress {
                logChange(section, row: row + 1, oldValue: transaction.properties[section][row + 1][1], newValue: newAddress)
                transaction.properties[section][row + 1][1] = newAddress
            }
        }
    }

    func logChange(section: Int, row: Int, oldValue: String, newValue: String) {
        // row is adjusted already i.e. (row + 1)

        let propertyType = (transaction.properties[section][row].count == 2) ? "STANDARD" : transaction.properties[section][row][2]
        
        var PFLogEntry: PFObject = PFObject(className: "Log")
        
        PFLogEntry["transaction"] = PFTransactions[transactionIndex]
        PFLogEntry["author"] = PFUser.currentUser()
        PFLogEntry["authorName"] = PFUser.currentUser().objectForKey("name")
        PFLogEntry["sectionName"] = transaction.properties[section][0][0]
        PFLogEntry["propertyName"] = transaction.properties[section][row][0]
        PFLogEntry["oldValue"] = oldValue
        PFLogEntry["newValue"] = newValue
        PFLogEntry["propertyType"] = propertyType

        PFLogEntry.saveEventually {
            (success: Bool, error: NSError!) -> Void in
            if success {
                let theLogEntry = LogEntry(
                    author: PFLogEntry["author"] as! PFUser,
                    authorName: PFLogEntry["authorName"] as! String,
                    createdAt: PFLogEntry.createdAt,
                    sectionName: PFLogEntry["sectionName"] as! String,
                    propertyName: PFLogEntry["propertyName"] as! String,
                    oldValue: PFLogEntry["oldValue"] as! String,
                    newValue: PFLogEntry["newValue"] as! String,
                    propertyType: PFLogEntry["propertyType"] as! String)

                self.logVC.log.insert(theLogEntry, atIndex: 0)
                self.logVC.logTableView.reloadData()
                
                self.transactionUpdated = true
            }
        }
    }
    
    // need to save check box state everytime it is tapped
    func boxTapped(indexPathTag: Int) {
        let section: Int = indexPathTag & 0xFFFF
        let row: Int = (indexPathTag >> 16) & 0xFFFF
        let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
        if let cell = detailsTableView.cellForRowAtIndexPath(indexPath) as? NewCheckBoxCell {
            if cell.checkBoxLabel.text == "\u{2610}" {
                cell.checkBoxLabel.text = "\u{2612}"
                logChange(section, row: row + 1, oldValue: transaction.properties[section][row + 1][1], newValue: "yes")
                transaction.properties[section][row + 1][1] = "yes"
            } else {
                cell.checkBoxLabel.text = "\u{2610}"
                logChange(section, row: row + 1, oldValue: transaction.properties[section][row + 1][1], newValue: "no")
                transaction.properties[section][row + 1][1] = "no"
            }
        }
    }
    
    // need to save radio button state everytime it is tapped, and deselect any other button
    func radioTapped(indexPathTag: Int) {
        let section: Int = indexPathTag & 0xFFFF
        let row: Int = (indexPathTag >> 16) & 0xFFFF
        let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
        if let cell = detailsTableView.cellForRowAtIndexPath(indexPath) as? NewRadioCell {
            if cell.radioLabel.text == "\u{25CE}" { // not selected
                cell.radioLabel.text = "\u{25C9}"
                transaction.properties[section][row + 1][1] = "yes"
                
                // find and deselect other radio buttons
                let radioName = transaction.properties[section][row + 1][0]
                var indexRow = row - 1
                
                var found = ""
                while indexRow >= 0 && transaction.properties[section][indexRow + 1][0] == radioName && transaction.properties[section][indexRow + 1][2] == "RADIO" {
                    if transaction.properties[section][indexRow + 1][1] == "yes" {
                        found = transaction.properties[section][indexRow + 1][3]
                        transaction.properties[section][indexRow + 1][1] = "no"
                        cell.radioLabel.text = "\u{25CE}"
                        break
                    }
                    indexRow -= 1
                }
                if found == "" {
                    indexRow = row + 1
                    let numRows = transaction.properties[section].count
                    while indexRow < (numRows - 1) && transaction.properties[section][indexRow + 1][0] == radioName && transaction.properties[section][indexRow + 1][2] == "RADIO" {
                        if transaction.properties[section][indexRow + 1][1] == "yes" {
                            found = transaction.properties[section][indexRow + 1][3]
                            transaction.properties[section][indexRow + 1][1] = "no"
                            cell.radioLabel.text = "\u{25CE}"
                            break
                        }
                        indexRow += 1
                    }
                }
                
                logChange(section, row: row + 1, oldValue: found, newValue: transaction.properties[section][row + 1][3])

                detailsTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.None) // not sure why checkbox code doesn't need this line to work, it's so weird
            }
        }
    }
    
    var theDatePicker: UIDatePicker?
    var dateFogView: UIView?
    var dateOkButton: UIButton?
    var dateCancelButton: UIButton?
    
    func dateTapped(indexPathTag: Int) {
        self.view.endEditing(true)
        
        let section: Int = indexPathTag & 0xFFFF
        let row: Int = (indexPathTag >> 16) & 0xFFFF
        
        // invisible view that blocks other actions
        if dateFogView == nil {
            dateFogView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
            dateFogView!.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        }
        
        self.view.addSubview(dateFogView!)
        
        if theDatePicker == nil {
            theDatePicker = UIDatePicker(frame: CGRectZero)
            theDatePicker!.datePickerMode = UIDatePickerMode.Date
            theDatePicker!.backgroundColor = bgColor
            theDatePicker!.frame.size.width = 300
            theDatePicker!.frame.origin.y = screenHeight / 2 - theDatePicker!.frame.height / 2
            theDatePicker!.frame.origin.x = (screenWidth - theDatePicker!.frame.width) / 2
            dateFogView!.addSubview(theDatePicker!)
        }
        
        if transaction.properties[section][row + 1][1] == "" {
            let currentDate = NSDate()
            theDatePicker!.date = currentDate
        } else {
            let dataFormatter: NSDateFormatter = NSDateFormatter()
            dataFormatter.dateFormat = "MM-dd-yyyy"
            theDatePicker!.date = dataFormatter.dateFromString(transaction.properties[section][row + 1][1])!
        }
        
        let buttonHeight = CGFloat(50)
        if dateOkButton == nil {
            dateOkButton = UIButton(frame: CGRectMake(screenWidth / 2, theDatePicker!.frame.maxY, theDatePicker!.frame.width / 2, buttonHeight))
            dateOkButton!.setTitle("Ok", forState: UIControlState.Normal)
            dateOkButton!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            dateOkButton!.backgroundColor = bgColor
            dateOkButton!.addTarget(self, action: "dateOkButton:", forControlEvents: UIControlEvents.TouchUpInside)
            dateFogView!.addSubview(dateOkButton!)
        }
        
        if dateCancelButton == nil {
            dateCancelButton = UIButton(frame: CGRectMake(theDatePicker!.frame.minX, theDatePicker!.frame.maxY, theDatePicker!.frame.width / 2, buttonHeight))
            dateCancelButton!.setTitle("Cancel", forState: UIControlState.Normal)
            dateCancelButton!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            dateCancelButton!.backgroundColor = bgColor
            dateCancelButton!.addTarget(self, action: "dateCancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
            dateFogView!.addSubview(dateCancelButton!)
        }
        
        dateOkButton!.tag = indexPathTag
    }
    
    func dateOkButton(sender: AnyObject) {
        let section: Int = sender.tag & 0xFFFF
        let row: Int = (sender.tag >> 16) & 0xFFFF
        let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)

        var dataFormatter: NSDateFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "MM-dd-yyyy"
        let date = dataFormatter.stringFromDate(theDatePicker!.date)

        if transaction.properties[section][row + 1][1] != date {
            if let cell = detailsTableView.cellForRowAtIndexPath(indexPath) as? NewDateCell {
                cell.valueLabel.text = date
                cell.valueLabel.font = UIFont.systemFontOfSize(15)
                cell.valueLabel.textColor = UIColor.blackColor()
            
                logChange(section, row: row + 1, oldValue: transaction.properties[section][row + 1][1], newValue: date)
                transaction.properties[section][row + 1][1] = date
            }
        }
        
        dateFogView!.removeFromSuperview()
    }
    
    func dateCancelButton(sender: AnyObject) {
        dateFogView!.removeFromSuperview() // maybe better to hide vs reomove?
    }
    
    var thePickerView: UIPickerView!
    var pickerFogView: UIView!
    var pickerData: [String]!
    var pickerOkButton: UIButton!
    var pickerCancelButton: UIButton!
    
    func pickerTapped(indexPathTag: Int) {
        self.view.endEditing(true)
        
        let section: Int = indexPathTag & 0xFFFF
        let row: Int = (indexPathTag >> 16) & 0xFFFF
        
        // invisible view that blocks other actions
        if pickerFogView == nil {
            pickerFogView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
            pickerFogView!.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        }
        
        self.view.addSubview(pickerFogView!)
        
        var arrCount = transaction.properties[section][row + 1].count
        pickerData = Array(transaction.properties[section][row + 1][3..<arrCount])
        
        if thePickerView == nil {
            thePickerView = UIPickerView(frame: CGRectZero)
            thePickerView!.frame.size.width = 300
            thePickerView!.frame.origin.y = screenHeight / 2 - thePickerView!.frame.height / 2
            thePickerView!.frame.origin.x = (screenWidth - thePickerView!.frame.width) / 2
            thePickerView!.backgroundColor = bgColor
            pickerFogView!.addSubview(thePickerView)
        }
        thePickerView.delegate = self
        thePickerView.dataSource = self
        thePickerView.selectRow(0, inComponent: 0, animated: false) // reset initial row selection
        
        let buttonHeight = CGFloat(50)
        if pickerOkButton == nil {
            pickerOkButton = UIButton(frame: CGRectMake(screenWidth / 2, thePickerView!.frame.maxY, thePickerView!.frame.width / 2, buttonHeight))
            pickerOkButton!.setTitle("Ok", forState: UIControlState.Normal)
            pickerOkButton!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            pickerOkButton!.backgroundColor = bgColor
            pickerOkButton!.addTarget(self, action: "pickerOkButton:", forControlEvents: UIControlEvents.TouchUpInside)
            pickerFogView!.addSubview(pickerOkButton!)
        }
        
        if pickerCancelButton == nil {
            pickerCancelButton = UIButton(frame: CGRectMake(thePickerView!.frame.minX, thePickerView!.frame.maxY, thePickerView!.frame.width / 2, buttonHeight))
            pickerCancelButton!.setTitle("Cancel", forState: UIControlState.Normal)
            pickerCancelButton!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            pickerCancelButton!.backgroundColor = bgColor
            pickerCancelButton!.addTarget(self, action: "pickerCancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
            pickerFogView!.addSubview(pickerCancelButton!)
        }
        
        pickerOkButton!.tag = indexPathTag
    }
    
    func pickerOkButton(sender: AnyObject) {
        let section: Int = sender.tag & 0xFFFF
        let row: Int = (sender.tag >> 16) & 0xFFFF
        let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)

        var pickerDataChosen = pickerData[thePickerView!.selectedRowInComponent(0)]
        if transaction.properties[section][row + 1][1] != pickerDataChosen {
            if let cell = detailsTableView.cellForRowAtIndexPath(indexPath) as? NewPickerCell {
            cell.valueLabel.text = pickerDataChosen
            cell.valueLabel.textColor = UIColor.blackColor()
            
            logChange(section, row: row + 1, oldValue: transaction.properties[section][row + 1][1], newValue: pickerDataChosen)
            transaction.properties[section][row + 1][1] = pickerDataChosen
            }
        }
        
        pickerFogView!.removeFromSuperview()
    }
    
    func pickerCancelButton(sender: AnyObject) {
        pickerFogView!.removeFromSuperview() // maybe better to hide vs reomove?
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    var theSelectAgentView: UIPickerView!
    var selectAgentFogView: UIView!
    var selectAgentOkButton: UIButton!
    var selectAgentCancelButton: UIButton!
    
    func selectAgent(sender: AnyObject) {
        self.view.endEditing(true)
        
        var findAgents: PFQuery = PFUser.query()
        findAgents.whereKey("title", equalTo: "agent")
        findAgents.orderByDescending("createdAt") // sorts it
        //findAgents.limit = ???
        
        findAgents.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.pickerData = []
                self.agents = []
                for object in objects {
                    let obj = object as! PFUser
                    let name = obj.objectForKey("name") as! String
                    self.pickerData.append(name)
                    self.agents.append(obj)
                }
                self.initializeSelectAgent()
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    func initializeSelectAgent() {
        // invisible view that blocks other actions
        if selectAgentFogView == nil {
            selectAgentFogView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
            selectAgentFogView!.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        }
        
        self.view.addSubview(selectAgentFogView!)
        
        if theSelectAgentView == nil {
            theSelectAgentView = UIPickerView(frame: CGRectZero)
            theSelectAgentView!.frame.size.width = 300
            theSelectAgentView!.frame.origin.y = screenHeight / 2 - theSelectAgentView!.frame.height / 2
            theSelectAgentView!.frame.origin.x = (screenWidth - theSelectAgentView!.frame.width) / 2
            theSelectAgentView!.backgroundColor = bgColor
            selectAgentFogView!.addSubview(theSelectAgentView)
        }
        
        theSelectAgentView.delegate = self
        theSelectAgentView.dataSource = self
        theSelectAgentView.selectRow(0, inComponent: 0, animated: false) // reset initial row selection
        
        let buttonHeight = CGFloat(50)
        if selectAgentOkButton == nil {
            selectAgentOkButton = UIButton(frame: CGRectMake(screenWidth / 2, theSelectAgentView!.frame.maxY, theSelectAgentView!.frame.width / 2, buttonHeight))
            selectAgentOkButton!.setTitle("Ok", forState: UIControlState.Normal)
            selectAgentOkButton!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            selectAgentOkButton!.backgroundColor = bgColor
            selectAgentOkButton!.addTarget(self, action: "selectAgentOkButton:", forControlEvents: UIControlEvents.TouchUpInside)
            selectAgentFogView!.addSubview(selectAgentOkButton!)
        }
        
        if selectAgentCancelButton == nil {
            selectAgentCancelButton = UIButton(frame: CGRectMake(theSelectAgentView!.frame.minX, theSelectAgentView!.frame.maxY, theSelectAgentView!.frame.width / 2, buttonHeight))
            selectAgentCancelButton!.setTitle("Cancel", forState: UIControlState.Normal)
            selectAgentCancelButton!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            selectAgentCancelButton!.backgroundColor = bgColor
            selectAgentCancelButton!.addTarget(self, action: "selectAgentCancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
            selectAgentFogView!.addSubview(selectAgentCancelButton!)
        }
    }
    
    func selectAgentOkButton(sender: AnyObject) {
        let idx = theSelectAgentView!.selectedRowInComponent(0)
        let name = pickerData[idx]

        if agents[idx].objectId != transaction.agent.objectId {
        
            var PFLogEntry: PFObject = PFObject(className: "Log")
            
            PFLogEntry["oldAgent"] = transaction.agent
            PFLogEntry["newAgent"] = agents[idx]
            
            PFLogEntry["transaction"] = PFTransactions[transactionIndex]
            PFLogEntry["author"] = PFUser.currentUser()
            PFLogEntry["authorName"] = PFUser.currentUser().objectForKey("name")
            PFLogEntry["sectionName"] = "DETAILS"
            PFLogEntry["propertyName"] = "agent"
            PFLogEntry["oldValue"] = transaction.agentName
            PFLogEntry["newValue"] = name
            PFLogEntry["propertyType"] = ""
            
            PFLogEntry.saveEventually {
                (success: Bool, error: NSError!) -> Void in
                if success {
                    self.agentTableHeaderLabel.text = name
                    self.transaction.agentName = name
                    self.transaction.agent = self.agents[idx]
                    self.transactionUpdated = true
                    let theLogEntry = LogEntry(
                        author: PFLogEntry["author"] as! PFUser,
                        authorName: PFLogEntry["authorName"] as! String,
                        createdAt: PFLogEntry.createdAt,
                        sectionName: PFLogEntry["sectionName"] as! String,
                        propertyName: PFLogEntry["propertyName"] as! String,
                        oldValue: PFLogEntry["oldValue"] as! String,
                        newValue: PFLogEntry["newValue"] as! String,
                        propertyType: PFLogEntry["propertyType"] as! String)
                    
                    self.logVC.log.insert(theLogEntry, atIndex: 0)
                    self.logVC.logTableView.reloadData()
                }
            }
        }

        selectAgentFogView!.removeFromSuperview()
    }
    
    func selectAgentCancelButton(sender: AnyObject) {
        selectAgentFogView!.removeFromSuperview() // maybe better to hide vs remove?
    }
    
    var theSelectStatusView: UIPickerView!
    var selectStatusFogView: UIView!
    var selectStatusOkButton: UIButton!
    var selectStatusCancelButton: UIButton!
    
    func selectStatus(sender: AnyObject) {
        self.view.endEditing(true)

        // invisible view that blocks other actions
        if selectStatusFogView == nil {
            selectStatusFogView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
            selectStatusFogView!.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        }
        
        self.view.addSubview(selectStatusFogView!)

        pickerData = ["new", "active", "inactive", "closed", "failed", "voided"]
        
        if theSelectStatusView == nil {
            theSelectStatusView = UIPickerView(frame: CGRectZero)
            theSelectStatusView!.frame.size.width = 300
            theSelectStatusView!.frame.origin.y = screenHeight / 2 - theSelectStatusView!.frame.height / 2
            theSelectStatusView!.frame.origin.x = (screenWidth - theSelectStatusView!.frame.width) / 2
            theSelectStatusView!.backgroundColor = bgColor
            selectStatusFogView!.addSubview(theSelectStatusView)
        }
        
        theSelectStatusView.delegate = self
        theSelectStatusView.dataSource = self
        theSelectStatusView.selectRow(0, inComponent: 0, animated: false) // reset initial row selection
        
        let buttonHeight = CGFloat(50)
        if selectStatusOkButton == nil {
            selectStatusOkButton = UIButton(frame: CGRectMake(screenWidth / 2, theSelectStatusView!.frame.maxY, theSelectStatusView!.frame.width / 2, buttonHeight))
            selectStatusOkButton!.setTitle("Ok", forState: UIControlState.Normal)
            selectStatusOkButton!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            selectStatusOkButton!.backgroundColor = bgColor
            selectStatusOkButton!.addTarget(self, action: "selectStatusOkButton:", forControlEvents: UIControlEvents.TouchUpInside)
            selectStatusFogView!.addSubview(selectStatusOkButton!)
        }
        
        if selectStatusCancelButton == nil {
            selectStatusCancelButton = UIButton(frame: CGRectMake(theSelectStatusView!.frame.minX, theSelectStatusView!.frame.maxY, theSelectStatusView!.frame.width / 2, buttonHeight))
            selectStatusCancelButton!.setTitle("Cancel", forState: UIControlState.Normal)
            selectStatusCancelButton!.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            selectStatusCancelButton!.backgroundColor = bgColor
            selectStatusCancelButton!.addTarget(self, action: "selectStatusCancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
            selectStatusFogView!.addSubview(selectStatusCancelButton!)
        }
    }
    
    func selectStatusOkButton(sender: AnyObject) {
        let idx = theSelectStatusView!.selectedRowInComponent(0)
        let status = pickerData[idx]
        
        if status != transaction.status {
            
            var PFLogEntry: PFObject = PFObject(className: "Log")
            
            PFLogEntry["transaction"] = PFTransactions[transactionIndex]
            PFLogEntry["author"] = PFUser.currentUser()
            PFLogEntry["authorName"] = PFUser.currentUser().objectForKey("name")
            PFLogEntry["sectionName"] = "DETAILS"
            PFLogEntry["propertyName"] = "status"
            PFLogEntry["oldValue"] = transaction.status
            PFLogEntry["newValue"] = status
            PFLogEntry["propertyType"] = ""
            
            PFLogEntry.saveEventually {
                (success: Bool, error: NSError!) -> Void in
                if success {
                    self.statusTableHeaderLabel.text = status
                    self.transaction.status = status
                    self.transactionUpdated = true
                    let theLogEntry = LogEntry(
                        author: PFLogEntry["author"] as! PFUser,
                        authorName: PFLogEntry["authorName"] as! String,
                        createdAt: PFLogEntry.createdAt,
                        sectionName: PFLogEntry["sectionName"] as! String,
                        propertyName: PFLogEntry["propertyName"] as! String,
                        oldValue: PFLogEntry["oldValue"] as! String,
                        newValue: PFLogEntry["newValue"] as! String,
                        propertyType: PFLogEntry["propertyType"] as! String)
                    
                    self.logVC.log.insert(theLogEntry, atIndex: 0)
                    self.logVC.logTableView.reloadData()
                }
            }
        }
        
        selectStatusFogView!.removeFromSuperview()
    }
    
    func selectStatusCancelButton(sender: AnyObject) {
        selectStatusFogView!.removeFromSuperview() // maybe better to hide vs remove?
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveChanges()
    }
    
    func saveChanges() {
        // find first responder, resign it so it will save
        for cell in detailsTableView.visibleCells() {
            let contentView = cell.contentView
            for child in contentView.subviews {
                if child.isFirstResponder() {
                    child.resignFirstResponder()
                }
            }
        }
        
        // save online
        if transactionUpdated == true {
            PFTransactions[transactionIndex]["status"] = transaction.status
            PFTransactions[transactionIndex]["agentName"] = transaction.agentName
            PFTransactions[transactionIndex]["agent"] = transaction.agent
            PFTransactions[transactionIndex]["properties"] = transaction.properties
            PFTransactions[transactionIndex].saveEventually()
            transactionUpdated = false
        }
    }

    /*
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if tabBarController.selectedIndex == 0 { // leaving details screen
            saveChanges()
        }
        
        return true
    }
    */
    
    /*
    func textFieldDidBeginEditing(textField: UITextField) -> Bool {
    let pointInTable: CGPoint = textField.superview!.convertPoint(textField.frame.origin, toView: detailsTableView)
    var contentOffset: CGPoint = detailsTableView.contentOffset
    
    let offset = screenHeight / 5
    if pointInTable.y > offset {
    contentOffset.y = pointInTable.y - offset
    detailsTableView.setContentOffset(contentOffset, animated: true)
    }
    
    return true
    }*/

    
    /*
    var swiped = UISwipeGestureRecognizer(target: self, action: "swipeHandler:")
    swiped.direction = UISwipeGestureRecognizerDirection.Right
    self.view.addGestureRecognizer(swiped)
    
    func swipeHandler(sender: UISwipeGestureRecognizer) {
    saveChanges()
    navigationController?.popViewControllerAnimated(true)
    }
    */
}
