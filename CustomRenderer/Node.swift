//
//  Node.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/13/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

class Node: Hashable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    var position = Vec.zero {
        didSet {
            recomputeGlobals()
            children.forEach { $0.recomputeGlobals() }
        }
    }
    var rotation = Quat.zero {
        didSet {
            recomputeGlobals()
            children.forEach { $0.recomputeGlobals() }
        }
    }
    var scale = Vec.one {
        didSet {
            recomputeGlobals()
            children.forEach { $0.recomputeGlobals() }
        }
    }
    
    var geometry: Geometry {
        didSet {
            geometry.node = self
        }
    }
    var children = Set<Node>()
    var parent: Node?
    
    func recomputeGlobals() {
        let parentRotation = parent?.globalRotation ?? .zero
        let parentPosition = parent?.globalPosition ?? .zero
        let parentScale = parent?.globalScale ?? .one
        
        globalPosition = parentPosition + position.rotated(by: parentRotation)
        globalRotation = parentRotation * rotation
        globalScale = parentScale * scale
    }
    
    private(set) var globalPosition = Vec.zero
    private(set) var globalRotation = Quat.zero
    private(set) var globalScale = Vec.one
    private(set) var boundingMin: Vec!
    private(set) var boundingMax: Vec!
        
    func childGeometries() -> [Geometry] {
        return children.map { $0.childGeometries() }.reduce([geometry], +)
    }
    
    func childLights() -> [Light] {
        return children.map { $0.childLights() }.reduce(self is Light ? [self as! Light] : [], +)
    }
    
    func globalFaces() -> [Face] {
        geometry.faces.map { $0.global() } + children.reduce([], { $0 + $1.globalFaces() })
    }
        
    init() {
        geometry = Geometry(faces: [])
        geometry.node = self
        recomputeGlobals()
    }
    
    init(geometry: Geometry) {
        self.geometry = geometry
        geometry.node = self
        recomputeGlobals()
    }
    
    func addChild(_ child: Node) {
        child.removeFromParent()
        child.parent = self
        children.insert(child)
    }
    
    func removeChild(_ child: Node) {
        children.remove(child)
    }
    
    func removeAllChildren() {
        children.forEach { removeChild($0) }
    }
    
    func removeFromParent() {
        parent?.removeChild(self)
        parent = nil
    }
    
    //returns the closest ancestor passing the closure, including self, or nil
    func ancestorPassing(_ c: (Node) -> Bool) -> Node? {
        return c(self) ? self : parent?.ancestorPassing(c)
    }
}
