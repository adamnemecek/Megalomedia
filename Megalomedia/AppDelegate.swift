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
    
    // App status bar icon
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    // Controller for preferences window
    var controller: NSWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Instantiate controller, set delegate for window (to handle window closing actions), set status bar and menu items
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
        
        // When window is closed, switch focus to next application (gets rid of "funk" noises on keypresses)
        NSApplication.sharedApplication().hide(sender)
        return true
    }
    
    func exitApp(sender: AnyObject) {
        exit(0)
    }

}

