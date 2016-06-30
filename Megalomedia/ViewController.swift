//
//  ViewController.swift
//  Megalomedia
//
//  Created by Justin Shi on 6/20/16.
//  Copyright © 2016 Justin Shi. All rights reserved.
//

import Cocoa
import Foundation
import Carbon

class ViewController: NSViewController, NSWindowDelegate {

    // Outlets for buttons for choosing new shortcuts
    @IBOutlet weak var iTunesButton: NSButton!
    @IBOutlet weak var vLCButton: NSButton!
    @IBOutlet weak var spotifyButton: NSButton!
    
    // Font and paragraph style
    let font: NSFont = NSFont.systemFontOfSize(13)
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    
    // Dictionary containing app name and tuple with associated button, Bool determining if currently picking new shortcut, button label, and shortcut keycode
    var appDict = [String: (button: NSButton, picking: Bool, label: String, keycode: UInt16?)]()
    
    @IBAction func clearShortcut(sender: NSButton) {
        for (name, tuple) in appDict {
            if name == sender.identifier {
                tuple.button.title = "Pick Shortcut"
                appDict[name] = (tuple.button, false, "Pick Shortcut", nil)
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(nil, forKey: name + "_label")
                defaults.setInteger(-1, forKey: name + "_keycode")
                defaults.synchronize()
                return
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
    
    // Keypresses; either activate shortcut or select new shortcut
    func playPause(theEvent: NSEvent) {
        for (name, tuple) in appDict {
            if tuple.picking {
                tuple.button.title = theEvent.characters!
                tuple.button.state = NSOffState
                appDict[name] = (tuple.button, false, theEvent.characters!, theEvent.keyCode)

                // Update user default preferences
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(theEvent.characters!, forKey: name + "_label")
                defaults.setInteger(Int(theEvent.keyCode), forKey: name + "_keycode")
                defaults.synchronize()
                return
            }
        }
        
        // AppleScript for pausing players
        for (name, tuple) in appDict {
            if theEvent.keyCode == tuple.keycode {
                let scriptSource = "if application \"\(name)\" is running then\n"
                    + "if \"\(name)\" is equal to \"Spotify\" or \"\(name)\" is equal to \"iTunes\" then\n"
                    + "tell application \"\(name)\"\n"
                    + "playpause\n"
                    + "end tell\n"
                    + "else\n"
                    + "tell application \"\(name)\"\n"
                    + "play\n"
                    + "end tell\n"
                    + "end if\n"
                    + "end if"
                let script: NSAppleScript? = NSAppleScript(source: scriptSource)
                script!.executeAndReturnError(nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set button text style and add app entries to dictionary
        paragraphStyle.alignment = .Center
        appDict["Spotify"] = (spotifyButton, false, "Pick Shortcut", nil)
        appDict["VLC"] = (vLCButton, false, "Pick Shortcut", nil)
        appDict["iTunes"] = (iTunesButton, false, "Pick Shortcut", nil)
        
        // In case user had preferences saved previously, load shorcuts
        let defaults = NSUserDefaults.standardUserDefaults()
        for (name, tuple) in appDict {
            if defaults.objectForKey(name + "_label") != nil {
                tuple.button.title = defaults.objectForKey(name + "_label") as! String
                appDict[name] = (tuple.button, false, defaults.objectForKey(name + "_label") as! String, UInt16(defaults.integerForKey(name + "_keycode")))
            }
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

