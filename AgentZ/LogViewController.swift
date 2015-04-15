//
//  LogViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 2/1/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // TODO
    // memoization for dynamic label height?
    
    var logTableView: UITableView = UITableView()
    
    var transactionIndex: Int!
    var log: [LogEntry] = []
    
    var loading: Bool = false
    var headerView: UIView!
    var setLoadMore: Bool = true
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItems = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 210/255, green: 203/255, blue: 177/255, alpha: 1.0)
        
        let tabBarHeight = self.tabBarController!.tabBar.bounds.height
        let navBarMaxY = self.navigationController!.navigationBar.frame.maxY
        logTableView.frame = CGRect(x: 10, y: navBarMaxY, width: tableViewWidth, height: screenHeight - tabBarHeight - navBarMaxY)
        
        logTableView.dataSource = self
        logTableView.delegate = self
        
        logTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        logTableView.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(logTableView)
        
        let headerHeight = CGFloat(47)
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableViewWidth, height: headerHeight))
        headerView.backgroundColor = UIColor.clearColor()
        
        var headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableViewWidth - 20, height: headerHeight))
        headerLabel.text = "Load More Log Entries"
        headerLabel.font = UIFont.boldSystemFontOfSize(17)
        headerLabel.textAlignment = NSTextAlignment.Center
        headerView.addSubview(headerLabel) // there is also insertSubview that animates differently
        
        headerView.userInteractionEnabled = true
        let headerViewTapped = UITapGestureRecognizer(target: self, action: "loadMoreLogFromOnline:")
        headerView.addGestureRecognizer(headerViewTapped)
        
        if setLoadMore {
            logTableView.tableFooterView = headerView
        } else {
            logTableView.tableFooterView = nil
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return log.count
    }
    
    let labelHeight = CGFloat(20)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = logTableView.dequeueReusableCellWithIdentifier("LogCell") as? LogCell
        if cell == nil {cell = LogCell()}

        let entry = log[indexPath.row]
        
        cell!.authorLabel.text = "\(entry.authorName)"

        var dataFormatter: NSDateFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        cell!.createdAtLabel.text = dataFormatter.stringFromDate(entry.createdAt)
        
        cell!.addressLabel.text = "\(entry.sectionName)➢\(entry.propertyName)"
        cell!.dataLabel.text = "\(entry.oldValue) ➡︎ \(entry.newValue)"
        
        cell!.authorLabel.frame = CGRectMake(10, 10, tableViewWidth / 2 - 10, labelHeight)
        cell!.createdAtLabel.frame = CGRectMake(tableViewWidth / 2, 10, tableViewWidth / 2 - 10, labelHeight)
        cell!.addressLabel.frame = CGRectMake(10, cell!.authorLabel.frame.maxY, tableViewWidth - 20, labelHeight)
        
        let frameWidth = findHeight("\(entry.oldValue) ➡︎ \(entry.newValue)", font: UIFont.systemFontOfSize(15))
        let dataLabelHeight = ceil(frameWidth / (tableViewWidth - 20)) * labelHeight
        
        cell!.dataLabel.frame = CGRectMake(10, cell!.addressLabel.frame.maxY, tableViewWidth - 20, dataLabelHeight)
        cell!.cellView.frame = CGRectMake(0, 0, tableViewWidth, cell!.dataLabel.frame.maxY + 10)
        
        return cell!
    }
    
    func findHeight(text: String, font: UIFont) -> CGFloat {
        var someLabel = UILabel()
        someLabel.text = text
        someLabel.font = font
        someLabel.sizeToFit()
        return someLabel.frame.width
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let entry = log[indexPath.row]
        let frameWidth = findHeight("\(entry.oldValue)➔\(entry.newValue)", font: UIFont.systemFontOfSize(15))
        let dataLabelHeight = ceil(frameWidth / (tableViewWidth - 20)) * labelHeight
        return dataLabelHeight + 70
    }
    
    func loadMoreLogFromOnline(sender: AnyObject) {
        if !loading {
            loading = true
            var findParseLog: PFQuery = PFQuery(className: "Log")
            findParseLog.whereKey("transaction", equalTo: PFTransactions[transactionIndex])
            
            findParseLog.orderByDescending("createdAt")
            findParseLog.limit = 20
            findParseLog.skip = log.count
            
            findParseLog.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                
                if error == nil {
                    for object in objects {
                        let theLogEntry = LogEntry(
                            author: object.objectForKey("author") as PFUser,
                            authorName: object.objectForKey("authorName") as String,
                            createdAt: object.createdAt,
                            sectionName: object.objectForKey("sectionName") as String,
                            propertyName: object.objectForKey("propertyName") as String,
                            oldValue: object.objectForKey("oldValue") as String,
                            newValue: object.objectForKey("newValue") as String,
                            propertyType: object.objectForKey("propertyType") as String)
                        
                        self.log.append(theLogEntry)
                    }

                    if objects.count < findParseLog.limit {
                        self.logTableView.tableFooterView = nil
                    } else {
                        self.logTableView.tableFooterView = self.headerView
                    }
                    
                    if objects.count > 0 {
                        self.logTableView.reloadData()
                    }
                } else {
                    NSLog("%@", error)
                }
                self.loading = false
            }
        }
    }
}
