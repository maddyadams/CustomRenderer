//
//  Vec.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/13/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

struct Vec {
    var x = 0.0
    var y = 0.0
    var z = 0.0
    
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    static let zero = Vec(0, 0, 0)
    static let one = Vec(1, 1, 1)
    static let xAxis = Vec(1, 0, 0)
    static let yAxis = Vec(0, 1, 0)
    static let zAxis = Vec(0, 0, 1)
    
    static func +(lhs: Vec, rhs: Vec) -> Vec {
        return Vec(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    static func +=(lhs: inout Vec, rhs: Vec) {
        lhs = Vec(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    static func -(lhs: Vec, rhs: Vec) -> Vec {
        return Vec(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    static func -=(lhs: inout Vec, rhs: Vec) {
        lhs = Vec(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    static func *(lhs: Vec, rhs: Double) -> Vec {
        return Vec(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    static func *=(lhs: inout Vec, rhs: Double) {
        lhs = Vec(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    static func *(lhs: Vec, rhs: Vec) -> Vec {
        return Vec(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
    }
    static func *=(lhs: inout Vec, rhs: Vec) {
        lhs = Vec(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
    }
    static func /(lhs: Vec, rhs: Double) -> Vec {
        return Vec(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
    static func /=(lhs: inout Vec, rhs: Double) {
        lhs = Vec(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
    
    func magnitude() -> Double { return sqrt(self.dot(self)) }
    func dot(_ other: Vec) -> Double { return x * other.x + y * other.y + z * other.z }
    func normalized() -> Vec { return self / magnitude() }
    
    func cross(_ other: Vec) -> Vec {
        /* i       j       k
           self.x  self.y  self.z
           other.x other.y other.z
        */
        return Vec(y * other.z - z * other.y,
                  -x * other.z + z * other.x,
                   x * other.y - y * other.x)
    }
    
    func rotated(by q: Quat) -> Vec { return q.rotate(self) }
    func project(_ fov: Double) -> Vec {
        return Vec(fov * x / abs(z), fov * y / abs(z), z)
    }
    
    subscript(_ i: Int) -> Double {
        get {
            if i == 0 { return x }
            else if i == 1 { return y }
            else if i == 2 { return z }
            else { fatalError() }
        } set {
            if i == 0 { x = newValue }
            else if i == 1 { y = newValue }
            else if i == 2 { z = newValue }
            else { fatalError() }
        }
    }
    
    func pointwiseMin(_ other: Vec) -> Vec {
        return Vec(min(x, other.x), min(y, other.y), min(z, other.z))
    }
    
    func pointwiseMax(_ other: Vec) -> Vec {
        return Vec(max(x, other.x), max(y, other.y), max(z, other.z))
    }
}
