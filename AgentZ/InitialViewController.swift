//
//  InitialViewController.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/25/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

let screenHeight = UIScreen.mainScreen().bounds.height
let screenWidth = UIScreen.mainScreen().bounds.width

class InitialViewController: UIViewController, UITextFieldDelegate {
    
    var usernameTextField: fooTextField!
    var passwordTextField: UITextField!
    //var loginButton: UIButton!
    
    var keyboardHeight: CGFloat!
    var offset: CGFloat!
    var textFieldArray: [UITextField]!
    
    var loginButton: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        loginButton = UIBarButtonItem(title: "Login", style: UIBarButtonItemStyle.Plain, target: self, action: "loginButton:")
        self.navigationItem.rightBarButtonItem = loginButton
        self.navigationItem.leftBarButtonItem = nil
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("gotoProfile", sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 226/255, green: 232/255, blue: 202/255, alpha: 1.0)
        
        let textFieldWidth = screenWidth - 80
        let textFieldHeight = CGFloat(40)

        let originX = screenWidth / 2 - textFieldWidth / 2
        
        usernameTextField = fooTextField(frame: CGRectMake(originX, screenHeight / 2 - textFieldHeight - 1, textFieldWidth, textFieldHeight))
        // can also use: usernameTextField.frame = CGRectMake(...)
        // or even usernameTextField.center = CGPointMake(...)
        usernameTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        usernameTextField.placeholder = "username"
        usernameTextField.tag = 0
        usernameTextField.autocapitalizationType = UITextAutocapitalizationType.None
        usernameTextField.autocorrectionType = UITextAutocorrectionType.No
        usernameTextField.spellCheckingType = UITextSpellCheckingType.No
        usernameTextField.returnKeyType = UIReturnKeyType.Next
        self.view.addSubview(usernameTextField)
        
        passwordTextField = fooTextField(frame: CGRectMake(originX, screenHeight / 2 + 1, textFieldWidth, textFieldHeight))
        passwordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        passwordTextField.secureTextEntry = true
        passwordTextField.placeholder = "password"
        passwordTextField.tag = 1
        passwordTextField.autocapitalizationType = UITextAutocapitalizationType.None
        passwordTextField.autocorrectionType = UITextAutocorrectionType.No
        passwordTextField.spellCheckingType = UITextSpellCheckingType.No
        self.view.addSubview(passwordTextField)
        
        /*
        loginButton = UIButton(frame: CGRectMake(...))
        loginButton.setTitle("login", forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "loginButton:", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.view.addSubview(loginButton)
        */
        
        // dismiss keyboard if tap anywhere on screen
        let screenTapped = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        self.view.addGestureRecognizer(screenTapped)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        keyboardHeight = 0.0
        offset = 0.0
        textFieldArray = [usernameTextField, passwordTextField]
    }

    func keyboardWillHide(notification: NSNotification) {
        self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        offset = 0.0
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            keyboardHeight = endFrame?.size.height ?? 0.0
        }
        if offset == 0.0 {
            for child in self.view.subviews {
                if child.isFirstResponder() {
                    offset = screenHeight - keyboardHeight - child.frame.maxY - 10
                    if offset < 0 { // textField is occluded by keyboard
                        self.view.frame = CGRectMake(0, offset, screenWidth, screenHeight)
                    } else {
                        offset = 0
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTextFieldTag = textField.tag + 1
        if nextTextFieldTag == textFieldArray.count {
            self.view.endEditing(true)
        } else {
            let nextTextField = textFieldArray[nextTextFieldTag]
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if offset == 0.0 {
            offset = screenHeight - keyboardHeight - textField.frame.maxY - 10
            if offset < 0 { // textField is occluded by keyboard
                UIView.animateWithDuration(0.3, animations: {
                    self.view.frame = CGRectMake(0, self.offset, screenWidth, screenHeight)
                })
            } else {
                offset = 0
            }
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func loginButton(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(usernameTextField.text, password: passwordTextField.text) {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                
                self.view.endEditing(true)
                self.usernameTextField.text = ""
                self.passwordTextField.text = ""
                
                self.performSegueWithIdentifier("gotoProfile", sender: self)
                
            } else if error != nil {
                
                var messageAlert = ""
                switch error.code {
                case 100: // internet connection appears offline
                    messageAlert = "Network offline"
                case 101: // invalid login credentials
                    messageAlert = "Invalid login credentials"
                default:
                    println(error.code)
                    messageAlert = error.localizedDescription
                }
                
                // display alert with error msg
                var failedOperationAlert: UIAlertController = UIAlertController(title: "Login Fail", message: messageAlert, preferredStyle: UIAlertControllerStyle.Alert)
                failedOperationAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(failedOperationAlert, animated: true, completion: nil)
            }
        }
    }
}
