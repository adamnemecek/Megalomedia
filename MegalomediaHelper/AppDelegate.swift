//
//  AppDelegate.swift
//  MegalomediaHelper
//
//  Created by Justin Shi on 7/21/16.
//  Copyright © 2016 Justin Shi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Helper application launches main application then terminates
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        var pathComponents: NSArray = (NSBundle.mainBundle().bundleURL.pathComponents)!
        pathComponents = pathComponents.subarrayWithRange(NSMakeRange(0, pathComponents.count - 4))
        let path = NSString.pathWithComponents(pathComponents as! [String])
        NSWorkspace.sharedWorkspace().launchApplication(path)
        NSApp.terminate(nil)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
}

