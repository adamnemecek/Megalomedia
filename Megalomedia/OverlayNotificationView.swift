//
//  OverlayNotificationView.swift
//  Megalomedia
//
//  Created by Justin Shi on 7/29/16.
//  Copyright © 2016 Justin Shi. All rights reserved.
//

import Cocoa

class OverlayNotificationView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        
        // Rounded corner square view of notification
        let bgColor = NSColor(calibratedWhite: 0.0, alpha: 0.35)
        let bgRect = dirtyRect
        let minX = NSMinX(bgRect)
        let midX = NSMidX(bgRect)
        let maxX = NSMaxX(bgRect)
        let minY = NSMinY(bgRect)
        let midY = NSMidY(bgRect)
        let maxY = NSMaxY(bgRect)
        let radius: CGFloat = 25.0
        let bgPath = NSBezierPath()
        bgPath.moveToPoint(NSMakePoint(midX, minY))
        bgPath.appendBezierPathWithArcFromPoint(NSMakePoint(maxX, minY), toPoint: NSMakePoint(maxX, midY), radius: radius)
        bgPath.appendBezierPathWithArcFromPoint(NSMakePoint(maxX, maxY), toPoint: NSMakePoint(midX, maxY), radius: radius)
        bgPath.appendBezierPathWithArcFromPoint(NSMakePoint(minX, maxY), toPoint: NSMakePoint(minX, midY), radius: radius)
        bgPath.appendBezierPathWithArcFromPoint(bgRect.origin, toPoint: NSMakePoint(midX, minY), radius: radius)
        bgPath.closePath()
        bgColor.set()
        bgPath.fill()
    }
}
