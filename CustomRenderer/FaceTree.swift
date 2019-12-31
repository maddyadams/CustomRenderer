//
//  FaceTree.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/27/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

class FaceTree {
    var minBounds: Vec!
    var maxBounds: Vec!
    
    var fastIntersection = false
    var face: Face?
    var left: FaceTree?
    var right: FaceTree?
        
    init(faces: [Face]) {
        guard faces.count != 0 else { fatalError() }
        
        minBounds = faces[0].minBounds
        maxBounds = faces[0].maxBounds
        for i in 1..<faces.count {
            minBounds = minBounds.pointwiseMin(faces[i].minBounds)
            maxBounds = maxBounds.pointwiseMax(faces[i].maxBounds)
        }
        fastIntersection = minBounds.x == maxBounds.x || minBounds.y == maxBounds.y || minBounds.z == maxBounds.z
        guard faces.count != 1 else {
            self.face = faces[0]
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
                
        var leftFaces = [Face]()
        var rightFaces = [Face]()
        for f in faces {
            //...and then also don't divide by two here
            if f.minBounds[index] + f.maxBounds[index] < doubledPivot {
                leftFaces.append(f)
            } else {
                rightFaces.append(f)
            }
        }
        
        if leftFaces.count == 0 || rightFaces.count == 0 {
            self.left = .init(faces: Array(faces.prefix(upTo: faces.count / 2)))
            self.right = .init(faces: Array(faces.suffix(from: faces.count / 2)))
        } else {
            self.left = .init(faces: leftFaces)
            self.right = .init(faces: rightFaces)
        }
    }
    
    func intersectedFaces(rayOrigin: Vec, rayInverseDir dir: Vec) -> [Face] {
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
        guard let lt = left, let rt = right else { return [self.face!] }
        return lt.intersectedFaces(rayOrigin: rayOrigin, rayInverseDir: dir) + rt.intersectedFaces(rayOrigin: rayOrigin, rayInverseDir: dir)
    }
}
