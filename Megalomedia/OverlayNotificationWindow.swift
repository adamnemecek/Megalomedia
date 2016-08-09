//
//  OverlayNotificationWindow.swift
//  Megalomedia
//
//  Created by Justin Shi on 7/29/16.
//  Copyright © 2016 Justin Shi. All rights reserved.
//

import Cocoa

// Notification window; overlay over all other windows
class OverlayNotificationWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.Buffered, defer: false)
        self.level = Int(CGWindowLevelForKey(CGWindowLevelKey.StatusWindowLevelKey))
        self.backgroundColor = NSColor.clearColor()
        self.alphaValue = 1.0
        self.opaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = true
    }
    
    override var canBecomeMainWindow: Bool {
        get {
            return false
        }
    }
    
    override var canBecomeKeyWindow: Bool {
        get {
            return false
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}