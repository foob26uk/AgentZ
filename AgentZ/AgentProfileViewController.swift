//
//  AgentProfileViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 3/31/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class AgentProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user: Agent!
    
    var nameLabel: UILabel!
    var userImageView: UIImageView!
    
    var profileTableView: UITableView = UITableView()

    override func viewDidAppear(animated: Bool) {
        if let _profileImage = user.profileImage {
            userImageView.image = UIImage(data: _profileImage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBarMaxY = self.navigationController!.navigationBar.frame.maxY
        
        userImageView = UIImageView(frame: CGRectMake(20, navBarMaxY + 20, 100, 100))
        nameLabel = UILabel(frame: CGRectMake(userImageView.frame.maxX + 20, navBarMaxY + 40, screenWidth - userImageView.frame.width - 60 , 60))

        nameLabel.text = user.name
        
        nameLabel.font = UIFont.boldSystemFontOfSize(21)
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.numberOfLines = 2
        
        self.view.addSubview(userImageView)
        self.view.addSubview(nameLabel)
        
        profileTableView.frame = CGRect(x: 20, y: userImageView.frame.maxY + 20, width: tableViewWidth - 20, height: screenHeight - navBarMaxY - userImageView.frame.height - 40)
        
        profileTableView.dataSource = self
        profileTableView.delegate = self
        
        profileTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        profileTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(profileTableView)
        
        self.view.backgroundColor = UIColor(red: 226/255, green: 233/255, blue: 226/255, alpha: 1.0)
        
        userImageView.layer.borderWidth = 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.properties.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = profileTableView.dequeueReusableCellWithIdentifier("ProfileCell") as? ProfileCell
        if cell == nil {cell = ProfileCell()}
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: ProfileCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let property = user.properties[indexPath.row]
        
        let tableWidth = profileTableView.frame.width
        
        cell.keyLabel.text = property[0]
        cell.keyLabel.frame = CGRectMake(0, 0, tableWidth, 20)
        
        cell.valueLabel.numberOfLines = 1
        if property[2] == "STANDARD" {
            cell.valueLabel.text = property[1]
            cell.valueLabel.frame = CGRectMake(0, cell.keyLabel.frame.maxY, tableWidth, 20.5)
        } else if property[2] == "ADDRESS" {
            cell.valueLabel.numberOfLines = 2
            cell.valueLabel.text = Agent.getFormattedAddress(property[1])
            cell.valueLabel.frame = CGRectMake(0, cell.keyLabel.frame.maxY, tableWidth, 41)
        } else if property[2] == "PHONE" {
            cell.valueLabel.text = Agent.getFormattedPhone(property[1])
            cell.valueLabel.frame = CGRectMake(0, cell.keyLabel.frame.maxY, tableWidth, 20.5)
        } else {
            cell.valueLabel.text = property[1]
            cell.valueLabel.frame = CGRectMake(0, cell.keyLabel.frame.maxY, tableWidth, 20.5)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let property = user.properties[indexPath.row]
        
        if property[2] == "ADDRESS" {
            return 71
        } else {
            return 50.5
        }
    }
}
