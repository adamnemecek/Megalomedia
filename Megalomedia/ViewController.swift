//
//  ViewController.swift
//  Megalomedia
//
//  Created by Justin Shi on 6/20/16.
//  Copyright © 2016 Justin Shi. All rights reserved.
//

import Carbon
import Cocoa
import Foundation
import ServiceManagement

class ViewController: NSViewController {
    
    // Controller and animation for notifications
    
    // WORKING ON IT
    var testWindowController: NSWindowController?
    // WORKING ON IT
    var notificationWindowController: NSWindowController? = nil
    var fadeOut: NSViewAnimation?
    
    // Outlets for checks for enabling notifications and launching app on login, and buttons for choosing new shortcuts
    @IBOutlet weak var enableNotificationsCheck: NSButton!
    @IBOutlet weak var launchOnLoginCheck: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var soundCloudButton: NSButton!
    @IBOutlet weak var youTubeButton: NSButton!
    @IBOutlet weak var iTunesButton: NSButton!
    @IBOutlet weak var vlcButton: NSButton!
    @IBOutlet weak var spotifyButton: NSButton!
    
    // Font and paragraph style
    let font: NSFont = NSFont.systemFontOfSize(13)
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    let defaults = NSUserDefaults.standardUserDefaults()
    let regex = try! NSRegularExpression(pattern: "F[0-9]+", options: NSRegularExpressionOptions.CaseInsensitive)
    
    // Dictionary containing app name and tuple with associated button, Bool determining if currently picking new shortcut, button label, and shortcut keycode
    var appDict = [String: (button: NSButton, picking: Bool, label: String, keycode: UInt16?)]()
    
    @IBAction func toggleEnableNotifications(sender: NSButton) {
        defaults.setBool(sender.state == NSOnState, forKey: "notificationsChecked")
        defaults.synchronize()
    }
    
    @IBAction func toggleLaunchOnLogin(sender: NSButton) {
        SMLoginItemSetEnabled("com.justinshi.MegalomediaHelper", sender.state == NSOnState)
        defaults.setBool(sender.state == NSOnState, forKey: "loginChecked")
        defaults.synchronize()
    }
    
    @IBAction func clearShortcut(sender: NSButton) {
        
        // Clear shortcut of specified app and switch all buttons out of "picking" state
        for (name, details) in appDict {
            if details.picking {
                details.button.title = details.label
                details.button.state = NSOffState
                appDict[name] = (details.button, false, details.label, details.keycode)
                
                // Change cancel button back to clear button
                for cancel in self.view.subviews {
                    if cancel.identifier == name {
                        (cancel as! NSButton).title = "Clear"
                    }
                }
            }
            else if name == sender.identifier || sender.identifier == "ClearAll" {
                details.button.title = "Pick Shortcut"
                details.button.state = NSOffState
                appDict[name] = (details.button, false, "Pick Shortcut", nil)
                defaults.setObject(nil, forKey: name + "_label")
                defaults.setInteger(-1, forKey: name + "_keycode")
                defaults.synchronize()
            }
        }
    }
    
    // Activates picking new shortcut state for app
    @IBAction func picking(sender: NSButton) {
        for (name, details) in appDict {
            if details.button == sender {
                details.button.state = NSOnState
                details.button.attributedTitle = NSAttributedString(string: "Press New Shortcut", attributes: [NSForegroundColorAttributeName: NSColor.whiteColor(), NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle])
                appDict[name] = (details.button, true, details.label, details.keycode)
                
                // Change clear button to cancel button
                for clear in self.view.subviews {
                    if clear.identifier == name {
                        (clear as! NSButton).title = "Cancel"
                    }
                }
            }
                
            // Switch all other buttons out of "picking" state
            else if details.picking {
                details.button.title = details.label
                details.button.state = NSOffState
                appDict[name] = (details.button, false, details.label, details.keycode)
                
                // Change cancel button back to clear button
                for cancel in self.view.subviews {
                    if cancel.identifier == name {
                        (cancel as! NSButton).title = "Clear"
                    }
                }
            }
        }
    }
    
    // Check if keypress event includes correct modifying keys
    func validateModifiers(theEvent: NSEvent, title: String, functionKey: Bool) -> Bool {
        if title.containsString("⌘") != theEvent.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
            return false
        }
        if title.containsString("⌥") != theEvent.modifierFlags.contains(NSEventModifierFlags.AlternateKeyMask) {
            return false
        }
        if title.containsString("⌃") != theEvent.modifierFlags.contains(NSEventModifierFlags.ControlKeyMask) {
            return false
        }
        if title.containsString("⇧") != theEvent.modifierFlags.contains(NSEventModifierFlags.ShiftKeyMask) {
            return false
        }
        
