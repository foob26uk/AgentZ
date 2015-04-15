//
//  ListTransactionsViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/27/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class ListTransactionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // TODO
    // for new transactions, make deletable (ios option?) and submittable to broker (make rows able to pan left/right to reveal options)
    // filter by status, search bar too
    // add more info: waiting for broker followup, agent followup required
    // refresh control, and obtain more transactions than the transaction limit of 20 when scrolling

    // WHAT IF no online connection, make new transaction, then refresh or load more transactions? What happens then?
    //retest it again

    var rowMostRecentlyTapped: Int = -1
    var loading: Bool = false
    var headerView: UIView!
    
    var listTableView: UITableView = UITableView()
    
    var refreshControl = UIRefreshControl()

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        listTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 226/255, green: 232/255, blue: 202/255, alpha: 1.0)
        
        let tabBarHeight = self.tabBarController!.tabBar.bounds.height
        let statusBarHeight = CGFloat(20)
        listTableView.frame = CGRect(x: 10, y: statusBarHeight, width: tableViewWidth, height: screenHeight - tabBarHeight - statusBarHeight)
        
        listTableView.dataSource = self
        listTableView.delegate = self
        
        listTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        listTableView.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(listTableView)
        
        //refreshControl.tintColor = UIColor.clearColor() // makes standard spinner invisible
        refreshControl.addTarget(self, action: "loadTransactionsFromOnline:", forControlEvents: UIControlEvents.ValueChanged)
        listTableView.addSubview(refreshControl)
        
        let headerHeight = CGFloat(47)
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableViewWidth, height: headerHeight))
        headerView.backgroundColor = UIColor.clearColor()
        
        var headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableViewWidth - 10, height: headerHeight))
        headerLabel.text = "Load More Transactions"
        headerLabel.font = UIFont.boldSystemFontOfSize(17)
        headerLabel.textAlignment = NSTextAlignment.Center
        headerView.addSubview(headerLabel) // there is also insertSubview that animates differently
        
        headerView.userInteractionEnabled = true
        let headerViewTapped = UITapGestureRecognizer(target: self, action: "loadMoreTransactionsFromOnline:")
        headerView.addGestureRecognizer(headerViewTapped)

        listTableView.tableFooterView = headerView
    }
    
    func loadTransactionsFromOnline(sender: AnyObject) {
        if !loading {
            loading = true
            var findParseTransactions: PFQuery = PFQuery(className: "Transaction")
            if agent.title == "agent" {
                findParseTransactions.whereKey("agent", equalTo: PFUser.currentUser())
            }
            
            findParseTransactions.orderByDescending("createdAt") // sorts it
            findParseTransactions.limit = 20
            
            findParseTransactions.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    transactions = []
                    PFTransactions = []
                    
                    for object in objects {
                        var onlineTransaction = Transaction()
                        onlineTransaction.transactionCount = object.objectForKey("count") as Int
                        onlineTransaction.transactionID = object.objectId as String
                        onlineTransaction.properties = object.objectForKey("properties") as [[[String]]]
                        onlineTransaction.status = object.objectForKey("status") as String
                        onlineTransaction.agentFollowupRequired = object.objectForKey("agentFollowupRequired") as Bool
                        onlineTransaction.brokerFollowupRequired = object.objectForKey("brokerFollowupRequired") as Bool
                        onlineTransaction.agent = object.objectForKey("agent") as PFUser
                        onlineTransaction.agentName = object.objectForKey("agentName") as String
                        onlineTransaction.creationDate = object.createdAt

                        transactions.append(onlineTransaction)
                        PFTransactions.append(object as PFObject)
                    }

                    if objects.count < findParseTransactions.limit {
                        self.listTableView.tableFooterView = nil
                    } else {
                        self.listTableView.tableFooterView = self.headerView
                    }

                    if objects.count > 0 {
                        self.listTableView.reloadData()
                    }
                }
                self.refreshControl.endRefreshing()
                self.loading = false
            }
        }
    }
    
    func loadMoreTransactionsFromOnline(sender: AnyObject) {
        if !loading {
            loading = true
            var findParseTransactions: PFQuery = PFQuery(className: "Transaction")
            if agent.title == "agent" {
                findParseTransactions.whereKey("agent", equalTo: PFUser.currentUser())
            }
            
            findParseTransactions.orderByDescending("createdAt") // sorts it
            findParseTransactions.limit = 20
            findParseTransactions.skip = PFTransactions.count
            
            findParseTransactions.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    for object in objects {
                        var onlineTransaction = Transaction()
                        onlineTransaction.transactionCount = object.objectForKey("count") as Int
                        onlineTransaction.transactionID = object.objectId as String
                        onlineTransaction.properties = object.objectForKey("properties") as [[[String]]]
                        onlineTransaction.status = object.objectForKey("status") as String
                        onlineTransaction.agentFollowupRequired = object.objectForKey("agentFollowupRequired") as Bool
                        onlineTransaction.brokerFollowupRequired = object.objectForKey("brokerFollowupRequired") as Bool
                        onlineTransaction.agent = object.objectForKey("agent") as PFUser
                        onlineTransaction.agentName = object.objectForKey("agentName") as String
                        onlineTransaction.creationDate = object.createdAt
                        
                        transactions.append(onlineTransaction)
                        PFTransactions.append(object as PFObject)
                    }
                    
                    if objects.count < findParseTransactions.limit {
                        self.listTableView.tableFooterView = nil
                    } else {
                        self.listTableView.tableFooterView = self.headerView
                    }
                    
                    if objects.count > 0 {
                        self.listTableView.reloadData()
                    }
                }
                self.loading = false
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if agent.title == "agent" {
            return 70
        } else {
            return 110
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if agent.title == "agent" {
            var cell = listTableView.dequeueReusableCellWithIdentifier("ListTransactionsCell") as? ListTransactionsCell
            if cell == nil {cell = ListTransactionsCell()}
        
            return cell!
        } else {
            var cell = listTableView.dequeueReusableCellWithIdentifier("ListTransactionsBrokerCell") as? ListTransactionsBrokerCell
            if cell == nil {cell = ListTransactionsBrokerCell()}
        
            return cell!
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let transaction = transactions[indexPath.row]

        if agent.title == "agent" {
            let _cell = cell as ListTransactionsCell

            _cell.addressLabel.text = transaction.getFormattedAddress()
            
            var dataFormatter: NSDateFormatter = NSDateFormatter()
            dataFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            _cell.dateLabel.text = dataFormatter.stringFromDate(transaction.creationDate)
            
            if transaction.brokerFollowupRequired {
                _cell.brokerFollowupLabel.text = " B "
            } else {
                _cell.brokerFollowupLabel.text = ""
            }

            if transaction.agentFollowupRequired {
                _cell.agentFollowupLabel.text = " A "
            } else {
                _cell.agentFollowupLabel.text = ""
            }

            _cell.agentFollowupLabel.sizeToFit()
            _cell.agentFollowupLabel.frame = CGRectMake(tableViewWidth - 30, 30, _cell.agentFollowupLabel.frame.width, 20)
            
            _cell.brokerFollowupLabel.sizeToFit()
            if _cell.agentFollowupLabel.text == "" {
                _cell.brokerFollowupLabel.frame = CGRectMake(tableViewWidth - 30, 30, _cell.brokerFollowupLabel.frame.width, 20)
            } else {
                _cell.brokerFollowupLabel.frame = CGRectMake(tableViewWidth - _cell.agentFollowupLabel.frame.width - 30, 30, _cell.brokerFollowupLabel.frame.width, 20)
            }
            
            _cell.statusLabel.text = transaction.status
            _cell.statusLabel.sizeToFit()
            if _cell.agentFollowupLabel.text == "" && _cell.brokerFollowupLabel.text == "" {
                _cell.statusLabel.frame = CGRectMake(tableViewWidth - _cell.statusLabel.frame.width - 10, 30, _cell.statusLabel.frame.width, 20)
            } else {
                _cell.statusLabel.frame = CGRectMake(tableViewWidth - _cell.statusLabel.frame.width - _cell.agentFollowupLabel.frame.width - _cell.brokerFollowupLabel.frame.width - 20, 30, _cell.statusLabel.frame.width, 20)
            }
            
        } else {
            let _cell = cell as ListTransactionsBrokerCell

            _cell.addressLabel.text = transaction.getFormattedAddress()
            
            var dataFormatter: NSDateFormatter = NSDateFormatter()
            dataFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            _cell.dateLabel.text = dataFormatter.stringFromDate(transaction.creationDate)
            
            _cell.agentLabel.text = transaction.agentName
            _cell.reprLabel.text = transaction.getFormattedRepresentation()
            
            if transaction.brokerFollowupRequired {
                _cell.brokerFollowupLabel.text = " B "
            } else {
                _cell.brokerFollowupLabel.text = ""
            }
            
            if transaction.agentFollowupRequired {
                _cell.agentFollowupLabel.text = " A "
            } else {
                _cell.agentFollowupLabel.text = ""
            }
            
            _cell.agentFollowupLabel.sizeToFit()
            _cell.agentFollowupLabel.frame = CGRectMake(tableViewWidth - 30, 30, _cell.agentFollowupLabel.frame.width, 20)
            
            _cell.brokerFollowupLabel.sizeToFit()
            if _cell.agentFollowupLabel.text == "" {
                _cell.brokerFollowupLabel.frame = CGRectMake(tableViewWidth - 30, 30, _cell.brokerFollowupLabel.frame.width, 20)
            } else {
                _cell.brokerFollowupLabel.frame = CGRectMake(tableViewWidth - _cell.agentFollowupLabel.frame.width - 30, 30, _cell.brokerFollowupLabel.frame.width, 20)
            }
            
            _cell.statusLabel.text = transaction.status
            _cell.statusLabel.sizeToFit()
            if _cell.agentFollowupLabel.text == "" && _cell.brokerFollowupLabel.text == "" {
                _cell.statusLabel.frame = CGRectMake(tableViewWidth - _cell.statusLabel.frame.width - 10, 30, _cell.statusLabel.frame.width, 20)
            } else {
                _cell.statusLabel.frame = CGRectMake(tableViewWidth - _cell.statusLabel.frame.width - _cell.agentFollowupLabel.frame.width - _cell.brokerFollowupLabel.frame.width - 20, 30, _cell.statusLabel.frame.width, 20)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if loading == false {
            rowMostRecentlyTapped = indexPath.row
            self.performSegueWithIdentifier("gotoDetails", sender: self)
        }
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoDetails" {
            let tb = segue.destinationViewController as UITabBarController
            if let vcArray = tb.viewControllers {
                let vc = vcArray[0] as DetailsViewController
                //tb.delegate = vc
                vc.transactionIndex = rowMostRecentlyTapped
                vc.transactionUpdated = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
