//
//  YouTubeSelectorTextField.swift
//  Megalomedia
//
//  Created by Justin Shi on 8/9/16.
//  Copyright © 2016 Justin Shi. All rights reserved.
//

import Carbon
import Cocoa

class YouTubeSelectorTextField: NSTextField {
    
    // Index of text field in selection window
    var index: Int
    
    override var opaque: Bool {
        get {
            return false
        }
    }
    
    init(frame frameRect: NSRect, index: Int) {
        self.index = index
        super.init(frame: frameRect)
        self.selectable = false
        self.bordered = false
        self.backgroundColor = NSColor.clearColor()
        self.textColor = NSColor.blackColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    // When text field is clicked, run script for playing/pausing YouTube considering multiple pages according to index of field clicked
    override func mouseDown(theEvent: NSEvent) {
        let path = NSBundle.mainBundle().pathForResource("YouTubeSelection", ofType: "scpt")
        let handler = NSAppleEventDescriptor(string: "youTubeSelection")
        let url = NSURL(fileURLWithPath: path!)
        let appleScript = NSAppleScript(contentsOfURL: url, error: nil)
        let parameter = NSAppleEventDescriptor(int32: Int32(index))
        let parameterList = NSAppleEventDescriptor.listDescriptor()
        parameterList.insertDescriptor(parameter, atIndex: 1)
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        let target = NSAppleEventDescriptor(descriptorType: DescType(typeProcessSerialNumber), bytes: &psn, length: sizeof(ProcessSerialNumber))
        let event = NSAppleEventDescriptor.appleEventWithEventClass(AEEventClass(kASAppleScriptSuite), eventID: AEEventID(kASSubroutineEvent), targetDescriptor: target, returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
        event.setParamDescriptor(handler, forKeyword: AEKeyword(keyASSubroutineName))
        event.setParamDescriptor(parameterList, forKeyword: AEKeyword(keyDirectObject))
        appleScript!.executeAppleEvent(event, error: nil)
        let selectorWindowFadeOut = NSViewAnimation(viewAnimations: [[NSViewAnimationTargetKey: self.window!, NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect], [NSViewAnimationTargetKey: (self.superview! as! YouTubeSelectorView).notification!, NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect]])
        selectorWindowFadeOut.duration = 0.2
        selectorWindowFadeOut.animationBlockingMode = .Blocking
        selectorWindowFadeOut.animationCurve = .EaseIn
        selectorWindowFadeOut.startAnimation()
        self.window!.close()
        NSApplication.sharedApplication().hide(nil)
    }
    
    // Underline text when mouse hovers over
    override func mouseEntered(theEvent: NSEvent) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .ByTruncatingTail
        let attrString = NSMutableAttributedString(string: self.stringValue, attributes: [NSForegroundColorAttributeName: NSColor.blackColor(), NSFontAttributeName: self.font!, NSParagraphStyleAttributeName: style])
        let range = NSRange(location: 0, length: attrString.length)
        attrString.beginEditing()
        attrString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: range)
        attrString.endEditing()
        self.attributedStringValue = attrString
    }
    
    // Remove underline
    override func mouseExited(theEvent: NSEvent) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .ByTruncatingTail
        let attrString = NSMutableAttributedString(string: self.stringValue, attributes: [NSForegroundColorAttributeName: NSColor.blackColor(), NSFontAttributeName: self.font!, NSParagraphStyleAttributeName: style])
        let range = NSRange(location: 0, length: attrString.length)
        attrString.beginEditing()
        attrString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleNone.rawValue, range: range)
        attrString.endEditing()
        self.attributedStringValue = attrString
    }
}
