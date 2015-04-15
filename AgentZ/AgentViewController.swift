//
//  AgentViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/28/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class AgentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    var agentTableView = UITableView()
    var tabBarHeight: CGFloat!
    var agents: [PFUser] = []
    var addButton: UIBarButtonItem!
    var agentSearchController = UISearchController()
    var searchArray: [PFUser] = [PFUser](){
        didSet {agentTableView.reloadData()}
    }
    
    var rowLastTapped = -1
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 226/255, green: 233/255, blue: 226/255, alpha: 1.0)
        
        tabBarHeight = self.tabBarController!.tabBar.bounds.height
        agentTableView.frame = CGRect(x: 20, y: navBarMaxY, width: tableViewWidth - 20, height: screenHeight - tabBarHeight - navBarMaxY)
        
        agentTableView.dataSource = self
        agentTableView.delegate = self
        
        agentTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        agentTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(agentTableView)
        
        loadAgentsFromOnline()
        
        agentSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.sizeToFit()
            self.agentTableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
    }
    
    func loadAgentsFromOnline() {
        var findAgents: PFQuery = PFUser.query()
        findAgents.orderByDescending("createdAt") // sorts it
        //findAgents.limit = ??? (default = 100)
        
        findAgents.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.agents = objects as! [PFUser]
                self.agentTableView.reloadData()
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchArray = agents.filter {
            (agent: PFUser) -> Bool in
            let name = agent.objectForKey("name") as! String
            let title = agent.objectForKey("title") as! String
            if name.rangeOfString(self.agentSearchController.searchBar.text, options: NSStringCompareOptions.RegularExpressionSearch) != nil || title.rangeOfString(self.agentSearchController.searchBar.text, options: NSStringCompareOptions.RegularExpressionSearch) != nil {
                return true
            }
            return false
        }
    }
    
    func addButton(sender: AnyObject) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoAgentProfile" {
            let vc = segue.destinationViewController as! AgentProfileViewController
            
            var _agent: PFUser!
            if agentSearchController.active {
                _agent = searchArray[rowLastTapped]
            } else {
                _agent = agents[rowLastTapped]
            }
        
            var user = Agent()
            user.name = _agent.objectForKey("name") as! String
            user.title = _agent.objectForKey("title") as! String
            
            if let _imageFile = _agent.objectForKey("profileImage") as? PFFile {
                _imageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData!, error: NSError!) -> Void in
                    
                    if error == nil {
                        user.profileImage = imageData
                    } else {
                        NSLog("%@", error)
                    }
                }
            }
        
            for index in 0..<user.properties.count {
                let value = _agent.objectForKey(agent.properties[index][0]) as? String
                if let _value = value {
                    user.properties[index][1] = _value
                }
            }

            vc.user = user
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        agentTableView.deselectRowAtIndexPath(indexPath, animated: true)

        rowLastTapped = indexPath.row
        
        self.performSegueWithIdentifier("gotoAgentProfile", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if agentSearchController.active {
            return searchArray.count
        } else {
            return agents.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = agentTableView.dequeueReusableCellWithIdentifier("AgentCell") as? AgentCell
        if cell == nil {cell = AgentCell()}
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! AgentCell
        var agent: PFUser!
        if agentSearchController.active {
            agent = searchArray[indexPath.row]
        } else {
            agent = agents[indexPath.row]
        }
        cell.nameLabel.text = (agent.objectForKey("name") as! String)
        cell.titleLabel.text = (agent.objectForKey("title") as! String)
        cell.emailLabel.text = (agent.objectForKey("email") as! String)
        cell.phoneLabel.text = Agent.getFormattedPhone(agent.objectForKey("phone") as! String)
        
        let labelHeight = CGFloat(20)
        let tableWidth = agentTableView.frame.width
        cell.titleLabel.sizeToFit()
        cell.titleLabel.frame = CGRectMake(tableWidth - cell.titleLabel.frame.width, 0, cell.titleLabel.frame.width, labelHeight)
        cell.nameLabel.frame = CGRectMake(0, 0, tableWidth - cell.titleLabel.frame.width, labelHeight)
        cell.emailLabel.frame = CGRectMake(0, cell.nameLabel.frame.maxY, tableWidth, labelHeight)
        cell.phoneLabel.frame = CGRectMake(0, cell.emailLabel.frame.maxY, tableWidth, labelHeight)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
}
