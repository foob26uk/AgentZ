//
//  ReviewViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/29/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditReviewDelegate {
    
    // TODO: loadMore?
    
    var reviewTableView = UITableView()
    var tabBarHeight: CGFloat!
    var addButton: UIBarButtonItem!

    var transactionIndex: Int!
    var transactionRequirements: [PFObject] = []
    
    var logVC: LogViewController!
    
    override func viewWillAppear(animated: Bool) {
        if agent.title == "agent" {
            self.tabBarController?.navigationItem.rightBarButtonItems = []
            self.tabBarController?.navigationItem.rightBarButtonItem = nil
        } else {
            let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "addButton:")
            self.tabBarController?.navigationItem.rightBarButtonItems = []
            self.tabBarController?.navigationItem.rightBarButtonItem = editButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 210/255, green: 203/255, blue: 177/255, alpha: 1.0)
        
        tabBarHeight = self.tabBarController!.tabBar.bounds.height
        reviewTableView.frame = CGRect(x: 20, y: navBarMaxY, width: tableViewWidth - 20, height: screenHeight - tabBarHeight - navBarMaxY)
        
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        
        reviewTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        reviewTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(reviewTableView)
    }
    
    func insertRequirementAtIndex(requirement: PFObject, idx: Int) {
        log(requirement.objectForKey("text") as String, oldValue: "ADD", newValue: "")
        transactionRequirements.insert(requirement, atIndex: idx)
        var indexPath: NSIndexPath = NSIndexPath(forRow: idx, inSection: 0)
        reviewTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        updateFollowupFlags()
    }
    
    func removeRequirementAtIndex(idx: Int) {
        log(transactionRequirements[idx].objectForKey("text") as String, oldValue: "REMOVE", newValue: "")
        transactionRequirements.removeAtIndex(idx)
        var indexPath: NSIndexPath = NSIndexPath(forRow: idx, inSection: 0)
        reviewTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        updateFollowupFlags()
    }
    
    func addButton(sender: AnyObject) {
        self.performSegueWithIdentifier("gotoEditReview", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoEditReview" {
            let vc = segue.destinationViewController as EditReviewViewController
            vc.transactionIndex = transactionIndex
            vc.transactionRequirements = transactionRequirements
            vc.delegate = self
        }
    }
    
    func updateFollowupFlags() {
        var foundAgentFlag = false
        var foundBrokerFlag = false
        for requirement in transactionRequirements {
            if requirement.objectForKey("agentFlag") as Bool {
                foundAgentFlag = true
            } else if requirement.objectForKey("brokerFlag") as Bool {
                foundBrokerFlag = true
            }
        }
        
        if foundAgentFlag {
            transactions[transactionIndex].agentFollowupRequired = true
            PFTransactions[transactionIndex]["agentFollowupRequired"] = true
        } else {
            transactions[transactionIndex].agentFollowupRequired = false
            PFTransactions[transactionIndex]["agentFollowupRequired"] = false
        }
        
        if foundBrokerFlag {
            transactions[transactionIndex].brokerFollowupRequired = true
            PFTransactions[transactionIndex]["brokerFollowupRequired"] = true
        } else {
            transactions[transactionIndex].brokerFollowupRequired = false
            PFTransactions[transactionIndex]["brokerFollowupRequired"] = false
        }
        
        PFTransactions[transactionIndex].saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if error != nil {
                NSLog("%@", error)
            }
        }
    }
    
    func log(form: String, oldValue: String, newValue: String) {
        var logEntry: PFObject = PFObject(className: "Log")
        logEntry["transaction"] = PFTransactions[transactionIndex]
        logEntry["author"] = PFUser.currentUser()
        logEntry["authorName"] = PFUser.currentUser().objectForKey("name")
        logEntry["newValue"] = newValue
        logEntry["oldValue"] = oldValue
        logEntry["propertyName"] = form
        logEntry["propertyType"] = ""
        logEntry["sectionName"] = "REVIEW"
        logEntry.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if success {
                let _logEntry = LogEntry(
                    author: PFUser.currentUser(),
                    authorName: logEntry.objectForKey("authorName") as String,
                    createdAt: logEntry.createdAt,
                    sectionName: "REVIEW",
                    propertyName: form,
                    oldValue: oldValue,
                    newValue: newValue,
                    propertyType: "")
                self.logVC.log.insert(_logEntry, atIndex: 0)
                self.logVC.logTableView.reloadData()
            } else {
                NSLog("%@", error)
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        reviewTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if agent.title == "agent" {
            let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let commentOption = UIAlertAction(title: "Comment", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                
                var commentAlert: UIAlertController = UIAlertController(title: "Enter Comment", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                commentAlert.addTextFieldWithConfigurationHandler(nil)
                commentAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                    alertAction in
                    let textFields: NSArray = commentAlert.textFields! as NSArray
                    let commentTextField: UITextField = textFields.objectAtIndex(0) as UITextField

                    let oldComment = self.transactionRequirements[indexPath.row].objectForKey("comment") as String
                    self.transactionRequirements[indexPath.row]["comment"] = commentTextField.text
                    self.transactionRequirements[indexPath.row].saveInBackgroundWithBlock {
                        (success: Bool, error: NSError!) -> Void in
                        if success {
                            self.log(self.transactionRequirements[indexPath.row].objectForKey("text") as String, oldValue: oldComment, newValue: commentTextField.text)
                            self.reviewTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        } else {
                            NSLog("%@", error)
                        }
                    }
                }))
                self.presentViewController(commentAlert, animated: true, completion: nil)
            })
            let submitOption = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                
                self.transactionRequirements[indexPath.row]["agentFlag"] = false
                self.transactionRequirements[indexPath.row]["brokerFlag"] = true
                self.transactionRequirements[indexPath.row].saveInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
                    if success {
                        self.log(self.transactionRequirements[indexPath.row].objectForKey("text") as String, oldValue: "SUBMIT", newValue: "")
                        self.reviewTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.updateFollowupFlags()
                    } else {
                        NSLog("%@", error)
                    }
                }
            })
            let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)

            let brokerFlag = transactionRequirements[indexPath.row].objectForKey("brokerFlag") as Bool
            if brokerFlag {
                submitOption.enabled = false
            }
            
            actionMenu.addAction(commentOption)
            actionMenu.addAction(submitOption)
            actionMenu.addAction(cancelOption)
            self.presentViewController(actionMenu, animated: true, completion: nil)
            
        } else {
            let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let removeOption = UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive, handler: {
                (action: UIAlertAction!) -> Void in

                self.transactionRequirements[indexPath.row].deleteInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
                    if success {
                        self.log(self.transactionRequirements[indexPath.row].objectForKey("text") as String, oldValue: "REMOVE", newValue: "")
                        self.transactionRequirements.removeAtIndex(indexPath.row)
                        self.reviewTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.updateFollowupFlags()
                    } else {
                        NSLog("%@", error)
                    }
                }
            })
            let commentOption = UIAlertAction(title: "Comment", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in

                var commentAlert: UIAlertController = UIAlertController(title: "Enter Comment", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                commentAlert.addTextFieldWithConfigurationHandler(nil)
                commentAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                    alertAction in
                    let textFields: NSArray = commentAlert.textFields! as NSArray
                    let commentTextField: UITextField = textFields.objectAtIndex(0) as UITextField

                    let oldComment = self.transactionRequirements[indexPath.row].objectForKey("comment") as String
                    self.transactionRequirements[indexPath.row]["comment"] = commentTextField.text
                    self.transactionRequirements[indexPath.row].saveInBackgroundWithBlock {
                        (success: Bool, error: NSError!) -> Void in
                        if success {
                            self.log(self.transactionRequirements[indexPath.row].objectForKey("text") as String, oldValue: oldComment, newValue: commentTextField.text)
                            self.reviewTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        } else {
                            NSLog("%@", error)
                        }
                    }
                }))
                self.presentViewController(commentAlert, animated: true, completion: nil)
            })
            let acceptOption = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                
                self.transactionRequirements[indexPath.row]["agentFlag"] = false
                self.transactionRequirements[indexPath.row]["brokerFlag"] = false
                self.transactionRequirements[indexPath.row].saveInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
                    if success {
                        self.log(self.transactionRequirements[indexPath.row].objectForKey("text") as String, oldValue: "ACCEPT", newValue: "")
                        self.reviewTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.updateFollowupFlags()
                    } else {
                        NSLog("%@", error)
                    }
                }
            })
            let rejectOption = UIAlertAction(title: "Reject", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                self.transactionRequirements[indexPath.row]["agentFlag"] = true
                self.transactionRequirements[indexPath.row]["brokerFlag"] = false
                self.transactionRequirements[indexPath.row].saveInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
                    if success {
                        self.log(self.transactionRequirements[indexPath.row].objectForKey("text") as String, oldValue: "REJECT", newValue: "")
                        self.reviewTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.updateFollowupFlags()
                    } else {
                        NSLog("%@", error)
                    }
                }
            })
            let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            let agentFlag = transactionRequirements[indexPath.row].objectForKey("agentFlag") as Bool
            let brokerFlag = transactionRequirements[indexPath.row].objectForKey("brokerFlag") as Bool
            
            if agentFlag {
                rejectOption.enabled = false
            } else if !brokerFlag {
                acceptOption.enabled = false
            }
            actionMenu.addAction(removeOption)
            actionMenu.addAction(commentOption)
            actionMenu.addAction(acceptOption)
            actionMenu.addAction(rejectOption)
            actionMenu.addAction(cancelOption)
            self.presentViewController(actionMenu, animated: true, completion: nil)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionRequirements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = reviewTableView.dequeueReusableCellWithIdentifier("ReviewCell") as? ReviewCell
        if cell == nil {cell = ReviewCell()}
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: ReviewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.titleLabel.text = (transactionRequirements[indexPath.row].objectForKey("text") as String)
        
        let agentFlag = transactionRequirements[indexPath.row].objectForKey("agentFlag") as Bool
        let brokerFlag = transactionRequirements[indexPath.row].objectForKey("brokerFlag") as Bool
        
        if agentFlag {
            cell.flagLabel.text = " A "
            cell.flagLabel.backgroundColor = UIColor.yellowColor()
        } else if brokerFlag {
            cell.flagLabel.text = " B "
            cell.flagLabel.backgroundColor = UIColor.cyanColor()
        } else {
            cell.flagLabel.text = ""
            cell.flagLabel.backgroundColor = UIColor.clearColor()
        }

        cell.flagLabel.sizeToFit()
        cell.flagLabel.frame = CGRectMake(cell.frame.width - cell.flagLabel.frame.width, 5, cell.flagLabel.frame.width, 20)
        
        cell.titleLabel.frame = CGRectMake(0, 0, cell.frame.width - cell.flagLabel.frame.width, 25)
        let comment = transactionRequirements[indexPath.row].objectForKey("comment") as String
        if comment != "" {
            cell.commentLabel.text = comment
            cell.commentLabel.frame = CGRectMake(0, cell.titleLabel.frame.maxY, cell.frame.width, 20)
        } else {
            cell.commentLabel.text = ""
            cell.commentLabel.frame = CGRectZero
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (transactionRequirements[indexPath.row].objectForKey("comment") as String) != "" {
            return 60
        } else {
            return 40
        }
    }
    
    /*
    // to create swipe left to expose actions
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
    var removeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "remove", handler: {
    (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
    self.reviewTableView.setEditing(false, animated: true)
    })
    // if want to change background color and title color
    removeAction.backgroundColor = UIColor.clearColor()
    UIButton.appearance().setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
    
    // other possible ways to change action appearance
    //removeAction.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"XYZ_PNG"]];
    //or initWithPatternImage.....
    return []
    }*/
}
