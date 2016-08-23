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
    
    // Main storyboard, application status bar icon, controller fo preferences and "about" window
    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    var preferenceController: NSWindowController?
    var aboutController: NSWindowController?
    var helpController: NSWindowController?
    
    // Number of windows open - hide application when 0
    var nWindowsOpen = 0
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Instantiate controller, set delegate for window (to handle window closing actions), set window level, set status bar and menu items
        self.preferenceController = self.storyboard.instantiateControllerWithIdentifier("preferenceWindowController") as? NSWindowController
        self.aboutController = self.storyboard.instantiateControllerWithIdentifier("aboutWindowController") as? NSWindowController
        self.helpController = self.storyboard.instantiateControllerWithIdentifier("helpWindowController") as? NSWindowController
        self.preferenceController!.window!.level = Int(CGWindowLevelForKey(CGWindowLevelKey.FloatingWindowLevelKey))
        self.aboutController!.window!.level = Int(CGWindowLevelForKey(CGWindowLevelKey.FloatingWindowLevelKey))
        self.helpController!.window!.level = Int(CGWindowLevelForKey(CGWindowLevelKey.FloatingWindowLevelKey))
        self.preferenceController!.window!.delegate = self
        self.aboutController!.window!.delegate = self
        self.helpController!.window!.delegate = self
        let button = self.statusItem.button
        button!.image = NSImage(named: "StatusBarButtonImage")
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About Megalomedia", action: #selector(openAboutWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Help", action: #selector(openHelpWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(openPreferencesWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit Megalomedia", action: #selector(exitApp), keyEquivalent: ""))
        statusItem.menu = menu
    }
    
    func openPreferencesWindow(sender: AnyObject) {
        nWindowsOpen += 1
        self.preferenceController!.showWindow(nil)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    
    func openAboutWindow(sender: AnyObject) {
        nWindowsOpen += 1
        self.aboutController!.showWindow(nil)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    
    func openHelpWindow(sender: AnyObject) {
        nWindowsOpen += 1
        self.helpController!.showWindow(nil)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        nWindowsOpen -= 1
        // When all windows closed, switch focus to next application (gets rid of "funk" noises on keypresses)
        if nWindowsOpen == 0 {
            NSApplication.sharedApplication().hide(sender)
        }
        return true
    }
    
    func windowDidResignMain(notification: NSNotification) {
        // When preferences window resigns main status, call this method with a generic button; this clears all shortcuts stuck in the "picking" state
        (self.preferenceController!.contentViewController! as! ViewController).picking(NSButton())
    }
    
    func exitApp(sender: AnyObject) {
        exit(0)
    }
}