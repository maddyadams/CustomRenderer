//
//  Light.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/21/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

class Light: Node {
    enum LightType {
        case ambient, omni//, directional, spot
    }
    
    var lightType: LightType
    var intensity: Double = 1
    
    init(_ lightType: LightType) {
        self.lightType = lightType
        super.init()
    }
}
