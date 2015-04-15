//
//  AppDelegate.swift
//  AgentZ
//
//  Created by Goldenbird Ventures on 1/25/15.
//  Copyright (c) 2015 foobbar. All rights reserved.
//

import UIKit

var globalFile: PFFile! // file to be attached to a transaction

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.setApplicationId("LTPIXk6N114fkwvoDA9Bwd0RDI87GgS7ArFIA5VQ", clientKey: "4L064ZEUILgNRCr6tdZKyEQE3Oei3S55sGxyDZ67")
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(applic1ation: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        //println("opening URL: \(url)")
        
        let filemgr = NSFileManager.defaultManager()

        
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentsDirectory: String = paths[0] as String
        var inboxPath = documentsDirectory.stringByAppendingPathComponent("Inbox")
        let dirFiles = filemgr.contentsOfDirectoryAtPath(inboxPath, error: nil)
        
        if !filemgr.changeCurrentDirectoryPath(inboxPath) {
            println("Panic: failed to change directory")
        }
        
        if let myFileName = url.lastPathComponent {
            if let _dirFiles = dirFiles {
                for aFile in _dirFiles {
                    let _aFile = aFile as String

                    if myFileName == _aFile {
                        if let myFile: NSData = filemgr.contentsAtPath(myFileName) {
                            //println("file \(myFileName) opened")
                       
                            globalFile = PFFile(name: myFileName, data: myFile)
                        }
                    }
                    
                    var error: NSError?
                    if !filemgr.removeItemAtPath(_aFile, error: &error) {
                        println("Remove failed: \(error!.localizedDescription)")
                    }
                }
            }
            
        }
        
        let filelist = filemgr.contentsOfDirectoryAtPath(inboxPath, error: nil)
        if filelist!.count != 0 {
            println("Panic: inbox not cleaned up")
        }
        //for filename in filelist!


        return true
    }

}

