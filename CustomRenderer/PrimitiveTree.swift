//
//  PrimitiveTree.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/27/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

class PrimitiveTree {
    var minBounds: Vec!
    var maxBounds: Vec!
    
    var fastIntersection = false
    var primitive: Primitive?
    var left: PrimitiveTree?
    var right: PrimitiveTree?
        
    init(primitives: [Primitive]) {
        guard primitives.count != 0 else { fatalError() }
        
        minBounds = primitives[0].minBounds
        maxBounds = primitives[0].maxBounds
        for i in 1..<primitives.count {
            minBounds = minBounds.pointwiseMin(primitives[i].minBounds)
            maxBounds = maxBounds.pointwiseMax(primitives[i].maxBounds)
        }
        fastIntersection = minBounds.x == maxBounds.x || minBounds.y == maxBounds.y || minBounds.z == maxBounds.z
        guard primitives.count != 1 else {
            self.primitive = primitives[0]
            return
        }
        
        let deltaVec = maxBounds - minBounds
        let maxDelta = max(deltaVec.x, deltaVec.y, deltaVec.z)
        let index: Int
        //we simply don't divide by two here...
        let doubledPivot: Double
        
        if maxDelta == deltaVec.x {
            index = 0
            doubledPivot = minBounds.x + maxBounds.x
        } else if maxDelta == deltaVec.y {
            index = 1
            doubledPivot = minBounds.y + maxBounds.y
        } else if maxDelta == deltaVec.z {
            index = 2
            doubledPivot = minBounds.z + maxBounds.z
        } else {
            fatalError()
        }
                
        var leftPrimitives = [Primitive]()
        var rightPrimitives = [Primitive]()
        for p in primitives {
            //...and then also don't divide by two here
            if p.minBounds[index] + p.maxBounds[index] < doubledPivot {
                leftPrimitives.append(p)
            } else {
                rightPrimitives.append(p)
            }
        }
        
        if leftPrimitives.count == 0 || rightPrimitives.count == 0 {
            self.left = .init(primitives: Array(primitives.prefix(upTo: primitives.count / 2)))
            self.right = .init(primitives: Array(primitives.suffix(from: primitives.count / 2)))
        } else {
            self.left = .init(primitives: leftPrimitives)
            self.right = .init(primitives: rightPrimitives)
        }
    }
    
    func intersectedPrimitives(rayOrigin: Vec, rayInverseDir dir: Vec) -> [Primitive] {
        //https://tavianator.com/fast-branchless-raybounding-box-intersections-part-2-nans/
        func intersectsBox() -> Bool {
            var t1 = (minBounds.x - rayOrigin.x) * dir.x
            var t2 = (maxBounds.x - rayOrigin.x) * dir.x
            var tmin = min(t1, t2)
            var tmax = max(t1, t2)


            t1 = (minBounds.y - rayOrigin.y) * dir.y
            t2 = (maxBounds.y - rayOrigin.y) * dir.y
//            tmin = max(min(t1, t2), tmin)
//            tmax = min(max(t1, t2), tmax)
            tmin = max(min(tmax, min(t1, t2)), tmin)
            tmax = min(max(tmin, max(t1, t2)), tmax)


            t1 = (minBounds.z - rayOrigin.z) * dir.z
            t2 = (maxBounds.z - rayOrigin.z) * dir.z
//            tmin = max(min(t1, t2), tmin)
//            tmax = min(max(t1, t2), tmax)
            tmin = max(min(tmax, min(t1, t2)), tmin)
            tmax = min(max(tmin, max(t1, t2)), tmax)
            
            return tmax > max(tmin, 0)
        }
        
        guard fastIntersection || intersectsBox() else { return [] }
        guard let lt = left, let rt = right else { return [self.primitive!] }
        return lt.intersectedPrimitives(rayOrigin: rayOrigin, rayInverseDir: dir) + rt.intersectedPrimitives(rayOrigin: rayOrigin, rayInverseDir: dir)
    }
}
