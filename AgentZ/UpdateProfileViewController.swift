//
//  UpdateProfileViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/25/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

class UpdateProfileViewController: UIViewController {

    var propertyIndex: Int! // row that was tapped in ProfileViewController
    var propertyType: String!
    var propertyName: String!
    
    var valueTextField: fooTextField!
    var passwordTextField: fooTextField!
    
    var streetTextField: fooTextField!
    var cityTextField: fooTextField!
    var stateTextField: UITextField!
    var zipTextField: UITextField!
    
    var newPasswordTextField: fooTextField!
    var reenterPasswordTextField: fooTextField!
    
    override func viewWillAppear(animated: Bool) {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButton:")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveButton:")
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.navigationItem.title = "Edit"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 226/255, green: 232/255, blue: 202/255, alpha: 1.0)
        
        let property = agent.properties[propertyIndex]
        propertyName = property[0]
        propertyType = property[2]
        
        let margin = CGFloat(20)
        let textFieldHeight = CGFloat(40)
        let fieldWidth = screenWidth - 40
        
        if propertyType != "ADDRESS" && propertyType != "PASSWORD" {
            valueTextField = fooTextField(frame: CGRectMake(margin, navBarMaxY + margin, fieldWidth, textFieldHeight))
            valueTextField.placeholder = propertyName
            valueTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
            valueTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            valueTextField.text = property[1]
            
            valueTextField.autocapitalizationType = UITextAutocapitalizationType.None
            valueTextField.autocorrectionType = UITextAutocorrectionType.No
            valueTextField.spellCheckingType = UITextSpellCheckingType.No

            self.view.addSubview(valueTextField)
            
            passwordTextField = fooTextField(frame: CGRectMake(margin, valueTextField.frame.maxY + 2, fieldWidth, textFieldHeight))
            passwordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            passwordTextField.placeholder = "password"
            passwordTextField.secureTextEntry = true
            passwordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
            self.view.addSubview(passwordTextField)
        }

        
        if propertyType == "ADDRESS" {
            let stateWidth = CGFloat(40)
            let zipWidth = CGFloat(60)
            streetTextField = fooTextField(frame: CGRectMake(margin, navBarMaxY + margin, fieldWidth, textFieldHeight))
            cityTextField = fooTextField(frame: CGRectMake(margin, streetTextField.frame.maxY, fieldWidth - stateWidth - zipWidth, textFieldHeight))
            stateTextField = UITextField(frame: CGRectMake(cityTextField.frame.width + margin, streetTextField.frame.maxY, stateWidth, textFieldHeight))
            zipTextField = UITextField(frame: CGRectMake(cityTextField.frame.width + stateTextField.frame.width + margin, streetTextField.frame.maxY, zipWidth, textFieldHeight))
            
            streetTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            cityTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            stateTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            zipTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            
            streetTextField.placeholder = "street"
            cityTextField.placeholder = "city"
            stateTextField.placeholder = "st."
            zipTextField.placeholder = "zip"
            
            streetTextField.text = Agent.getStreet(property[1])
            cityTextField.text = Agent.getCity(property[1])
            stateTextField.text = Agent.getState(property[1])
            zipTextField.text = Agent.getZip(property[1])
            
            streetTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
            zipTextField.keyboardType = UIKeyboardType.NumberPad
            
            streetTextField.autocapitalizationType = UITextAutocapitalizationType.Words
            cityTextField.autocapitalizationType = UITextAutocapitalizationType.Words
            stateTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
            
            streetTextField.autocorrectionType = UITextAutocorrectionType.No
            stateTextField.autocorrectionType = UITextAutocorrectionType.No
            cityTextField.autocorrectionType = UITextAutocorrectionType.No
            zipTextField.autocorrectionType = UITextAutocorrectionType.No
            
            streetTextField.spellCheckingType = UITextSpellCheckingType.No
            stateTextField.spellCheckingType = UITextSpellCheckingType.No
            cityTextField.spellCheckingType = UITextSpellCheckingType.No
            zipTextField.spellCheckingType = UITextSpellCheckingType.No
            
            self.view.addSubview(streetTextField)
            self.view.addSubview(cityTextField)
            self.view.addSubview(stateTextField)
            self.view.addSubview(zipTextField)
            
            passwordTextField = fooTextField(frame: CGRectMake(margin, cityTextField.frame.maxY + 2, fieldWidth, textFieldHeight))
            passwordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            passwordTextField.placeholder = "password"
            passwordTextField.secureTextEntry = true
            passwordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
            self.view.addSubview(passwordTextField)
        } else if propertyType == "PHONE" {
            valueTextField.keyboardType = UIKeyboardType.NumberPad
        } else if propertyType == "EMAIL" {
            valueTextField.keyboardType = UIKeyboardType.EmailAddress
        } else if propertyType == "PASSWORD" {
            newPasswordTextField = fooTextField(frame: CGRectMake(margin, navBarMaxY + margin, fieldWidth, textFieldHeight))
            newPasswordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            newPasswordTextField.placeholder = "new password"
            newPasswordTextField.secureTextEntry = true
            newPasswordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
            self.view.addSubview(newPasswordTextField)

            reenterPasswordTextField = fooTextField(frame: CGRectMake(margin, newPasswordTextField.frame.maxY, fieldWidth, textFieldHeight))
            reenterPasswordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            reenterPasswordTextField.placeholder = "new password again"
            reenterPasswordTextField.secureTextEntry = true
            reenterPasswordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
            self.view.addSubview(reenterPasswordTextField)
            
            passwordTextField = fooTextField(frame: CGRectMake(margin, reenterPasswordTextField.frame.maxY + 2, fieldWidth, textFieldHeight))
            passwordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            passwordTextField.placeholder = "old password"
            passwordTextField.secureTextEntry = true
            passwordTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
            self.view.addSubview(passwordTextField)
        }
    }

    func saveButton(sender: AnyObject) {

        var alert: String!
        var value: String!
        
        if propertyType == "ADDRESS" {
            value = "\(self.streetTextField.text)|\(self.cityTextField.text)|\(self.stateTextField.text)|\(self.zipTextField.text)"
        } else if propertyType == "PASSWORD" {
            value = newPasswordTextField.text
        } else {
            value = valueTextField.text
        }
        
        if passwordTextField.text.isEmpty {
            alert = "Password Required"
        } else if propertyType != "PASSWORD" && value == agent.properties[propertyIndex][1] {
            alert = "No Changes Detected"
        } else if propertyType == "ADDRESS" {
            if streetTextField.text.isEmpty || stateTextField.text.isEmpty || cityTextField.text.isEmpty || zipTextField.text.isEmpty {
                alert = "Missing Fields"
            }
        } else if propertyType == "PHONE" {
            value = valueTextField.text.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch, range: nil)
            if count(value) != 10 {
                alert = "Invalid Number Of Digits"
            }
        } else if propertyType == "EMAIL" {
            if count(valueTextField.text.componentsSeparatedByString(" ")) != 1 {
                alert = "No White Spaces Allowed"
            } else if count(valueTextField.text.componentsSeparatedByString("@")) != 2 {
                alert = "Invalid Email Format"
            }
        } else if propertyType == "USERNAME" {
            if count(valueTextField.text.componentsSeparatedByString(" ")) != 1 {
                alert = "No White Spaces Allowed"
            }
        } else if propertyType == "PASSWORD" {
            if newPasswordTextField.text.isEmpty {
                alert = "New Password Blank"
            } else if newPasswordTextField.text != reenterPasswordTextField.text {
                alert = "New Passwords Don't Match"
            }
        }
        
        if alert != nil {
            var failedValidationAlert: UIAlertController = UIAlertController(title: alert, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            failedValidationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(failedValidationAlert, animated: true, completion: nil)
            
        } else {
            // authenticates user by login, failed login doesn't logout user
            let username = PFUser.currentUser()["username"] as! String
            PFUser.logInWithUsernameInBackground(username, password: passwordTextField.text) {
                (user: PFUser!, error: NSError!) -> Void in
                if error != nil {

                    switch error.code {
                    case 100: // internet connection appears offline
                        alert = "Network Offline"
                    case 101: // invalid login credentials
                        alert = "Invalid Password"
                    default:
                        alert = error.localizedDescription
                    }
                    
                    var failedOperationAlert: UIAlertController = UIAlertController(title: alert, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    failedOperationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(failedOperationAlert, animated: true, completion: nil)
                    
                } else {
                    if self.propertyType == "PASSWORD" {
                        // PFUser.currentUser()["password"] does not work
                        PFUser.currentUser().password = value
                    } else {
                        PFUser.currentUser()[self.propertyName] = value
                    }
                    PFUser.currentUser().saveInBackgroundWithBlock {
                        (success: Bool, error: NSError!) -> Void in
                        if success {
                            if self.propertyType == "PASSWORD" {
                                agent.properties[self.propertyIndex][1] = "*******"
                            } else {
                                agent.properties[self.propertyIndex][1] = value
                            }
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            NSLog("%@", error)
                        }
                    }
                }
            }
        }
    }

    func cancelButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
