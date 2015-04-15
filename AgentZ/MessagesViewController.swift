//
//  MessagesViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/29/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit
import MessageUI

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    // TODO
    // dynamic inputTextView up to a limit

    // option to require followup?
    
    var messagesTableView: UITableView = UITableView()
    var inputTextView: UITextView = UITextView()
    var theInputView: UIView = UIView()
    
    var tabBarHeight: CGFloat!
    var tableHeight: CGFloat!
    let textInputHeight = CGFloat(50)
    
    var transactionIndex: Int!
    
    var messages: [Message] = []
    var loading: Bool = false
    var headerView: UIView!
    var setLoadMore: Bool = true
    
    var screenTapped: UITapGestureRecognizer!
    
    var emailSwitch = UISwitch()
    
    override func viewWillAppear(animated: Bool) {
        //self.tabBarController?.navigationItem.rightBarButtonItem = nil
        //self.tabBarController?.navigationItem.rightBarButtonItems = []
        
        let _emailSwitch = UIBarButtonItem(customView: emailSwitch)
        var emailSwitchLabel = UILabel(frame: CGRectZero)
        emailSwitchLabel.text = "Email?"
        emailSwitchLabel.sizeToFit()
        let _emailSwitchLabel = UIBarButtonItem(customView: emailSwitchLabel)
        self.tabBarController?.navigationItem.rightBarButtonItems = [_emailSwitchLabel, _emailSwitch]
    }
    
    override func viewDidAppear(animated: Bool) {
        if messages.count > 0 {
            let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
            messagesTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 210/255, green: 203/255, blue: 177/255, alpha: 1.0)
        
        tabBarHeight = self.tabBarController!.tabBar.bounds.height
        tableHeight = screenHeight - tabBarHeight - navBarMaxY - textInputHeight
        messagesTableView.frame = CGRect(x: 10, y: navBarMaxY, width: tableViewWidth, height: tableHeight)
        
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        
        messagesTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        messagesTableView.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(messagesTableView)
        
        theInputView.frame = CGRect(x: 0, y: navBarMaxY + messagesTableView.frame.height, width: screenWidth, height: textInputHeight)
        theInputView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(theInputView)
        
        let sendButtonWidth = textInputHeight
        inputTextView.frame = CGRect(x: 0, y: 0, width: screenWidth - sendButtonWidth, height: textInputHeight)
        inputTextView.font = UIFont.systemFontOfSize(15)
        inputTextView.autocapitalizationType = UITextAutocapitalizationType.Sentences
        //inputTextView.autocorrectionType = UITextAutocorrectionType.Yes
        //inputTextView.spellCheckingType = UITextSpellCheckingType.Yes
        inputTextView.text = "tap here to start writing message"
        inputTextView.textColor = UIColor(white: 0.7, alpha: 1.0)
        inputTextView.delegate = self
        theInputView.addSubview(inputTextView)
        
        var sendButton = UIButton(frame: CGRectMake(inputTextView.frame.maxX, 0, sendButtonWidth, textInputHeight))
        sendButton.backgroundColor = UIColor.whiteColor()
        sendButton.setTitle("\u{329E}", forState: UIControlState.Normal)
        sendButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        sendButton.addTarget(self, action: "sendButton:", forControlEvents: UIControlEvents.TouchUpInside)
        theInputView.addSubview(sendButton)

        let headerHeight = CGFloat(47)
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableViewWidth, height: headerHeight))
        headerView.backgroundColor = UIColor.clearColor()
        
        var headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableViewWidth - 10, height: headerHeight))
        headerLabel.text = "Load More Messages"
        headerLabel.font = UIFont.boldSystemFontOfSize(17)
        headerLabel.textAlignment = NSTextAlignment.Center
        headerView.addSubview(headerLabel) // there is also insertSubview that animates differently
        
        headerView.userInteractionEnabled = true
        let headerViewTapped = UITapGestureRecognizer(target: self, action: "loadMoreMessagesFromOnline:")
        headerView.addGestureRecognizer(headerViewTapped)

        if setLoadMore {
            messagesTableView.tableHeaderView = headerView
        } else {
            messagesTableView.tableHeaderView = nil
        }
    
        // callback when keyboard frame changed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func sendButton(sender: AnyObject) {
        if inputTextView.text != "" && inputTextView.text != "tap here to start writing message" {
            
            var PFMsg: PFObject = PFObject(className: "Message")
            
            PFMsg["transaction"] = PFTransactions[transactionIndex]
            PFMsg["author"] = PFUser.currentUser()
            PFMsg["authorName"] = PFUser.currentUser().objectForKey("name") // better to store and retrieve faster than having to use fetchIfNeeded
            PFMsg["text"] = inputTextView.text
            
            PFMsg.saveInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if success {
                    var msg = Message(author: PFMsg["author"] as PFUser, authorName: PFMsg["authorName"] as String, text: PFMsg["text"] as String, createdAt: PFMsg.createdAt)

                    self.messages.append(msg)
                    self.inputTextView.text = "" // clear after send
                    
                    let indexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                    self.messagesTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                    self.messagesTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    
                    if self.emailSwitch.on {
                        self.emailAction(msg)
                    }
                }
            }
        }
    }

    func emailAction(msg: Message) {
        let subject = "Message from " + msg.authorName
        let body = "Sent from real estate app:\n" + msg.text
        
        var findAgents: PFQuery = PFUser.query()
        findAgents.orderByDescending("createdAt") // sorts it
        findAgents.selectKeys(["email"])

        if agent.title == "agent" {
            findAgents.whereKey("title", notEqualTo: "agent")
        } else {
            findAgents.whereKey("name", equalTo: transactions[transactionIndex].agentName)
        }

        findAgents.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                let recipients = objects as [PFUser]
                let recipientEmails: [String] = recipients.map {
                    user in
                    return user["email"] as String
                }
                
                var composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                composer.setSubject(subject)
                composer.setMessageBody(body, isHTML: false)
                composer.setToRecipients(recipientEmails)
                
                self.presentViewController(composer, animated: true, completion: nil)
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "tap here to start writing message" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "tap here to start writing message"
            textView.textColor = UIColor(white: 0.7, alpha: 1.0)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var keyboardHeight: CGFloat!
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            keyboardHeight = endFrame?.size.height ?? 0.0
            //keyboardHeight = (view.convertRect(endFrame!, fromView: nil)).size.height
        }
        
        var offset = -keyboardHeight + tabBarHeight
        messagesTableView.frame = CGRectMake(5, navBarMaxY, messagesTableView.frame.width, tableHeight + offset)
        theInputView.frame = CGRectMake(0, navBarMaxY + messagesTableView.frame.height, screenWidth, textInputHeight)
        
        if messages.count > 0 {
            let indexPath = NSIndexPath(forRow: messages.count - 1, inSection: 0)
            messagesTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
        
        screenTapped = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        self.view.addGestureRecognizer(screenTapped)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        messagesTableView.frame = CGRectMake(5, navBarMaxY, messagesTableView.frame.width, tableHeight)
        theInputView.frame = CGRectMake(0, navBarMaxY + messagesTableView.frame.height, screenWidth, textInputHeight)
        self.view.removeGestureRecognizer(screenTapped)
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func loadMoreMessagesFromOnline(sender: AnyObject) {
        if !loading {
            loading = true
            var findParseMessages: PFQuery = PFQuery(className: "Message")
            findParseMessages.whereKey("transaction", equalTo: PFTransactions[transactionIndex])
            
            findParseMessages.orderByDescending("createdAt")
            findParseMessages.limit = 20
            findParseMessages.skip = messages.count
            
            findParseMessages.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                
                if error == nil {
                    for object in objects {
                        let author = object.objectForKey("author") as PFUser
                        let authorName = object.objectForKey("authorName") as String
                        let text = object.objectForKey("text") as String
                        let createdAt = object.createdAt
                        let msg = Message(author: author, authorName: authorName, text: text, createdAt: createdAt)
                        
                        self.messages.insert(msg, atIndex: 0)
                    }

                    if objects.count < findParseMessages.limit {
                        self.messagesTableView.tableHeaderView = nil
                    } else {
                        self.messagesTableView.tableHeaderView = self.headerView
                    }

                    if objects.count > 0 {
                        self.messagesTableView.reloadData()
                    }
                } else {
                    NSLog("%@", error)
                }
                self.loading = false
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = messagesTableView.dequeueReusableCellWithIdentifier("MessagesCell") as? MessagesCell
        if cell == nil {cell = MessagesCell()}
        
        return cell!
    }
    
    let labelHeight = CGFloat(20)
    
    func tableView(tableView: UITableView, willDisplayCell cell: MessagesCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let entry = messages[indexPath.row]
        
        cell.keyLabel.text = entry.authorName
        cell.valueLabel.text = entry.text
        
        var dataFormatter: NSDateFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        cell.dateLabel.text = dataFormatter.stringFromDate(entry.createdAt)
        
        let valueLabelHeight = updateLabelFrame(entry.text, font: UIFont.systemFontOfSize(15))
        
        cell.keyLabel.frame = CGRectMake(10, 10, tableViewWidth / 2 - 10, labelHeight)
        cell.dateLabel.frame = CGRectMake(tableViewWidth / 2 , 10, tableViewWidth / 2 - 10, labelHeight)
        cell.valueLabel.frame = CGRectMake(10, cell.keyLabel.frame.maxY, tableViewWidth - 20, valueLabelHeight)
        cell.cellView.frame = CGRectMake(0, 0, tableViewWidth, cell.valueLabel.frame.maxY + 10)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index: Int!
        let entry = messages[indexPath.row]
        return 50 + updateLabelFrame(entry.text as NSString, font: UIFont.systemFontOfSize(15))
    }
    
    func updateLabelFrame(text: NSString!, font: UIFont!) -> CGFloat {
        var maxSize = CGSizeMake(tableViewWidth - 20, CGFloat(MAXFLOAT)) as CGSize // width, height
        var expectedSize = NSString(string: text!).boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size as CGSize
        return ceil(expectedSize.height)
    }
}
