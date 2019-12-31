//
//  Geometry.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/14/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation
import AppKit

class Geometry {
    var primitives = [Primitive]() {
        didSet {
            primitives.forEach { $0.node = node }
        }
    }
    private(set) var globalPrimitives: [Primitive]!
    
    var node: Node! {
        didSet {
            primitives.forEach { $0.node = node }
        }
    }
    
    init(primitives: [Primitive]) {
        self.primitives = primitives
        primitives.forEach { $0.node = node }
    }
        
    func set(color: NSColor) {
        primitives.forEach { $0.set(color: color) }
    }
    
    static func parameterized(_ f: (Double, Double) -> Vec, uMin: Double, uMax: Double, vMin: Double, vMax: Double, uSubdiv: Int, vSubdiv: Int) -> Geometry {
        let faces = (0..<vSubdiv).map { (v: Int) -> [Face] in
            (0..<uSubdiv).map { (u: Int) -> [Face] in
                let verts = [(u, v), (u, v + 1), (u + 1, v + 1), (u + 1, v)].map { (p: (Int, Int)) -> Vec in
                    f((uMax - uMin) * Double(p.0) / Double(uSubdiv) + uMin,
                      (vMax - vMin) * Double(p.1) / Double(vSubdiv) + vMin)
                }
                return Face.from(polygon: verts, color: .white)
            }.reduce([], +)
        }
        return Geometry(primitives: faces.reduce([], +))
    }
    
    static func sphere(radius: Double, uSubdiv: Int, vSubdiv: Int) -> Geometry {
        func toLocal(u: Double, v: Double) -> Vec {
            return Vec(radius * cos(u) * sin(v), radius * cos(v), radius * sin(u) * sin(v))
        }
        
        return parameterized(toLocal, uMin: 0, uMax: 2 * .pi, vMin: 0, vMax: .pi, uSubdiv: uSubdiv, vSubdiv: vSubdiv)
    }
    
    static func torus(innerRadius: Double, outerRadius: Double, uSubdiv: Int, vSubdiv: Int) -> Geometry {
        func toLocal(u: Double, v: Double) -> Vec {
            return Vec(outerRadius * sin(u) + innerRadius * sin(v) * sin(u),
                       -innerRadius * cos(v),
                       outerRadius * cos(u) + innerRadius * sin(v) * cos(u))
        }
        
        return parameterized(toLocal, uMin: 0, uMax: 2 * .pi, vMin: 0, vMax: 2 * .pi, uSubdiv: uSubdiv, vSubdiv: vSubdiv)
    }
        
    static func boxGeometry(width: Double, height: Double, depth: Double) -> Geometry {
        let w = width / 2
        let h = height / 2
        let d = depth / 2
        
        let vertices = [Vec(-w, -h, -d),
                        Vec(-w, -h, +d),
                        Vec(-w, +h, -d),
                        Vec(-w, +h, +d),
                        Vec(+w, -h, -d),
                        Vec(+w, -h, +d),
                        Vec(+w, +h, -d),
                        Vec(+w, +h, +d)]
        
        /*     6------7
              /|     /|
             / |    / |
            /  |   /  |
           4------5   |
           |   2--|---3
           |  /   |  /
           | /    | /
           |/     |/
           0------1
        */
        
        let indices = [
            1, 0, 2, 3, //bottom
            2, 0, 4, 6, //left
            3, 7, 5, 1, //right
            7, 6, 4, 5, //top
            5, 4, 0, 1, //front
            3, 2, 6, 7 //back
        ]
        
        let faces = stride(from: 0, to: indices.count, by: 4).map { i in
            Face.from(polygon: (0..<4).map { vertices[indices[i + $0]] },
                      color: .white)
        }.reduce([], +)
        
        return Geometry(primitives: faces)
    }    
}
