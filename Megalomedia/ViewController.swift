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
    
    // Check for launching app on login or not
    @IBOutlet weak var launchOnLoginCheck: NSButton!
    
    // Outlets for buttons for choosing new shortcuts
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var soundCloudButton: NSButton!
    @IBOutlet weak var youTubeButton: NSButton!
    @IBOutlet weak var iTunesButton: NSButton!
    @IBOutlet weak var vlcButton: NSButton!
    @IBOutlet weak var spotifyButton: NSButton!
    
    // Font and paragraph style
    let font: NSFont = NSFont.systemFontOfSize(13)
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    
    // Dictionary containing app name and tuple with associated button, Bool determining if currently picking new shortcut, button label, and shortcut keycode
    var appDict = [String: (button: NSButton, picking: Bool, label: String, keycode: UInt16?)]()
    
    // Toggles whether or not to launch on login
    @IBAction func toggleLaunchOnLogin(sender: NSButton) {
        print("press detected")
        if sender.state == NSOnState {
            SMLoginItemSetEnabled("com.justinshi.MegalomediaHelper", true)
        }
        else {
            SMLoginItemSetEnabled("com.justinshi.MegalomediaHelper", false)
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.state == NSOnState, forKey: "loginChecked")
        defaults.synchronize()
    }
    
    // Clears shortcuts
    @IBAction func clearShortcut(sender: NSButton) {
        for (name, tuple) in appDict {
            if name == sender.identifier {
                tuple.button.title = "Pick Shortcut"
                tuple.button.state = NSOffState
                appDict[name] = (tuple.button, false, "Pick Shortcut", nil)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(nil, forKey: name + "_label")
                defaults.setInteger(-1, forKey: name + "_keycode")
                defaults.synchronize()
            }
            else if tuple.picking {
                tuple.button.title = tuple.label
                tuple.button.state = NSOffState
                appDict[name] = (tuple.button, false, tuple.label, tuple.keycode)
            }
        }
    }
    
    // Activates picking new shortcut state for app
    @IBAction func picking(sender: NSButton) {
        for (name, tuple) in appDict {
            if tuple.button == sender {
                tuple.button.state = NSOnState
                tuple.button.attributedTitle = NSAttributedString(string: "Press New Shortcut", attributes: [NSForegroundColorAttributeName: NSColor.whiteColor(), NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle])
                appDict[name] = (tuple.button, true, tuple.label, tuple.keycode)
            }
            else if tuple.picking {
                tuple.button.title = tuple.label
                tuple.button.state = NSOffState
                appDict[name] = (tuple.button, false, tuple.label, tuple.keycode)
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
        for (name, tuple) in appDict {
            
            // When currently picking new shortcut
            if tuple.picking {
                
                tuple.button.title = ""
                
                // Add modifier key label
                if theEvent.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    tuple.button.title += "⌘"
                }
                if theEvent.modifierFlags.contains(NSEventModifierFlags.AlternateKeyMask) {
                    tuple.button.title += "⌥"
                }
                if theEvent.modifierFlags.contains(NSEventModifierFlags.ControlKeyMask) {
                    tuple.button.title += "⌃"
                }
                if theEvent.modifierFlags.contains(NSEventModifierFlags.FunctionKeyMask) {
                    tuple.button.title += "fn"
                }
                if theEvent.modifierFlags.contains(NSEventModifierFlags.ShiftKeyMask) {
                    tuple.button.title += "⇧"
                }
                
                // Ensure correct label is given to button corresponding to keypress (unaltered by Shift key)
                switch theEvent.keyCode {
                    case UInt16(kVK_Tab):
                        tuple.button.title += "⇥"
                    case UInt16(kVK_Space):
                        tuple.button.title += "space"
                    case UInt16(kVK_Return):
                        tuple.button.title += "↩︎"
                    case UInt16(kVK_Delete):
                        tuple.button.title += "⌫"
                    case UInt16(kVK_Escape):
                        tuple.button.title += "⎋"
                    case UInt16(kVK_RightArrow):
                        tuple.button.title += "→"
                    case UInt16(kVK_LeftArrow):
                        tuple.button.title += "←"
                    case UInt16(kVK_UpArrow):
                        tuple.button.title += "↑"
                    case UInt16(kVK_DownArrow):
                        tuple.button.title += "↓"
                    case UInt16(kVK_F1):
                        tuple.button.title = "F1"
                    case UInt16(kVK_F2):
                        tuple.button.title = "F2"
                    case UInt16(kVK_F3):
                        tuple.button.title = "F3"
                    case UInt16(kVK_F4):
                        tuple.button.title = "F4"
                    case UInt16(kVK_F5):
                        tuple.button.title = "F5"
                    case UInt16(kVK_F6):
                        tuple.button.title = "F6"
                    case UInt16(kVK_F7):
                        tuple.button.title = "F7"
                    case UInt16(kVK_F8):
                        tuple.button.title = "F8"
                    case UInt16(kVK_F9):
                        tuple.button.title = "F9"
                    case UInt16(kVK_F10):
                        tuple.button.title = "F10"
                    case UInt16(kVK_F11):
                        tuple.button.title = "F11"
                    case UInt16(kVK_F12):
                        tuple.button.title = "F12"
                    case UInt16(kVK_F13):
                        tuple.button.title = "F13"
                    case UInt16(kVK_F14):
                        tuple.button.title = "F14"
                    case UInt16(kVK_F15):
                        tuple.button.title = "F15"
                    case UInt16(kVK_F16):
                        tuple.button.title = "F16"
                    case UInt16(kVK_F17):
                        tuple.button.title = "F17"
                    case UInt16(kVK_F18):
                        tuple.button.title = "F18"
                    case UInt16(kVK_F19):
                        tuple.button.title = "F19"
                    case UInt16(kVK_ANSI_0):
                        tuple.button.title += "0"
                    case UInt16(kVK_ANSI_1):
                        tuple.button.title += "1"
                    case UInt16(kVK_ANSI_2):
                        tuple.button.title += "2"
                    case UInt16(kVK_ANSI_3):
                        tuple.button.title += "3"
                    case UInt16(kVK_ANSI_4):
                        tuple.button.title += "4"
                    case UInt16(kVK_ANSI_5):
                        tuple.button.title += "5"
                    case UInt16(kVK_ANSI_6):
                        tuple.button.title += "6"
                    case UInt16(kVK_ANSI_7):
                        tuple.button.title += "7"
                    case UInt16(kVK_ANSI_8):
                        tuple.button.title += "8"
                    case UInt16(kVK_ANSI_9):
                        tuple.button.title += "9"
                    case UInt16(kVK_ANSI_Grave):
                        tuple.button.title += "`"
                    case UInt16(kVK_ANSI_Comma):
                        tuple.button.title += ","
                    case UInt16(kVK_ANSI_Period):
                        tuple.button.title += "."
                    case UInt16(kVK_ANSI_Slash):
                        tuple.button.title += "/"
                    case UInt16(kVK_ANSI_Semicolon):
                        tuple.button.title += ";"
                    case UInt16(kVK_ANSI_Quote):
                        tuple.button.title += "'"
                    case UInt16(kVK_ANSI_LeftBracket):
                        tuple.button.title += "["
                    case UInt16(kVK_ANSI_RightBracket):
                        tuple.button.title += "]"
                    case UInt16(kVK_ANSI_Backslash):
                        tuple.button.title += "\\"
                    case UInt16(kVK_ANSI_Minus):
                        tuple.button.title += "-"
                    case UInt16(kVK_ANSI_Equal):
                        tuple.button.title += "="
                    default:
                        tuple.button.title += theEvent.charactersIgnoringModifiers!.uppercaseString
                }
                
                // Switch out of selecting shortcut state
                tuple.button.state = NSOffState
                appDict[name] = (tuple.button, false, tuple.button.title, theEvent.keyCode)

                // Update user default preferences
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(tuple.button.title, forKey: name + "_label")
                defaults.setInteger(Int(theEvent.keyCode), forKey: name + "_keycode")
                defaults.synchronize()
                return
            }
        }
        
        // Regular expression used to see if key is function key
        let regex = try! NSRegularExpression(pattern: "F[0-9]+", options: NSRegularExpressionOptions.CaseInsensitive)
        
        // AppleScripts for pausing players
        for (name, tuple) in appDict {
            let range = NSRange.init(location: 0, length: tuple.button.title.characters.count)
            if theEvent.keyCode == tuple.keycode && validateModifiers(theEvent, title: tuple.button.title, functionKey: 0 < regex.numberOfMatchesInString(tuple.button.title, options: NSMatchingOptions.WithoutAnchoringBounds, range: range)) {
                var path: String?
                var handler: NSAppleEventDescriptor
                
                // If universal pause button was pressed
                if name == "Pause" {
                    path = NSBundle.mainBundle().pathForResource("UniversalPause", ofType: "scpt")
                    let url = NSURL(fileURLWithPath: path!)
                    let appleScript = NSAppleScript(contentsOfURL: url, error: nil)
                    appleScript!.executeAndReturnError(nil)
                    return
                }
                    
                // Otherwise, decide to execute AppleScript for app players or web players
                else if name == "YouTube" || name == "SoundCloud" {
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
                appleScript!.executeAppleEvent(event, error: nil)
            }
        }
    }
    
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
        let defaults = NSUserDefaults.standardUserDefaults()
        for (name, tuple) in appDict {
            if defaults.objectForKey(name + "_label") != nil {
                tuple.button.title = defaults.objectForKey(name + "_label") as! String
                appDict[name] = (tuple.button, false, defaults.objectForKey(name + "_label") as! String, UInt16(defaults.integerForKey(name + "_keycode")))
            }
        }
        if defaults.boolForKey("loginChecked") {
            launchOnLoginCheck.state = NSOnState
        }
        else {
            launchOnLoginCheck.state = NSOffState
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