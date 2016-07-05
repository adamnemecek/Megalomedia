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
    @IBOutlet weak var youTubeButton: NSButton!
    @IBOutlet weak var iTunesButton: NSButton!
    @IBOutlet weak var vlcButton: NSButton!
    @IBOutlet weak var spotifyButton: NSButton!
    
    // Font and paragraph style
    let font: NSFont = NSFont.systemFontOfSize(13)
    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    
    // Dictionary containing app name and tuple with associated button, Bool determining if currently picking new shortcut, button label, and shortcut keycode
    var appDict = [String: (button: NSButton, picking: Bool, label: String, keycode: UInt16?)]()
    
    // Clears shortcuts
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
                
                // Decide to execute AppleScript for app players or web players
                if name == "YouTube" {
                    let path = NSBundle.mainBundle().pathForResource("YouTubePlayPause", ofType: "scpt")
                    let url = NSURL(fileURLWithPath: path!)
                    let appleScript = NSAppleScript(contentsOfURL: url, error: nil)
                    appleScript!.executeAndReturnError(nil)
                    
                }
                else {
                    let path = NSBundle.mainBundle().pathForResource("AppPlayPause", ofType: "scpt")
                    let url = NSURL(fileURLWithPath: path!)
                    let appleScript = NSAppleScript(contentsOfURL: url, error: nil)
                    let parameter = NSAppleEventDescriptor(string: name)
                    let parameterList = NSAppleEventDescriptor.listDescriptor()
                    parameterList.insertDescriptor(parameter, atIndex: 1)
                    var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
                    let target = NSAppleEventDescriptor(descriptorType: DescType(typeProcessSerialNumber), bytes: &psn, length: sizeof(ProcessSerialNumber))
                    let handler = NSAppleEventDescriptor(string: "play_pause_app")
                    let event = NSAppleEventDescriptor.appleEventWithEventClass(AEEventClass(kASAppleScriptSuite), eventID: AEEventID(kASSubroutineEvent), targetDescriptor: target, returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
                    event.setParamDescriptor(handler, forKeyword: AEKeyword(keyASSubroutineName))
                    event.setParamDescriptor(parameterList, forKeyword: AEKeyword(keyDirectObject))
                    appleScript!.executeAppleEvent(event, error: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set button text style and add app entries to dictionary
        paragraphStyle.alignment = .Center
        appDict["Spotify"] = (spotifyButton, false, "Pick Shortcut", nil)
        appDict["VLC"] = (vlcButton, false, "Pick Shortcut", nil)
        appDict["iTunes"] = (iTunesButton, false, "Pick Shortcut", nil)
        appDict["YouTube"] = (youTubeButton, false, "Pick Shortcut", nil)
        
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

