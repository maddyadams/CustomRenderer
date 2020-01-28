//
//  Sphere.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/30/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation
import AppKit

class Sphere: Primitive {
    var center: Vec
    var radius: Double
    private(set) var radius2: Double!
    
    init(center: Vec = .zero, radius: Double, color: NSColor, node: Node? = nil) {
        self.center = center
        self.radius = radius
        super.init(color: color, node: node)
    }
    
    override func global() -> Primitive {
        let newCenter = node.transform(point: center)
        //we assume we don't have any scaling. probably a bad assumption
        let newRadius = radius
        let result = Sphere(center: newCenter, radius: newRadius, color: color, node: node)
        
        result.radius2 = newRadius * newRadius
        result.minBounds = newCenter - Vec(newRadius, newRadius, newRadius)
        result.maxBounds = newCenter + Vec(newRadius, newRadius, newRadius)
        
        return result
    }
    
    override func intersect(origin: Vec, direction dir: Vec, t: Double, shadowRay: Bool) -> (Vec, Double)? {
        //p0 = origin + dir*t
        //|center - p0| = radius
        //sqrt[(center.x - p0.x)^2 + ... ] = radius
        //(center.x - p0.x)^2 + ... = radius^2
        //center.x^2 - 2center.x*p0.x + p0.x^2 + ... = radius^2
        //center.x^2 - 2center.x*(origin.x + dir.x*t) + (origin.x + dir.x*t)^2 + ... = radius^2
        //center.dot(center) - 2center.dot(origin + dir*t) + origin.x^2 + 2origin.x*dir.x*t + dir.x^2*t^2 + ... = radius^2
        //center.dot(center) - 2center.dot(origin + dir*t) + origin.dot(origin) + 2origin.dot(dir*t) + dir.dot(dir)*t^2 = radius^2
        //dir.dot(dir)*t^2 + 2origin.dot(dir*t)-2center.dot(origin+dir*t) + center.dot(center) + origin.dot(origin) - radius^2 = 0
        //dir.dot(dir)*t^2 + 2t*origin.dot(dir)-2center.dot(origin)-2center.dot(dir*t) + center^2 + origin^2 - radius^2 = 0
        //dir.dot(dir)*t^2 + 2t*origin.dot(dir)-2center.dot(origin)-2t*center.dot(dir) + center^2 + origin^2 - radius^2 = 0
        //dir.dot(dir)*t^2 + 2t(origin.dot(dir)-center.dot(dir)) + center^2-2center.dot(origin)+origin^2 - radius^2 = 0
        //dir.dot(dir)*t^2 + 2t(dir.dot(origin-center)) + (origin-center)^2 - radius^2 = 0
        //a = dir.dot(dir), b = 2dir.dot(origin-center), c = (origin-center)^2 - radius^2
        
//        let oc = origin - center
//        let a = 1.0 // dir.dot(dir), dir is normalized already
//        let b = 2 * oc.dot(dir)
//        let c = oc.dot(oc) - radius*radius
//        let discrimant = b*b - 4*a*c
//        if discrimant < 0 { return nil }
//
//        let t = (-b-sqrt(discrimant))/(2*a)
//        let intersectionPoint = origin + dir * t
//        return (intersectionPoint, t)
        
        let oc = origin - center
        let b = 2 * oc.dot(dir)
        let c = oc.dot(oc) - radius2
        let discriminant = b*b - 4*c
        
        if discriminant < 0 { return nil }
        let t0 = (-b-sqrt(discriminant)) / 2
        guard 1e-6 <= t0 && t0 < t else { return nil }
        
        return (origin + dir * t0, t0)
    }
    
    override func normal(at point: Vec) -> Vec {
        return (point - center).normalized()
    }
}