        // If function key was pressed, we don't need to check for function modifier key
        if (title.containsString("fn") != theEvent.modifierFlags.contains(NSEventModifierFlags.FunctionKeyMask)) && !functionKey {
            return false
        }
        return true
    }
    
    // Keypresses; either activate shortcut or select new shortcut
    func playPause(theEvent: NSEvent) {
        for (name, details) in appDict {
            
            // When currently picking new shortcut
            if details.picking {
                details.button.title = ""
                
                // Add modifier key label
                if theEvent.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    
                    // Quit app shortcut; don't do anything
                    if theEvent.keyCode == UInt16(kVK_ANSI_Q) {
                        return
                    }
                    details.button.title += "⌘"
                }
                if theEvent.modifierFlags.contains(NSEventModifierFlags.AlternateKeyMask) {
                    details.button.title += "⌥"
                }
                if theEvent.modifierFlags.contains(NSEventModifierFlags.ControlKeyMask) {
                    details.button.title += "⌃"
                }
                if theEvent.modifierFlags.contains(NSEventModifierFlags.FunctionKeyMask) {
                    details.button.title += "fn"
                }
                if theEvent.modifierFlags.contains(NSEventModifierFlags.ShiftKeyMask) {
                    details.button.title += "⇧"
                }
                
                // Ensure correct label is given to button corresponding to keypress (unaltered by Shift key)
                switch theEvent.keyCode {
                    case UInt16(kVK_Tab):
                        details.button.title += "⇥"
                    case UInt16(kVK_Space):
                        details.button.title += "space"
                    case UInt16(kVK_Return):
                        details.button.title += "↩︎"
                    case UInt16(kVK_Delete):
                        details.button.title += "⌫"
                    case UInt16(kVK_Escape):
                        details.button.title += "⎋"
                    case UInt16(kVK_RightArrow):
                        details.button.title += "→"
                    case UInt16(kVK_LeftArrow):
                        details.button.title += "←"
                    case UInt16(kVK_UpArrow):
                        details.button.title += "↑"
                    case UInt16(kVK_DownArrow):
                        details.button.title += "↓"
                    case UInt16(kVK_F1):
                        details.button.title = "F1"
                    case UInt16(kVK_F2):
                        details.button.title = "F2"
                    case UInt16(kVK_F3):
                        details.button.title = "F3"
                    case UInt16(kVK_F4):
                        details.button.title = "F4"
                    case UInt16(kVK_F5):
                        details.button.title = "F5"
                    case UInt16(kVK_F6):
                        details.button.title = "F6"
                    case UInt16(kVK_F7):
                        details.button.title = "F7"
                    case UInt16(kVK_F8):
                        details.button.title = "F8"
                    case UInt16(kVK_F9):
                        details.button.title = "F9"
                    case UInt16(kVK_F10):
                        details.button.title = "F10"
                    case UInt16(kVK_F11):
                        details.button.title = "F11"
                    case UInt16(kVK_F12):
                        details.button.title = "F12"
                    case UInt16(kVK_F13):
                        details.button.title = "F13"
                    case UInt16(kVK_F14):
                        details.button.title = "F14"
                    case UInt16(kVK_F15):
                        details.button.title = "F15"
                    case UInt16(kVK_F16):
                        details.button.title = "F16"
                    case UInt16(kVK_F17):
                        details.button.title = "F17"
                    case UInt16(kVK_F18):
                        details.button.title = "F18"
                    case UInt16(kVK_F19):
                        details.button.title = "F19"
                    case UInt16(kVK_ANSI_0):
                        details.button.title += "0"
                    case UInt16(kVK_ANSI_1):
                        details.button.title += "1"
                    case UInt16(kVK_ANSI_2):
                        details.button.title += "2"
                    case UInt16(kVK_ANSI_3):
                        details.button.title += "3"
                    case UInt16(kVK_ANSI_4):
                        details.button.title += "4"
                    case UInt16(kVK_ANSI_5):
                        details.button.title += "5"
                    case UInt16(kVK_ANSI_6):
                        details.button.title += "6"
                    case UInt16(kVK_ANSI_7):
                        details.button.title += "7"
                    case UInt16(kVK_ANSI_8):
                        details.button.title += "8"
                    case UInt16(kVK_ANSI_9):
                        details.button.title += "9"
                    case UInt16(kVK_ANSI_Grave):
                        details.button.title += "`"
                    case UInt16(kVK_ANSI_Comma):
                        details.button.title += ","
                    case UInt16(kVK_ANSI_Period):
                        details.button.title += "."
                    case UInt16(kVK_ANSI_Slash):
                        details.button.title += "/"
                    case UInt16(kVK_ANSI_Semicolon):
                        details.button.title += ";"
                    case UInt16(kVK_ANSI_Quote):
                        details.button.title += "'"
                    case UInt16(kVK_ANSI_LeftBracket):
                        details.button.title += "["
                    case UInt16(kVK_ANSI_RightBracket):
                        details.button.title += "]"
                    case UInt16(kVK_ANSI_Backslash):
                        details.button.title += "\\"
                    case UInt16(kVK_ANSI_Minus):
                        details.button.title += "-"
                    case UInt16(kVK_ANSI_Equal):
                        details.button.title += "="
                    default:
                        details.button.title += theEvent.charactersIgnoringModifiers!.uppercaseString
                }
                
                // Avoid overlapping shortcuts
                for (otherName, otherDetails) in appDict {
                    if !otherDetails.picking && otherDetails.button.title == details.button.title {
                        otherDetails.button.title = "Pick Shortcut"
                        appDict[otherName] = (otherDetails.button, false, otherDetails.button.title, nil)
                        defaults.setObject(nil, forKey: otherName + "_label")
                        defaults.setInteger(-1, forKey: otherName + "_keycode")
                        defaults.synchronize()
                    }
                }
                
                // Change cancel button back to clear button
                for cancel in self.view.subviews {
                    if cancel.identifier == name {
                        (cancel as! NSButton).title = "Clear"
                    }
                }
                
                // Switch out of selecting shortcut state
                details.button.state = NSOffState
                appDict[name] = (details.button, false, details.button.title, theEvent.keyCode)

                // Update user default preferences
                defaults.setObject(details.button.title, forKey: name + "_label")
                defaults.setInteger(Int(theEvent.keyCode), forKey: name + "_keycode")
                defaults.synchronize()
                return
            }
        }
        
        // AppleScripts for pausing players
        for (name, details) in appDict {
            let range = NSRange.init(location: 0, length: details.button.title.characters.count)
            if theEvent.keyCode == details.keycode && validateModifiers(theEvent, title: details.button.title, functionKey: 0 < regex.numberOfMatchesInString(details.button.title, options: NSMatchingOptions.WithoutAnchoringBounds, range: range)) {
                var path: String?
                var handler: NSAppleEventDescriptor
                
                // If universal pause button was pressed
                if name == "Pause" {
                    path = NSBundle.mainBundle().pathForResource("UniversalPause", ofType: "scpt")
                    let url = NSURL(fileURLWithPath: path!)
                    let appleScript = NSAppleScript(contentsOfURL: url, error: nil)
                    appleScript!.executeAndReturnError(nil)
                    displayNotification(name)
                    return
                }
                    
                // Otherwise, decide to execute AppleScript for app players or web players
                else if name == "YouTube" || name == "SoundCloud" {
                    
                    // WORKING ON IT
                    displayYouTubeTitles()
                    // WORKING ON IT
                    
                    path = NSBundle.mainBundle().pathForResource("WebPlayPause", ofType: "scpt")
                    handler = NSAppleEventDescriptor(string: "playPauseWeb")
                }
                else {
                    path = NSBundle.mainBundle().pathForResource("AppPlayPause", ofType: "scpt")
                    handler = NSAppleEventDescriptor(string: "playPauseApp")
                }
                let url = NSURL(fileURLWithPath: path!)
                let appleScript = NSAppleScript(contentsOfURL: url, error: nil)
                let parameter = NSAppleEventDescriptor(string: name)
                let parameterList = NSAppleEventDescriptor.listDescriptor()
                parameterList.insertDescriptor(parameter, atIndex: 1)
                var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
                let target = NSAppleEventDescriptor(descriptorType: DescType(typeProcessSerialNumber), bytes: &psn, length: sizeof(ProcessSerialNumber))
                let event = NSAppleEventDescriptor.appleEventWithEventClass(AEEventClass(kASAppleScriptSuite), eventID: AEEventID(kASSubroutineEvent), targetDescriptor: target, returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
                event.setParamDescriptor(handler, forKeyword: AEKeyword(keyASSubroutineName))
                event.setParamDescriptor(parameterList, forKeyword: AEKeyword(keyDirectObject))
                if appleScript!.executeAppleEvent(event, error: nil).stringValue == "running" {
                    displayNotification(name)
                }
            }
        }
    }
    
    // Called to display notification showing which app shortcut pressed was
    func displayNotification(appName: String) {
        if enableNotificationsCheck.state == NSOnState {
            
            // Handle notifications and animations if new shortcut is pressed while old notification still visible
            if notificationWindowController != nil && notificationWindowController!.window!.visible {
                fadeOut!.stopAnimation()
                notificationWindowController!.close()
            }
            notificationWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("notificationWindowController") as? NSWindowController
            (notificationWindowController!.window!.contentView!.subviews[0] as! NSImageView).image = NSImage(named: appName + " inverted")
            notificationWindowController!.showWindow(nil)
            fadeOut = NSViewAnimation(viewAnimations: [[NSViewAnimationTargetKey: notificationWindowController!.window!, NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect]])
            fadeOut!.duration = 1.5
            fadeOut!.animationBlockingMode = .Nonblocking
            fadeOut!.animationCurve = .EaseIn
            fadeOut!.startAnimation()
        }
    }
    
    // WORKING ON IT
    func displayYouTubeTitles() {
        let path = NSBundle.mainBundle().pathForResource("YouTubeTabCount", ofType: "scpt")
        let url = NSURL(fileURLWithPath: path!)
        let appleScript = NSAppleScript(contentsOfURL: url, error: nil)
        let rawResult = appleScript!.executeAndReturnError(nil)
        var titleArray = [String]()
        for i in 1...rawResult.numberOfItems {
            let rawString = rawResult.descriptorAtIndex(i)!.stringValue
            titleArray.append(rawString!.substringWithRange(rawString!.startIndex.advancedBy(5)..<rawString!.endIndex.advancedBy(-3)))
        }
        testWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("test") as? NSWindowController
        let theFrame = testWindowController!.window!.contentView!.frame
        let scrollview = NSScrollView(frame: theFrame)
        scrollview.borderType = .NoBorder
        scrollview.autoresizingMask = .ViewNotSizable
        scrollview.contentView = NSClipView(frame: theFrame)
        var docHeight: CGFloat
        if (30 * rawResult.numberOfItems) > Int(theFrame.height) {
            docHeight = CGFloat(30 * rawResult.numberOfItems)
        }
        else {
            docHeight = theFrame.height
        }
        scrollview.contentView.documentView = YouTubeSelectorView(frame: NSMakeRect(0.0, 0.0, theFrame.width, docHeight))
        for i in 0..<rawResult.numberOfItems {
            let text = NSTextField(frame: NSMakeRect(0.0, 30.0 * CGFloat(i), theFrame.width, 30))
            text.stringValue = titleArray[i]
            text.selectable = false
            text.bordered = false
            scrollview.contentView.documentView?.addSubview(text)
        }
        scrollview.drawsBackground = false
        scrollview.verticalScrollElasticity = .None
        scrollview.hasVerticalScroller = true
        scrollview.horizontalScrollElasticity = .None
        scrollview.hasHorizontalScroller = false
        testWindowController!.window!.contentView = scrollview
        testWindowController!.showWindow(nil)
    }
    // WORKING ON IT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set button text style and add app entries to dictionary
        paragraphStyle.alignment = NSTextAlignment.Center
        appDict["Spotify"] = (spotifyButton, false, "Pick Shortcut", nil)
        appDict["VLC"] = (vlcButton, false, "Pick Shortcut", nil)
        appDict["iTunes"] = (iTunesButton, false, "Pick Shortcut", nil)
        appDict["YouTube"] = (youTubeButton, false, "Pick Shortcut", nil)
        appDict["SoundCloud"] = (soundCloudButton, false, "Pick Shortcut", nil)
        appDict["Pause"] = (pauseButton, false, "Pick Shortcut", nil)
        
        // In case user had preferences saved previously, load settings
        for (name, details) in appDict {
            if defaults.objectForKey(name + "_label") != nil {
                details.button.title = defaults.objectForKey(name + "_label") as! String
                appDict[name] = (details.button, false, defaults.objectForKey(name + "_label") as! String, UInt16(defaults.integerForKey(name + "_keycode")))
            }
        }
        if defaults.boolForKey("loginChecked") {
            launchOnLoginCheck.state = NSOnState
        }
        else {
            launchOnLoginCheck.state = NSOffState
        }
        if defaults.boolForKey("notificationsChecked") {
            enableNotificationsCheck.state = NSOnState
        }
        else {
            enableNotificationsCheck.state = NSOffState
        }
        
        // Prompt user for accessibility access if not allowed and set monitors for keypresses
        AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true])
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) { (theEvent) -> NSEvent! in
            self.playPause(theEvent)
            return theEvent
        }
        NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) { (theEvent) -> Void in
            self.playPause(theEvent)
        }
    }
}

// forward and backwards skip, YouTube multiple pages problem