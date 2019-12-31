//
//  Camera.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/14/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

class Camera: Node {
    var zNear = 0.001
    var zFar = 1_000_000.0
    var fov = 1.0
    static private let _fovConstant = 2000.0
    
    func _getTrueFov() -> Double {
        return fov * Camera._fovConstant
    }
}
