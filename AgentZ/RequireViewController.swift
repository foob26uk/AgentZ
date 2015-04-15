//
//  RequireViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/29/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class RequireViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var reqTableView = UITableView()
    var tabBarHeight: CGFloat!
    var addButton: UIBarButtonItem!
    
    var requirements: [PFObject] = []
    
    override func viewWillDisappear(animated: Bool) {
        if barView != nil {
            barView.removeFromSuperview()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addButton:")
        self.tabBarController?.navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 226/255, green: 233/255, blue: 226/255, alpha: 1.0)
        
        tabBarHeight = self.tabBarController!.tabBar.bounds.height
        reqTableView.frame = CGRect(x: 20, y: navBarMaxY, width: tableViewWidth - 20, height: screenHeight - tabBarHeight - navBarMaxY)
        
        reqTableView.dataSource = self
        reqTableView.delegate = self
        
        reqTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        reqTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(reqTableView)
        
        loadReqsFromOnline()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    var keyboardHeight: CGFloat!
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            keyboardHeight = endFrame?.size.height ?? 0.0
        }

        reqTableView.frame = CGRectMake(20, navBarMaxY, tableViewWidth, screenHeight - keyboardHeight - navBarMaxY)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        reqTableView.frame = CGRectMake(20, navBarMaxY, tableViewWidth - 20, screenHeight - tabBarHeight - navBarMaxY)
    }
    
    func loadReqsFromOnline() {
        var findRequirements: PFQuery = PFQuery(className: "Requirement")
        
        findRequirements.orderByAscending("text")
        findRequirements.limit = 100 // default
        
        findRequirements.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.requirements = objects as [PFObject]
                self.reqTableView.reloadData()
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    var barView: UIView!
    var barTextField: UITextField!
    
    
    func addButton(sender: AnyObject) {
        let minY = self.navigationController!.navigationBar.frame.minY
        let maxY = self.navigationController!.navigationBar.frame.maxY

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        if barView == nil {
            barView = UIView(frame: CGRectMake(0, minY, screenWidth, maxY - minY))
            barView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            barTextField = UITextField(frame: CGRectMake(40, 0, barView.frame.width - 40 - 40, barView.frame.height))
            barTextField.placeholder = "Add requirement"
            barTextField.backgroundColor = UIColor.clearColor()
            //barTextField.borderStyle = UITextBorderStyle.RoundedRect
            barTextField.autocapitalizationType = UITextAutocapitalizationType.None
            barTextField.autocorrectionType = UITextAutocorrectionType.No
            barTextField.spellCheckingType = UITextSpellCheckingType.No
            barView.addSubview(barTextField)
            
            var cancelButton = UIButton(frame: CGRectMake(barTextField.frame.maxX, 0, maxY - minY, maxY - minY))
            cancelButton.backgroundColor = UIColor.clearColor()
            cancelButton.setTitle("X", forState: UIControlState.Normal)
            cancelButton.addTarget(self, action: "cancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
            cancelButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            barView.addSubview(cancelButton)
            
            barTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
            barTextField.returnKeyType = UIReturnKeyType.Done
            barTextField.delegate = self
        }
        
        barTextField.becomeFirstResponder()
        self.view.addSubview(barView)
    }
    
    func insertElementInRequirements(element: PFObject) -> Int {
        let text = element.objectForKey("text") as String
        var idx = 0
        while idx < requirements.count {
            if text < requirements[idx].objectForKey("text") as String {
                break
            }
            idx++
        }
        requirements.insert(element, atIndex: idx)
        return idx
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if !textField.text.isEmpty {
            var newReq = PFObject(className: "Requirement")
            newReq["text"] = textField.text
            newReq["selected"] = false
            newReq.saveInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if success {
                    let idx = self.insertElementInRequirements(newReq)
                    self.reqTableView.reloadData()
                } else {
                    NSLog("%@", error)
                }
            }
        }
        
        return true
    }
    
    func cancelButton(sender: AnyObject) {
        barView.removeFromSuperview()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if requirements[indexPath.row].objectForKey("selected") as Bool {
            requirements[indexPath.row]["selected"] = false
        } else {
            requirements[indexPath.row]["selected"] = true
        }
        
        requirements[indexPath.row].saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if success {
                self.reqTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            requirements[indexPath.row].deleteInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if success {
                    self.requirements.removeAtIndex(indexPath.row)
                    self.reqTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requirements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = reqTableView.dequeueReusableCellWithIdentifier("UITableViewCell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "UITableViewCell")
            cell?.backgroundColor = UIColor.clearColor()
            cell?.textLabel?.backgroundColor = UIColor.clearColor()
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel!.text = (requirements[indexPath.row].objectForKey("text") as String)
        
        if requirements[indexPath.row].objectForKey("selected") as Bool {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
}