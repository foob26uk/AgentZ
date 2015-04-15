//
//  DocumentsViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/29/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentInteractionControllerDelegate {
    
    // TODO
    // progress bar for uploading/downloading big file?
    // 10mB PFFile limit
    
    var docTableView: UITableView = UITableView()
    
    var transactionIndex: Int!
    
    var addPhotoButton: UIBarButtonItem!
    var addFileButton: UIBarButtonItem!
    
    var docs: [Document] = []
    var docObjects: [PFObject] = []

    var logVC: LogViewController!
    
    var loading: Bool = false
    var headerView: UIView!
    var setLoadMore: Bool = true
    
    override func viewWillAppear(animated: Bool) {
        //addPhotoButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: "addPhotoButton:")
        //self.tabBarController?.navigationItem.rightBarButtonItem = addPhotoButton
        
        addPhotoButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "addPhotoButton:")
        addFileButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addFileButton:")
        
        self.tabBarController?.navigationItem.rightBarButtonItems = [addPhotoButton, addFileButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 210/255, green: 203/255, blue: 177/255, alpha: 1.0)
        
        let tabBarHeight = self.tabBarController!.tabBar.bounds.height
        let navBarMaxY = self.navigationController!.navigationBar.frame.maxY
        docTableView.frame = CGRect(x: 10, y: navBarMaxY, width: tableViewWidth, height: screenHeight - tabBarHeight - navBarMaxY)
        
        docTableView.dataSource = self
        docTableView.delegate = self
        
        docTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        docTableView.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(docTableView)
        
        let headerHeight = CGFloat(47)
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableViewWidth, height: headerHeight))
        headerView.backgroundColor = UIColor.clearColor()
        
        var headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableViewWidth - 20, height: headerHeight))
        headerLabel.text = "Load More Documents"
        headerLabel.font = UIFont.boldSystemFontOfSize(17)
        headerLabel.textAlignment = NSTextAlignment.Center
        headerView.addSubview(headerLabel) // there is also insertSubview that animates differently
        
        headerView.userInteractionEnabled = true
        let headerViewTapped = UITapGestureRecognizer(target: self, action: "loadMoreDocumentsFromOnline:")
        headerView.addGestureRecognizer(headerViewTapped)
        
        if setLoadMore {
            docTableView.tableFooterView = headerView
        } else {
            docTableView.tableFooterView = nil
        }
    }
    
    func loadMoreDocumentsFromOnline(sender: AnyObject) {
        if !loading {
            loading = true
            var findParseDocuments: PFQuery = PFQuery(className: "Document")
            findParseDocuments.whereKey("transaction", equalTo: PFTransactions[transactionIndex])
            findParseDocuments.selectKeys(["name", "description", "thumbnail"])
            findParseDocuments.whereKey("deleted", notEqualTo: true)
            
            findParseDocuments.orderByDescending("createdAt")
            findParseDocuments.limit = 20
            findParseDocuments.skip = docs.count
            
            findParseDocuments.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                
                if error == nil {
                    for object in objects {
                        let _name = object.objectForKey("name") as! String
                        let _description = object.objectForKey("description") as! String
                        let _doc = Document(name: _name, description: _description)
                        let _thumbnail = object.objectForKey("thumbnail") as? PFFile
                        if let thumbnail = _thumbnail {
                            thumbnail.getDataInBackgroundWithBlock {
                                (tempData: NSData!, error: NSError!) -> Void in
                                if error == nil {
                                    _doc.thumbnail = UIImage(data: tempData)
                                } else {
                                    NSLog("%@", error)
                                }
                            }
                        }
                        self.docs.append(_doc)
                        self.docObjects.append(object as! PFObject)
                    }

                    if objects.count < findParseDocuments.limit {
                        self.docTableView.tableFooterView = nil
                    } else {
                        self.docTableView.tableFooterView = self.headerView
                    }
                    
                    if objects.count > 0 {
                        self.docTableView.reloadData()
                    }
                } else {
                    NSLog("%@", error)
                }
                self.loading = false
            }
        }
    }

    func logDocument(action: String, fileIndex: Int) {
        
        var PFLogEntry: PFObject = PFObject(className: "Log")
        
        PFLogEntry["document"] = docObjects[fileIndex]
        PFLogEntry["transaction"] = PFTransactions[transactionIndex]
        PFLogEntry["author"] = PFUser.currentUser()
        PFLogEntry["authorName"] = PFUser.currentUser().objectForKey("name")
        PFLogEntry["sectionName"] = "DOCUMENT"
        PFLogEntry["propertyName"] = docObjects[fileIndex].objectForKey("name")
        PFLogEntry["oldValue"] = action
        PFLogEntry["newValue"] = ""
        PFLogEntry["propertyType"] = ""
        
        PFLogEntry.saveEventually {
            (success: Bool, error: NSError!) -> Void in
            if success {
                let theLogEntry = LogEntry(
                    author: PFLogEntry["author"] as! PFUser,
                    authorName: PFLogEntry["authorName"] as! String,
                    createdAt: PFLogEntry.createdAt,
                    sectionName: PFLogEntry["sectionName"] as! String,
                    propertyName: PFLogEntry["propertyName"] as! String,
                    oldValue: PFLogEntry["oldValue"] as! String,
                    newValue: PFLogEntry["newValue"] as! String,
                    propertyType: PFLogEntry["propertyType"] as! String)
                
                self.logVC.log.insert(theLogEntry, atIndex: 0)
                self.logVC.logTableView.reloadData()
            }
        }

    }
    
    func addFileButton(sender: AnyObject) {
        if globalFile == nil {
            var failedOperationAlert: UIAlertController = UIAlertController(title: "Attach Fail", message: "Missing file attachment", preferredStyle: UIAlertControllerStyle.Alert)
            failedOperationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(failedOperationAlert, animated: true, completion: nil)
        } else {
            var descriptionAlert: UIAlertController = UIAlertController(title: globalFile.name, message: "Please enter description", preferredStyle: UIAlertControllerStyle.Alert)
            descriptionAlert.addTextFieldWithConfigurationHandler(nil)
            descriptionAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields: NSArray = descriptionAlert.textFields! as NSArray
                let descriptionTextfield: UITextField = textFields.objectAtIndex(0) as! UITextField
                self.addFile(descriptionTextfield.text)
                
            }))
            
            self.presentViewController(descriptionAlert, animated: true, completion: nil)
        }
    }

    func addFile(description: String) {
        var PFdoc = PFObject(className:"Document")
        PFdoc["uploadedBy"] = PFUser.currentUser()
        PFdoc["name"] = globalFile.name
        PFdoc["description"] = description
        PFdoc["file"] = globalFile
        PFdoc["transaction"] = PFTransactions[transactionIndex]
        PFdoc.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if success {
                var doc: Document = Document(
                    name: PFdoc["name"] as! String,
                    description: PFdoc["description"] as! String)
                
                globalFile.getDataInBackgroundWithBlock {
                    (data: NSData!, error: NSError!) -> Void in
                    if error == nil {
                        doc.fileData = data
                    } else {
                        NSLog("%@", error)
                    }
                }
                
                self.docs.insert(doc, atIndex: 0)
                self.docObjects.insert(PFdoc, atIndex: 0)
                self.logDocument("ADD", fileIndex: 0)
                self.docTableView.reloadData()
            } else {
                println("Panic: failed to attach file")
            }
            
            globalFile = nil
        }
    }
    
    func addPhotoButton(sender: AnyObject) {
        var imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera // another option is PhotoLibrary
        
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary) {
//        let pickedImage: UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let pickedImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        picker.dismissViewControllerAnimated(true, completion: nil)
        let scaledImage = scaleImageWith(pickedImage, and: CGSizeMake(60, 60))

        var imageData = UIImageJPEGRepresentation(pickedImage, 1.0)
        let thumbnail = UIImageJPEGRepresentation(scaledImage, 1.0)

        // PFFile cannot be more than 10 mB
        // limit 10485760 bytes
        var quality = CGFloat(0.9)
        while imageData.length > 10485760 && quality >= 0 {
            imageData = UIImageJPEGRepresentation(pickedImage, quality)
            quality -= 0.1
        }
        
        if quality >= 0 {
            
            var infoAlert: UIAlertController = UIAlertController(title: "Information Needed", message: "Please enter title and description", preferredStyle: UIAlertControllerStyle.Alert)
            infoAlert.addTextFieldWithConfigurationHandler {
                textfield in
                textfield.placeholder = "title"
            }
            infoAlert.addTextFieldWithConfigurationHandler {
                textfield in
                textfield.placeholder = "description"
            }
            infoAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields: NSArray = infoAlert.textFields! as NSArray
                let titleTextfield: UITextField = textFields.objectAtIndex(0) as! UITextField
                let descriptionTextfield: UITextField = textFields.objectAtIndex(1) as! UITextField
                
                let imageFile: PFFile = PFFile(name: titleTextfield.text + ".jpg", data: imageData)
                let thumbnailFile: PFFile = PFFile(name: titleTextfield.text + "Thumbnail.jpg", data: thumbnail)
                
                var PFdoc = PFObject(className:"Document")
                PFdoc["uploadedBy"] = PFUser.currentUser()
                PFdoc["name"] = titleTextfield.text + ".jpg"
                PFdoc["description"] = descriptionTextfield.text
                PFdoc["file"] = imageFile
                PFdoc["thumbnail"] = thumbnailFile
                PFdoc["transaction"] = PFTransactions[self.transactionIndex]
                PFdoc.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
                    if success {
                        var doc: Document = Document(
                            name: PFdoc["name"] as! String,
                            description: PFdoc["description"] as! String)
                        doc.thumbnail = scaledImage
                        doc.fileData = imageData
                        
                        self.docs.insert(doc, atIndex: 0)
                        self.docObjects.insert(PFdoc, atIndex: 0)
                         self.logDocument("ADD", fileIndex: 0)
                        self.docTableView.reloadData()
                    } else {
                        NSLog("%@", error)
                    }
                }
            }))
            
            self.presentViewController(infoAlert, animated: true, completion: nil)
        }
    }
    
    func scaleImageWith(image:UIImage, and newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docs.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var doc = docs[indexPath.row]
        if doc.fileData == nil {
            docObjects[indexPath.row].fetchIfNeededInBackgroundWithBlock {
                (docObject: PFObject!, error: NSError!) -> Void in
                if error == nil {
                    (docObject.objectForKey("file") as! PFFile).getDataInBackgroundWithBlock {
                        (tempData: NSData!, error: NSError!) -> Void in
                        if error == nil {
                            doc.fileData = tempData
                            self.previewDoc(doc)
                        } else {
                            NSLog("%@", error)
                        }
                    }
                } else {
                    NSLog("%@", error)
                }
            }
        } else { // fileData not nil, don't have to download file
            previewDoc(doc)
        }
    }
    
    func previewDoc(doc: Document) {
        let tempFileName = NSTemporaryDirectory().stringByAppendingPathComponent(doc.name)
        let tempURL: NSURL! = NSURL(fileURLWithPath: tempFileName)
        doc.fileData?.writeToURL(tempURL, atomically: true)
        if tempURL != nil {
            let docController = UIDocumentInteractionController(URL: tempURL)
            if doc.name.pathExtension == "pdf" {
                docController.UTI = "com.adobe.pdf"
            }
            docController.delegate = self
            docController.presentPreviewAnimated(true)
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self.navigationController!
    }
    
    /* Doug doesn't want "deletable" documents
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            docObjects[indexPath.row]["deleted"] = true // don't actually delete the file, just mark it as deleted
            docObjects[indexPath.row].saveInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if success {
                    self.logDocument("REMOVE", fileIndex: indexPath.row)
                    self.docs.removeAtIndex(indexPath.row)
                    self.docObjects.removeAtIndex(indexPath.row)
                    self.docTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        }
    }*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = docTableView.dequeueReusableCellWithIdentifier("DocumentCell") as? DocumentCell
        if cell == nil {cell = DocumentCell()}
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! DocumentCell
        var doc = docs[indexPath.row]
        
        cell.nameLabel.text = doc.name
        cell.descriptionLabel.text = doc.description
        
        if doc.thumbnail != nil {
            cell.thumbnail.image = doc.thumbnail
        } else if doc.name.pathExtension == "pdf" {
            cell.thumbnail.image = UIImage(named: "pdficon")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
}