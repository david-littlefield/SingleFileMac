//
//  TextField.swift
//  SingleFile
//
//  Created by David Littlefield on 7/28/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa

/////////////////////////////////////////////////////////////////////////////////////////////

class TextField: NSTextField {

    // TEXT FIELD //
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.setupTextField()
    }
    
    private func setupTextField() {
        self.backgroundColor = .unemphasizedSelectedContentBackgroundColor
        self.textColor = .secondaryLabelColor
        self.font = NSFont(name: "Arial", size: 15.0)
        self.layer?.cornerRadius = 5.0
        self.wantsLayer = true
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
