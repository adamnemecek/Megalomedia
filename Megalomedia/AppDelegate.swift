//
//  AppDelegate.swift
//  Megalomedia
//
//  Created by Justin Shi on 6/20/16.
//  Copyright © 2016 Justin Shi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    var controller: NSWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.controller = self.storyboard.instantiateControllerWithIdentifier("preferenceWindowController") as? NSWindowController
        self.controller!.window!.delegate = self
        if let button = self.statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(openPreferencesWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit Megalomedia", action: #selector(exitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    func openPreferencesWindow(sender: AnyObject) {
        self.controller!.showWindow(nil)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        NSApplication.sharedApplication().hide(sender)
        return true
    }
    
    func exitApp(sender: AnyObject) {
        exit(0)
    }

}

