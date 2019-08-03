//
//  Divider.swift
//  SingleFile
//
//  Created by David Littlefield on 7/27/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa

/////////////////////////////////////////////////////////////////////////////////////////////

class Divider: NSView {

    // VIEW //
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setupView()
    }
    
    private func setupView() {
        layer?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        wantsLayer = true
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
