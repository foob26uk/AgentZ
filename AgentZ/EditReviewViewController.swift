//
//  EditReviewViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/30/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

protocol EditReviewDelegate {
    func insertRequirementAtIndex(requirement: PFObject, idx: Int)
    func removeRequirementAtIndex(idx: Int)
}

class EditReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var editTableView = UITableView()
    
    var transactionIndex: Int!
    var transactionRequirements: [PFObject]!
    var requirements: [PFObject] = []
    var requirementsSelected: [Bool] = []
    
    var delegate: EditReviewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 226/255, green: 233/255, blue: 226/255, alpha: 1.0)
        
        editTableView.frame = CGRect(x: 20, y: navBarMaxY, width: tableViewWidth - 20, height: screenHeight - navBarMaxY)
                
        editTableView.dataSource = self
        editTableView.delegate = self

        editTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        editTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(editTableView)
        
        loadReqsFromOnline()
    }

    func findSelectedRequirements() {
        // transactionRequirements and requirements are sorted, could do binary search
        
        var rDict = [String: PFObject]()
        for req in transactionRequirements {
            let key: String = (req.objectForKey("requirement") as! PFObject).objectId as String
            rDict[key] = req
        }
        
        for (idx, req) in enumerate(requirements) {
            let key: String = req.objectId as String
            if rDict[key] != nil {
                requirementsSelected[idx ] = true
            }
        }
    }
    
    func loadReqsFromOnline() {
        var findRequirements: PFQuery = PFQuery(className: "Requirement")
        
        findRequirements.orderByAscending("text")
        findRequirements.limit = 100 // default
        
        findRequirements.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.requirements = objects as! [PFObject]
                self.requirementsSelected = [Bool](count: objects.count, repeatedValue: false)
                self.editTableView.reloadData()
                self.findSelectedRequirements()
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if requirementsSelected[indexPath.row] {
            // removing
            var idx: Int!
            for (i, req) in enumerate(transactionRequirements) {
                if (req.objectForKey("requirement") as! PFObject).objectId == requirements[indexPath.row].objectId {
                    idx = i
                    break
                }
            }
            if idx != nil {
                transactionRequirements[idx].deleteInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
                    if success {
                        self.delegate?.removeRequirementAtIndex(idx)
                        self.transactionRequirements.removeAtIndex(idx)
                        self.requirementsSelected[indexPath.row] = false
                        self.editTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    } else {
                        NSLog("%@", error)
                    }
                }
            }
        } else {
            // adding
            var newRequirement: PFObject = PFObject(className: "Review")
            newRequirement["transaction"] = PFTransactions[transactionIndex]
            newRequirement["requirement"] = requirements[indexPath.row]
            newRequirement["text"] = requirements[indexPath.row].objectForKey("text")
            newRequirement["agentFlag"] = true
            newRequirement["brokerFlag"] = false
            newRequirement["comment"] = ""

            newRequirement.saveInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if success {
                    var idx: Int = 0
                    let text = newRequirement.objectForKey("text") as! String
                    while idx < self.transactionRequirements.count {
                        if text < (self.transactionRequirements[idx].objectForKey("text") as! String) {
                            break
                        }
                        idx++
                    }
                    self.delegate?.insertRequirementAtIndex(newRequirement, idx: idx)
                    self.transactionRequirements.insert(newRequirement, atIndex: idx)
                    self.requirementsSelected[indexPath.row] = true
                    self.editTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                } else {
                    NSLog("%@", error)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requirements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = editTableView.dequeueReusableCellWithIdentifier("UITableViewCell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "UITableViewCell")
            cell?.backgroundColor = UIColor.clearColor()
            cell?.textLabel?.backgroundColor = UIColor.clearColor()
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel!.text = (requirements[indexPath.row].objectForKey("text") as! String)
        
        if requirementsSelected[indexPath.row] {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
    }
}
