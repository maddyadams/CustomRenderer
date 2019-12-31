//
//  Primitive.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/30/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation
import AppKit

class Primitive {
    private(set) var color: NSColor
    var node: Node!
    
    var minBounds: Vec!
    var maxBounds: Vec!
    
    init(color: NSColor, node: Node?) {
        self.color = color
        self.node = node
    }
    
    func set(color: NSColor) {
        self.color = color.usingColorSpace(.deviceRGB)!
    }
    
    
    func global() -> Primitive {
        return .init(color: color, node: node)
    }
}
