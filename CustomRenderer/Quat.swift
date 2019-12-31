//
//  Quat.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/13/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

struct Quat {
    private var _scalar = 0.0
    private var _axis = Vec.zero
    
    init(theta: Double, axis: Vec) {
        self._scalar = cos(theta / 2)
        self._axis = axis.normalized() * sin(theta / 2)
        if self._axis.x.isNaN { self._axis.x = 0 }
        if self._axis.y.isNaN { self._axis.y = 0 }
        if self._axis.z.isNaN { self._axis.z = 0 }
    }
    
    static let zero = Quat(theta: 1, axis: .zero)
    
    private init() { }
    private static func raw(_ scalar: Double, _ axis: Vec) -> Quat {
        var result = Quat()
        result._scalar = scalar
        result._axis = axis
        return result
    }
    
    static func *(lhs: Quat, rhs: Quat) -> Quat {
        /* definition of quaternion multiplication, where lhs = s + v, rhs = t + w,
        * s and t are the scalar components (ie Quaternion.w), and v and w are the vector
        * components (ie Quaternion.axis)
        *
        *   lhs * rhs  =
        *  (s + v)(t + w) = (st - v.dot(w)) + (sw + tv + v.cross(w))
        */
        
        let s = lhs._scalar
        let v = lhs._axis
        let t = rhs._scalar
        let w = rhs._axis
        
        return Quat.raw(s * t - v.dot(w), (w * s) + (v * t) + v.cross(w))
    }
    static func *=(lhs: inout Quat, rhs: Quat) {
        lhs = lhs * rhs
    }
    
    func rotate(_ v: Vec) -> Vec {
        return (self *
                   (Quat.raw(0, v) * self.inverse())
               )._axis
    }
    
    func inverse() -> Quat {
        // (s + v)^-1 = (s - v)/(s^2 + ||v||^2)
        let denom = _scalar * _scalar + _axis.magnitude() * _axis.magnitude()
        return Quat.raw(_scalar / denom, _axis / -denom)
    }
    
    func pitch() -> Double {
        //https://math.stackexchange.com/questions/687964
        //phi = arctan2(q2q3 + q0q1, 1/2 - (q1^2 + q2^2))
        let (q0, q1, q2, q3) = (_scalar, _axis.x, _axis.y, _axis.z)
        return atan2(q2*q3 + q0*q1, 1.0/2 - (q1*q1 + q2*q2))
    }
    
    func roll() -> Double {
        //https://math.stackexchange.com/questions/687964
        //psi = arctan2(q1q2 + q0q3, 1/2 - (q2^2 + q3^2))
        let (q0, q1, q2, q3) = (_scalar, _axis.x, _axis.y, _axis.z)
        return atan2(q1*q2 + q0*q3, 1.0/2 - (q2*q2 + q3*q3))
    }
    
    func yaw() -> Double {
        //https://math.stackexchange.com/questions/687964
        //theta = arcsin(-2(q1q3 - q0q2))
        let (q0, q1, q2, q3) = (_scalar, _axis.x, _axis.y, _axis.z)
        return asin(-2.0*(q1*q3 - q0*q2))
    }
    
    static func from(euler: Vec) -> Quat {
        return Quat(theta: euler.y, axis: .zAxis)
             * Quat(theta: euler.x, axis: .xAxis)
             * Quat(theta: euler.z, axis: .yAxis)
    }
    
    //NOTE: different from internal representation
    var axis: Vec {
        return _axis / _axis.magnitude()
    }
    
    //NOTE: different from internal representation
    var theta: Double {
        return 2 * atan2(_axis.magnitude(), _scalar)
    }
    
    static func *(lhs: Quat, rhs: Double) -> Quat {
        return Quat.raw(lhs._scalar * rhs, lhs._axis * rhs)
    }
    static func *=(lhs: inout Quat, rhs: Double) {
        lhs = lhs * rhs
    }
    
    func scaled(_ rhs: Double) -> Quat {
        return Quat(theta: theta * rhs, axis: axis * rhs)
    }
    
    static func +(lhs: Quat, rhs: Quat) -> Quat {
        return Quat.raw(lhs._scalar + rhs._scalar, lhs._axis + rhs._axis)
    }
    static func +=(lhs: inout Quat, rhs: Quat) {
        lhs = lhs + rhs
    }
    
    func normalized() -> Quat {
        return Quat.raw(_scalar / magnitude(), _axis / magnitude())
    }
    
    func magnitude() -> Double {
        return sqrt(_scalar * _scalar + _axis.magnitude() * _axis.magnitude())
    }
    
    func distance(to: Quat) -> Double {
        let dS = _scalar - to._scalar
        let dA = (_axis - to._axis).magnitude()
        return sqrt(dS * dS + dA * dA)
    }
}
