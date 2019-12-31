//
//  WindowController.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/14/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func keyDown(with event: NSEvent) {
        contentViewController?.keyDown(with: event)
    }

}
