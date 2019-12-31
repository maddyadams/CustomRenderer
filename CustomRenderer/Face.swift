//
//  Face.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/14/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation
import AppKit

class Face: Hashable {
    var a: Vec
    var b: Vec
    var c: Vec
    private(set) var color: NSColor
    var node: Node!
    
    private(set) var u: Vec!
    private(set) var v: Vec!
    private(set) var n: Vec!
    private(set) var ucrossv: Vec!
    private(set) var minBounds: Vec!
    private(set) var maxBounds: Vec!
    
    static func ==(lhs: Face, rhs: Face) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    func set(color: NSColor) {
        self.color = color.usingColorSpace(.deviceRGB)!
    }
    
    static func from(polygon: [Vec], color: NSColor) -> [Face] {
        var result = [Face]()
        if polygon.count <= 3 {
            result.append(.init(polygon, color: color, node: nil))
            return result
        }
        
        for i in 2..<polygon.count {
            result.append(.init([polygon[0], polygon[i - 1], polygon[i]], color: color, node: nil))
        }
        return result
    }
    
    init(_ vertices: [Vec], color: NSColor, node: Node?) {
        guard vertices.count == 3 else { fatalError() }
        a = vertices[0]
        b = vertices[1]
        c = vertices[2]
        self.color = color.usingColorSpace(.deviceRGB)!
        self.node = node
    }
    
    func transformed(by camera: Camera) -> Face {
        //local rotate, scale, translate, camera rotate
        let deltaR = node.globalRotation
        let deltaS = node.globalScale
        let deltaT = node.globalPosition - camera.globalPosition
        let deltaC = camera.globalRotation
        
        return Face([a, b, c].map {
            ($0.rotated(by: deltaR) * deltaS + deltaT).rotated(by: deltaC)
        }, color: color, node: node)
    }
    
    func global() -> Face {
        let result = transformed(by: Camera())
        result.computeRaytraceProperties()
        return result
    }
    
    func computeRaytraceProperties() {
        u = c - a
        v = b - a
        n = u.cross(v).normalized()
        ucrossv = u.cross(v)
        minBounds = Vec(min(a.x, b.x, c.x), min(a.y, b.y, c.y), min(a.z, b.z, c.z))
        maxBounds = Vec(max(a.x, b.x, c.x), max(a.y, b.y, c.y), max(a.z, b.z, c.z))
    }
    
    func contains(_ p: Vec) -> Bool {
        let u = self.u!
        let v = self.v!
        let w = p - a
        let n = self.ucrossv!
        
        let gamma = u.cross(w).dot(n) / n.dot(n)
        let beta = w.cross(v).dot(n) / n.dot(n)
        let alpha = 1 - gamma - beta
        let lEpsilon = -1e-6
        let rEpsilon = 1 + 1e6
        
        return lEpsilon <= alpha && alpha <= rEpsilon &&
               lEpsilon <= beta && beta <= rEpsilon &&
               lEpsilon <= gamma && gamma <= rEpsilon
    }
    
    func project(with camera: Camera) -> Face {
        return Face([a, b, c].map {
            $0.project(camera._getTrueFov())
        }, color: color, node: node)
    }
    
    //splits this into at most two faces, each of which is on the camera's near clipping plane
    //and has a horizontal base. the intuition behind this is similar to that of splitting up
    //a double integral over a triangle, since scanlines are similar to double integration.
    func splitToHorizontalBases() -> [Face] {
        let sorted = [a, b, c].sorted(by: { $0.y < $1.y })
        let aa = sorted[0]
        let bb = sorted[1]
        let cc = sorted[2]
        
        let tValue = (bb.y - aa.y) / (cc.y - aa.y)
        guard tValue.isFinite else { return [] }
        
        let dd = Vec((cc.x - aa.x) * tValue + aa.x,
                     bb.y,
                     (cc.z - aa.z) * tValue + aa.z)
        let firstTriangle = [aa, bb, dd]
        let secondTriangle = [cc, dd, bb]
        return [Face(firstTriangle, color: color, node: node), Face(secondTriangle, color: color, node: node)]
    }
    
    func getBounds(at y: Double) -> (x1: Double, z1: Double, x2: Double, z2: Double) {
        if a.y == b.y {
            return (b.x, b.z, c.x, c.z)
        }
        let percent = (y - a.y) / (b.y - a.y)
        if percent < 0 { return (a.x, a.z, a.x, a.z) }
        if percent > 1 { return (b.x, b.z, c.x, c.z) }
        
        let x1 = (b.x - a.x) * percent + a.x
        let z1 = (b.z - a.z) * percent + a.z
        let x2 = (c.x - a.x) * percent + a.x
        let z2 = (c.z - a.z) * percent + a.z
        return (x1, z1, x2, z2)
    }
}
