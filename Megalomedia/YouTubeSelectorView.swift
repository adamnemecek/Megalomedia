//
//  YouTubeSelectorView.swift
//  Megalomedia
//
//  Created by Justin Shi on 8/8/16.
//  Copyright © 2016 Justin Shi. All rights reserved.
//

import Cocoa

class YouTubeSelectorView: NSView {
    
    // Reference to window containing this view
    var notification: NSWindow? = nil
    
    override var flipped: Bool {
        get {
            return true
        }
    }

}
