//
//  NewTransactionViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/27/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

let newTableViewWidth = screenWidth - 10
let newTableCellHeight = CGFloat(30)

class NewTransactionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NewCheckBoxCellDelegate, NewRadioCellDelegate, NewDateCellDelegate, NewPickerCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // TODO
    // agent can add extra fields to transaction, like another phone number
    // different keyboards, different settings (e.g. auto-capitalization, auto-complete, ...)
    // data validation before saving (e.g. check date format, check address format, ...)
    // data/header lengths greater than a row?
    // pickerview should just use a tableview?
    // hide view instead of removeFromSuperview for pickers?
    
    var newTableView: UITableView = UITableView()
    var transaction: Transaction = Transaction()
    
    var headerHeight = CGFloat(40)
    var tabBarHeight: CGFloat!
    
    var textFieldBeingEdited: UITextField?
    
    var buttonClicked: Bool = false
    
    var disableButtons: Bool = false // disable buttons when displaying datepicker and pickerview
    
    var tableHeaderView: UIView!
    var tableHeaderLabel: UILabel!
    var agents: [PFUser]!
    
    let bgColor = UIColor(red: 226/255, green: 232/255, blue: 202/255, alpha: 0.95)
    
    override func viewWillAppear(animated: Bool) {
        let discardButton = UIBarButtonItem(title: "Discard", style: UIBarButtonItemStyle.Plain, target: self, action: "discardButton:")
        self.tabBarController?.navigationItem.leftBarButtonItem = discardButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveButton:")
        self.tabBarController?.navigationItem.rightBarButtonItem = saveButton
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 226/255, green: 232/255, blue: 202/255, alpha: 1.0)
        
        tabBarHeight = self.tabBarController!.tabBar.bounds.height
        newTableView.frame = CGRect(x: 5, y: navBarMaxY, width: newTableViewWidth, height: screenHeight - tabBarHeight - navBarMaxY)
        
        newTableView.dataSource = self
        newTableView.delegate = self
        
        // to add padding around tableView
        //var inset = UIEdgeInsets(top: 0, left: 0, bottom: 500, right: 0)
        //newTableView.contentInset = inset
        
        newTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        newTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(newTableView)
        
        let screenTapped = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        self.view.addGestureRecognizer(screenTapped)

        /*
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        keyboardHeight = 0.0
        offset = 0.0
        */

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        if agent.title != "agent" {
            let tableHeaderHeight = CGFloat(40)
            tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: newTableViewWidth, height: tableHeaderHeight))
            tableHeaderView.backgroundColor = UIColor.clearColor()
            
            tableHeaderLabel = UILabel(frame: CGRect(x: 5, y: 0, width: newTableViewWidth - 10, height: tableHeaderHeight))
            tableHeaderLabel.text = "[tap to select agent]"
            tableHeaderLabel.font = UIFont.boldSystemFontOfSize(17)
            tableHeaderLabel.textAlignment = NSTextAlignment.Center
            tableHeaderView.addSubview(tableHeaderLabel) // there is also insertSubview that animates differently
            
            tableHeaderView.userInteractionEnabled = true
            let headerViewTapped = UITapGestureRecognizer(target: self, action: "selectAgent:")
            tableHeaderView.addGestureRecognizer(headerViewTapped)
            
            newTableView.tableHeaderView = tableHeaderView
        }
    }
    
    var keyboardHeight: CGFloat!
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            keyboardHeight = endFrame?.size.height ?? 0.0
        }

        /*
        if textFieldBeingEdited != nil && textFieldBeingEdited!.isFirstResponder() {
            let indexPathTag = textFieldBeingEdited!.tag
            let section: Int = indexPathTag & 0xFFFF
            let row: Int = (indexPathTag >> 16) & 0xFFFF
            let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
            let rectInTableView: CGRect = newTableView.rectForRowAtIndexPath(indexPath) // find the CGRect of the cell
            let rect: CGRect = newTableView.convertRect(rectInTableView, toView: newTableView.superview) // convert CGRect coords to screen coordinate system
        }*/

        newTableView.frame = CGRectMake(5, navBarMaxY, newTableViewWidth, screenHeight - keyboardHeight - navBarMaxY)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        newTableView.frame = CGRectMake(5, navBarMaxY, newTableViewWidth, screenHeight - tabBarHeight - navBarMaxY)
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transaction.properties[section].count - 1
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
            cell = newTableView.dequeueReusableCellWithIdentifier("NewStandardCell") as? NewStandardCell
            if cell == nil {cell = NewStandardCell()}
        } else if textArray[2] == "ADDRESS" {
            cell = newTableView.dequeueReusableCellWithIdentifier("NewAddressCell") as? NewAddressCell
            if cell == nil {cell = NewAddressCell()}
        } else if textArray[2] == "DATE" {
            cell = newTableView.dequeueReusableCellWithIdentifier("NewDateCell") as? NewDateCell
            if cell == nil {cell = NewDateCell()}
        } else if textArray[2] == "CHECKBOX" {
            cell = newTableView.dequeueReusableCellWithIdentifier("NewCheckBoxCell") as? NewCheckBoxCell
            if cell == nil {cell = NewCheckBoxCell()}
        } else if textArray[2] == "RADIO" {
            cell = newTableView.dequeueReusableCellWithIdentifier("NewRadioBoxCell") as? NewRadioCell
            if cell == nil {cell = NewRadioCell()}
        } else if textArray[2] == "PICKER" {
            cell = newTableView.dequeueReusableCellWithIdentifier("NewRadioBoxCell") as? NewPickerCell
            if cell == nil {cell = NewPickerCell()}
        } else {
            println("Panic: cellForRowAtIndexPath error")
        }

        return cell!
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let textArray = transaction.properties[indexPath.section][indexPath.row + 1]

        if textArray.count == 2 {
            let theCell = cell as NewStandardCell
            theCell.valueTextField.delegate = self
            theCell.keyLabel.text = textArray[0]
            theCell.valueTextField.placeholder = textArray[0]
            theCell.valueTextField.text = textArray[1]
            theCell.valueTextField.tag = indexPath.section | indexPath.row << 16
            // to get values back
            // section = tag & 0xFFFF
            // row = (tag >> 16) & 0xFFFF
        } else if textArray[2] == "ADDRESS" {
            let theCell = cell as NewAddressCell
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
            let theCell = cell as NewDateCell
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
            let theCell = cell as NewCheckBoxCell
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
            let theCell = cell as NewRadioCell
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
        } else if textArray[2] == "PICKER" {
            let theCell = cell as NewPickerCell
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
        headerView.backgroundColor = UIColor(white: 0.8, alpha: 0.8) // white value is amount of black, alpha value is transparency
        
        var headerLabel = UILabel(frame: CGRect(x: 5, y: 0, width: newTableViewWidth - 10, height: headerHeight))
        headerLabel.text = transaction.properties[section][0][0]
        headerView.addSubview(headerLabel) // there is also insertSubview that animates differently
        
        /* for expanding/contracting sections
        headerView.userInteractionEnabled = true
        let headerViewTapped = UITapGestureRecognizer(target: self, action: "expandOrContractSection:")
        headerView.tag = section
        headerView.addGestureRecognizer(headerViewTapped)
        */
        
        return headerView
    }
    
    func textFieldDidBeginEditing(textField: UITextField) -> Bool {
        textFieldBeingEdited = textField
        
        /*
        let pointInTable: CGPoint = textField.superview!.convertPoint(textField.frame.origin, toView: newTableView)
        var contentOffset: CGPoint = newTableView.contentOffset

        let offset = screenHeight / 5
        if pointInTable.y > offset {
            contentOffset.y = pointInTable.y - offset
            newTableView.setContentOffset(contentOffset, animated: true)
        }
        */
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textFieldBeingEdited = nil
        
        let section: Int = textField.tag & 0xFFFF
        let row: Int = (textField.tag >> 16) & 0xFFFF
        let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)

        let textArray = transaction.properties[section][row + 1]
        if textArray.count == 2 {
            if let theCell = newTableView.cellForRowAtIndexPath(indexPath) as? NewStandardCell {
                transaction.properties[section][row + 1][1] = theCell.valueTextField.text
            }
        } else if textArray[2] == "ADDRESS" {
            if let theCell = newTableView.cellForRowAtIndexPath(indexPath) as? NewAddressCell {
                transaction.properties[section][row + 1][1] = "\(theCell.streetTextField.text)|\(theCell.cityTextField.text)|\(theCell.stateTextField.text)|\(theCell.zipTextField.text)"
            }
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if !buttonClicked {
            // arrays are weird in swift, when assignment, there is copying
            let textArray = transaction.properties[indexPath.section][indexPath.row + 1]
            if textArray.count == 2 {
                let theCell = cell as NewStandardCell
                // can't assign to textArray, it's a different array after assignment, wtf (have to use NSMutableArray)
                transaction.properties[indexPath.section][indexPath.row + 1][1] = theCell.valueTextField.text
            } else if textArray[2] == "ADDRESS" {
                let theCell = cell as NewAddressCell
                transaction.properties[indexPath.section][indexPath.row + 1][1] = "\(theCell.streetTextField.text)|\(theCell.cityTextField.text)|\(theCell.stateTextField.text)|\(theCell.zipTextField.text)"
            }
        }
    }
    
    // need to save check box state everytime it is tapped
    func boxTapped(indexPathTag: Int) {
        let section: Int = indexPathTag & 0xFFFF
        let row: Int = (indexPathTag >> 16) & 0xFFFF
        let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
        if let cell = newTableView.cellForRowAtIndexPath(indexPath) as? NewCheckBoxCell {
            if cell.checkBoxLabel.text == "\u{2610}" {
                cell.checkBoxLabel.text = "\u{2612}"
                transaction.properties[section][row + 1][1] = "yes"
            } else {
                cell.checkBoxLabel.text = "\u{2610}"
                transaction.properties[section][row + 1][1] = "no"
            }
        }
    }

    // need to save radio button state everytime it is tapped, and deselect any other button
    func radioTapped(indexPathTag: Int) {
        let section: Int = indexPathTag & 0xFFFF
        let row: Int = (indexPathTag >> 16) & 0xFFFF
        let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: section)
        if let cell = newTableView.cellForRowAtIndexPath(indexPath) as? NewRadioCell {
            if cell.radioLabel.text == "\u{25CE}" { // not selected
                cell.radioLabel.text = "\u{25C9}"
                transaction.properties[section][row + 1][1] = "yes"

                // find and deselect other radio buttons
                let radioName = transaction.properties[section][row + 1][0]
                var indexRow = row - 1
                while indexRow >= 0 && transaction.properties[section][indexRow + 1][0] == radioName && transaction.properties[section][indexRow + 1][2] == "RADIO" {
                    transaction.properties[section][indexRow + 1][1] = "no"
                    cell.radioLabel.text = "\u{25CE}"
                    indexRow -= 1
                }
                indexRow = row + 1
                let numRows = transaction.properties[section].count
                while indexRow < (numRows - 1) && transaction.properties[section][indexRow + 1][0] == radioName && transaction.properties[section][indexRow + 1][2] == "RADIO" {
                    transaction.properties[section][indexRow + 1][1] = "no"
                    cell.radioLabel.text = "\u{25CE}"
                    indexRow += 1
                }
                
                newTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.None) // not sure why checkbox code doesn't need this line to work, it's so weird
            }
        }
    }

    var theDatePicker: UIDatePicker?
    var dateFogView: UIView?
    var dateOkButton: UIButton?
    var dateCancelButton: UIButton?
    
    func dateTapped(indexPathTag: Int) {
        disableButtons = true
        
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
        
        if let cell = newTableView.cellForRowAtIndexPath(indexPath) as? NewDateCell {
            var dataFormatter: NSDateFormatter = NSDateFormatter()
            dataFormatter.dateFormat = "MM-dd-yyyy"
            let date = dataFormatter.stringFromDate(theDatePicker!.date)
            
            cell.valueLabel.text = date
            cell.valueLabel.font = UIFont.systemFontOfSize(15)
            cell.valueLabel.textColor = UIColor.blackColor()

            transaction.properties[section][row + 1][1] = date
        }
        
        dateFogView!.removeFromSuperview()
        
        disableButtons = false
    }
    
    func dateCancelButton(sender: AnyObject) {
        dateFogView!.removeFromSuperview() // maybe better to hide vs reomove?
        
        disableButtons = false
    }
    
    var thePickerView: UIPickerView!
    var pickerFogView: UIView!
    var pickerData: [String]!
    var pickerOkButton: UIButton!
    var pickerCancelButton: UIButton!
    
    func pickerTapped(indexPathTag: Int) {
        disableButtons = true
        
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
        
        if let cell = newTableView.cellForRowAtIndexPath(indexPath) as? NewPickerCell {
            var pickerDataChosen = pickerData[thePickerView!.selectedRowInComponent(0)]
            
            cell.valueLabel.text = pickerDataChosen
            cell.valueLabel.textColor = UIColor.blackColor()
            
            transaction.properties[section][row + 1][1] = pickerDataChosen
        }
        
        pickerFogView!.removeFromSuperview()
        
        disableButtons = false
    }
    
    func pickerCancelButton(sender: AnyObject) {
        pickerFogView!.removeFromSuperview() // maybe better to hide vs remove?
        
        disableButtons = false
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    //func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

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
        disableButtons = true
        
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
                    let obj = object as PFUser
                    let name = obj.objectForKey("name") as String
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
        tableHeaderLabel.text = name
        transaction.agentName = name
        transaction.agent = agents[idx]
        
        selectAgentFogView!.removeFromSuperview()
        
        disableButtons = false
    }
    
    func selectAgentCancelButton(sender: AnyObject) {
        selectAgentFogView!.removeFromSuperview() // maybe better to hide vs remove?
        
        disableButtons = false
    }

    
    func discardButton(sender: AnyObject) {
        if !disableButtons {
            buttonClicked = true
            
            if textFieldBeingEdited != nil && textFieldBeingEdited!.isFirstResponder() {textFieldBeingEdited!.resignFirstResponder()} // gets rid of keyboard
            
            transaction = Transaction()
            newTableView.reloadData()
            if agent.title != "agent" {
                tableHeaderLabel.text = "[tap to select agent]"
            }

            buttonClicked = false
        }
    }

    func saveButton(sender: AnyObject) {
        if !disableButtons {
            buttonClicked = true
            
            if textFieldBeingEdited != nil && textFieldBeingEdited!.isFirstResponder() {textFieldBeingEdited!.resignFirstResponder()} // calls textFieldDidEndEditing to save
            
            var messageAlert: String?

            if agent.title == "agent" {
                transaction.agentName = PFUser.currentUser().objectForKey("name") as String
            }
            
            if transaction.properties[1][1][1] == "|||" { // check if property address is empty
                messageAlert = "No property address"
            } else if transaction.agentName == "" {
                messageAlert = "No agent selected"
            } else {
                // code here to check for duplicates (very basic)
                // this is to prevent agent from creating too many duplicates accidentally, not to prevent all cases of duplicates occurring in the system, especially not malicious creation of duplicates
                var foundDuplicate = false
                for someTransaction in transactions {
                    if someTransaction.properties[1][1][1] == transaction.properties[1][1][1] {
                        messageAlert = "Duplicate property address"
                        foundDuplicate = true
                    }
                }
                
                if !foundDuplicate {
                    var countQuery = PFQuery(className: "TCount")
                    countQuery.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject!, error: NSError!) -> Void in
                        if object != nil {
                            object.incrementKey("count")
                            object.saveInBackground()
                            self.saveTransaction(object["count"] as Int)
                        }
                    }
                }
            }
            
            if messageAlert != nil {
                var noSaveAlert: UIAlertController = UIAlertController(title: "Save Failed", message: messageAlert, preferredStyle: UIAlertControllerStyle.Alert)
                noSaveAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(noSaveAlert, animated: true, completion: nil)
            }
            
            buttonClicked = false
        }
    }
    
    func saveTransaction(transactionCount: Int) {
        var ParseTransaction: PFObject = PFObject(className: "Transaction")
        
        ParseTransaction["count"] = transactionCount
        ParseTransaction["agent"] = transaction.agent
        ParseTransaction["agentName"] = transaction.agentName
        ParseTransaction["uploadedBy"] = PFUser.currentUser()
        ParseTransaction["brokerFollowupRequired"] = transaction.brokerFollowupRequired
        ParseTransaction["agentFollowupRequired"] = transaction.agentFollowupRequired
        ParseTransaction["status"] = transaction.status
        ParseTransaction["properties"] = transaction.properties
        
        ParseTransaction.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if success {
                self.transaction.transactionCount = ParseTransaction["count"] as Int
                self.transaction.transactionID = ParseTransaction.objectId
                transactions.insert(self.transaction, atIndex: 0)
                PFTransactions.insert(ParseTransaction, atIndex: 0)
                
                // TODO: should be cloud code not run locally
                // creating requirements and logging it, for new transaction
                var findRequirements: PFQuery = PFQuery(className: "Requirement")
                findRequirements.orderByAscending("text")
                findRequirements.whereKey("selected", equalTo: true)
                findRequirements.limit = 100 // default
                findRequirements.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        var requirements = objects as [PFObject]
                        if requirements.count > 0 {
                            ParseTransaction["agentFollowupRequired"] = true
                            ParseTransaction.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError!) -> Void in
                                if success {
                                    transactions[0].agentFollowupRequired = true
                                    for req in requirements {
                                        var transactionRequirement: PFObject = PFObject(className: "Review")
                                        transactionRequirement["transaction"] = ParseTransaction
                                        transactionRequirement["requirement"] = req
                                        transactionRequirement["text"] = req.objectForKey("text")
                                        transactionRequirement["agentFlag"] = true
                                        transactionRequirement["brokerFlag"] = false
                                        transactionRequirement["comment"] = ""
                                        transactionRequirement.saveInBackgroundWithBlock {
                                            (success: Bool, error: NSError!) -> Void in
                                            if success {
                                                var logEntry: PFObject = PFObject(className: "Log")
                                                logEntry["transaction"] = ParseTransaction
                                                logEntry["author"] = PFUser.currentUser()
                                                logEntry["authorName"] = PFUser.currentUser().objectForKey("name")
                                                logEntry["newValue"] = ""
                                                logEntry["oldValue"] = "ADD"
                                                logEntry["propertyName"] = transactionRequirement.objectForKey("text")
                                                logEntry["propertyType"] = ""
                                                logEntry["sectionName"] = "REVIEW"
                                                logEntry.saveInBackgroundWithBlock {
                                                    (success: Bool, error: NSError!) -> Void in
                                                    if error != nil {
                                                        NSLog("%@", error)
                                                    }
                                                }
                                            } else {
                                                NSLog("%@", error)
                                            }
                                        }
                                    }
                                    self.tabBarController?.selectedIndex = 2 // move to other view
                                } else {
                                    NSLog("%@", error)
                                }
                            }
                        }
                    } else {
                        NSLog("%@", error)
                    }
                } // end of what should be cloud code
                
                self.discardButton(self)
                //self.tabBarController?.selectedIndex = 2 // move to other view
            }
        }
    }
    
    // pressing return button, just dismisses the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
