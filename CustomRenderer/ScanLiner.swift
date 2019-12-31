//
//  ScanLiner.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/24/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

class ScanLiner: Renderer {
    func render(_ wrapper: RendererWrapper) {
        let widthOffset = wrapper.widthOffset!
        let heightOffset = wrapper.heightOffset!
        
        var zBuffer = [Double].init(repeating: wrapper.camera.zFar, count: wrapper.renderedWidth * wrapper.renderedHeight)
        
        for geometry in wrapper.rootNode.childGeometries() {
            for face in geometry.faces.map({ $0.transformed(by: wrapper.camera) }) {
                //back culling
                let ab = face.b - face.a
                let ac = face.c - face.a
                guard ab.cross(ac).z > 0 else { continue }

                for splitFace in face.project(with: wrapper.camera).splitToHorizontalBases() {
                    let y1 = max(-heightOffset, min(splitFace.a.y, splitFace.b.y))
                    let y2 = min(heightOffset, max(splitFace.a.y, splitFace.b.y))

                    //iterate vertically
                    var y = y1 - 1
                    while y <= y2 {
                        y += 1

                        //get the bounds of the scanline at height y
                        //then get the x bounds, and the corresponding z coordinate at the endpoints
                        var (x1, z1, x2, z2) = splitFace.getBounds(at: y)
                        if x2 < x1 {
                            swap(&x1, &x2)
                            swap(&z1, &z2)
                        }

                        //x1, x2 give the endpoints for the scanline
                        //x3, x4 give the endpoints clipped to the bounds of the screen
                        let x3 = max(x1, -widthOffset)
                        let x4 = min(x2, widthOffset)

                        //iterate horizontally
                        var x = x3 - 1
                        while x <= x4 {
                            x += 1

                            //get the z coordinate at (x, y)
                            let percent = (x - x1) / (x2 - x1)
                            let z = (z2 - z1) * percent + z1
                            guard wrapper.camera.zNear <= z && z <= wrapper.camera.zFar else { continue }

                            let frameX = Int(round(x) + widthOffset)
                            let frameY = Int(heightOffset - round(y))
                            
                            //sometimes x or y can be rounded up, so we need one last bounds check
                            guard 0 <= frameX && frameX < wrapper.renderedWidth else { continue }
                            guard 0 <= frameY && frameY < wrapper.renderedHeight else { continue }

                            //check the zBuffer first
                            let i = frameY * wrapper.renderedWidth + frameX
                            guard z <= zBuffer[i] else { continue }

                            let color = splitFace.color
                            wrapper.dataForRendering[3 * i + 0] = UInt8(color.redComponent * 255)
                            wrapper.dataForRendering[3 * i + 1] = UInt8(color.greenComponent * 255)
                            wrapper.dataForRendering[3 * i + 2] = UInt8(color.blueComponent * 255)

                            zBuffer[i] = z
                            wrapper.hittests[i] = face.node
                        }
                    }
                }
            }
        }
    }
}
