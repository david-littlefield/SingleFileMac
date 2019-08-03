//
//  View.swift
//  SingleFile
//
//  Created by David Littlefield on 7/27/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa

/////////////////////////////////////////////////////////////////////////////////////////////

class View: NSView {

    // VIEW //
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(nil)
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
