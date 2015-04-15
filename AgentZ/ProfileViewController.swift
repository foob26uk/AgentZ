//
//  ProfileViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/25/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

var transactions: [Transaction] = []
var PFTransactions: [PFObject] = []
var agent: Agent = Agent()

var tableViewWidth = screenWidth - 20

var navBarMaxY: CGFloat!

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // Future TODO: financial information, like release of commission payment to agent, should be in agent profile
    
    var nameLabel: UILabel!
    var agentImageView: UIImageView!
    
    var profileTableView: UITableView = UITableView()
    var tabBarHeight: CGFloat!
    
    var rowMostRecentlyTapped: Int!
    
    override func viewWillAppear(animated: Bool) {
        let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButton:")
        self.tabBarController?.navigationItem.leftBarButtonItem = logoutButton
        
        if agent.title == "agent" {
            self.tabBarController?.navigationItem.rightBarButtonItem = nil
        } else {
            let brokerButton = UIBarButtonItem(title: "Broker", style: UIBarButtonItemStyle.Plain, target: self, action: "brokerButton:")
            self.tabBarController?.navigationItem.rightBarButtonItem = brokerButton
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        profileTableView.reloadData()
        
        if agent.profileImage != nil {
            let image: UIImage = UIImage(data: agent.profileImage!)!
            self.agentImageView.image = image
        } else if let agentProfileImage: PFFile = PFUser.currentUser()["profileImage"] as? PFFile {
            agentProfileImage.getDataInBackgroundWithBlock {
                (imageData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    agent.profileImage = imageData
                    let image: UIImage = UIImage(data: imageData)!
                    self.agentImageView.image = image
                } else {
                    println("No image found!")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarMaxY = self.navigationController!.navigationBar.frame.maxY
        
        agentImageView = UIImageView(frame: CGRectMake(20, navBarMaxY + 20, 100, 100))
        nameLabel = UILabel(frame: CGRectMake(agentImageView.frame.maxX + 20, navBarMaxY + 40, screenWidth - agentImageView.frame.width - 60 , 60))
        nameLabel.font = UIFont.boldSystemFontOfSize(21)
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.numberOfLines = 2

        self.view.addSubview(agentImageView)
        self.view.addSubview(nameLabel)
        
        tabBarHeight = self.tabBarController!.tabBar.bounds.height
        profileTableView.frame = CGRect(x: 20, y: agentImageView.frame.maxY + 20, width: tableViewWidth - 20, height: screenHeight - tabBarHeight - navBarMaxY - agentImageView.frame.height - 40)
        
        profileTableView.dataSource = self
        profileTableView.delegate = self
        
        profileTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        profileTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(profileTableView)
        
        self.view.backgroundColor = UIColor(red: 226/255, green: 232/255, blue: 202/255, alpha: 1.0)

        if agent.name == "" {
            agent.name = PFUser.currentUser().objectForKey("name") as String
            agent.title = PFUser.currentUser().objectForKey("title") as String
            nameLabel.text = agent.name
            
            for index in 0..<agent.properties.count {
                let value = PFUser.currentUser().objectForKey(agent.properties[index][0]) as? String
                if let _value = value {
                    agent.properties[index][1] = _value
                }
            }
        }
        
        agentImageView.layer.borderWidth = 1
        agentImageView.userInteractionEnabled = true
        let agentImageViewTapped = UITapGestureRecognizer(target: self, action: "changeAgentImage:")
        agentImageView.addGestureRecognizer(agentImageViewTapped)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agent.properties.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = profileTableView.dequeueReusableCellWithIdentifier("ProfileCell") as? ProfileCell
        if cell == nil {cell = ProfileCell()}
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: ProfileCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let property = agent.properties[indexPath.row]
        
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
        let property = agent.properties[indexPath.row]

        if property[2] == "ADDRESS" {
            return 71
        } else {
            return 50.5
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rowMostRecentlyTapped = indexPath.row
        self.performSegueWithIdentifier("gotoUpdateProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoUpdateProfile" {
            let vc = segue.destinationViewController as UpdateProfileViewController
            vc.propertyIndex = rowMostRecentlyTapped
        }
    }
    
    // next three functions just for selecting agent profile image from photo library on phone
    func changeAgentImage(sender: UITapGestureRecognizer) {
        var imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary // could have picked camera as source
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary) {
        let pickedImage: UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        let scaledImage = self.scaleImageWith(pickedImage, and: CGSizeMake(100, 100))
        let imageData = UIImagePNGRepresentation(scaledImage)
        let imageFile: PFFile = PFFile(name: "profileImage.png", data: imageData) // could name the file when creating it too
        
        //Same as line below: PFUser.currentUser().setObject(imageFile, forKey: "profileImage")
        PFUser.currentUser()["profileImage"] = imageFile

        PFUser.currentUser().saveInBackground() // can't use saveEventually when there is imageFile attached to it I think
        
        agent.profileImage = imageData
        picker.dismissViewControllerAnimated(true, completion: nil) // dismisses the imagePickerController
    }
    
    func scaleImageWith(image:UIImage, and newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    func brokerButton(sender: AnyObject) {
        self.performSegueWithIdentifier("gotoBroker", sender: self)
    }
    
    func logoutButton(sender: AnyObject) {
        transactions = []
        PFTransactions = []
        agent = Agent()
        
        PFUser.logOut()
        navigationController?.popViewControllerAnimated(true)
    }
}
