//
//  Raytracer.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/24/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

class RayTracer: Renderer {
    var wrapper: RendererWrapper!
    
    private var lightsForRenderPass: [Light]!
    private var faceTree: FaceTree!
    private var recurseLimit = 1
    private var nextRecurseLimit: Int?
    
    private var rootNode: Node!
    private var camera: Camera!
    
    private var widthOffset: Double!
    private var heightOffset: Double!
    
    private var data: [Data]!
    private var hittests: [[Node?]]!
    private var syncThread = DispatchQueue(label: "syncThread")
    
    func changeRecurseLimit(to: Int) {
        nextRecurseLimit = to
    }
    
    func render(_ wrapper: RendererWrapper) {
        self.wrapper = wrapper
        self.rootNode = wrapper.rootNode
        self.camera = wrapper.camera
        self.lightsForRenderPass = rootNode.childLights()
        self.faceTree = FaceTree(faces: rootNode.globalFaces())
        self.widthOffset = wrapper.widthOffset
        self.heightOffset = wrapper.heightOffset
        
        let didResize = wrapper.didResize
        
        self.recurseLimit = nextRecurseLimit ?? recurseLimit
        nextRecurseLimit = nil
        
        let threadCount = 16
        let minY = { return wrapper.renderedHeight * $0 / threadCount }
        let maxY = { return wrapper.renderedHeight * ($0 + 1) / threadCount }
        
        if didResize {
            data = [Data]()
            hittests = [[Node]]()
            for i in 0..<threadCount {
                data.append(Data(repeating: 0, count: wrapper.componentsPerPixel * wrapper.renderedWidth * (maxY(i) - minY(i))))
                hittests.append([Node?].init(repeating: nil, count: wrapper.renderedWidth * (maxY(i) - minY(i))))
            }
        } else {
            for i in 0..<threadCount {
                for j in 0..<hittests[i].count {
                    data[i][3 * j + 0] = 0
                    data[i][3 * j + 1] = 0
                    data[i][3 * j + 2] = 0
                    hittests[i][j] = nil
                }
            }
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        for i in 0..<threadCount {
            DispatchQueue.global().async {
                let (dataPtr, hittestPtr) = self.syncThread.sync {
                    return (UnsafeMutablePointer(&self.data![i]), UnsafeMutablePointer(&self.hittests![i]))
                }
                self.raytracePortion(fromX: 0, toX: wrapper.renderedWidth, fromY: minY(i), toY: maxY(i),
                                     dataPtr: dataPtr, hittestPrt: hittestPtr)
                semaphore.signal()
            }
        }
        for _ in 0..<threadCount {
            semaphore.wait()
        }
        
        wrapper.dataForRendering = Data(data.reduce([], +))
        wrapper.hittests = hittests.reduce([], +)
    }
    
    private func raytracePortion(fromX: Int, toX: Int, fromY: Int, toY: Int,
                                 dataPtr: UnsafeMutablePointer<Data>, hittestPrt: UnsafeMutablePointer<[Node?]>) {
        for x in fromX..<toX {
            for y in fromY..<toY {
                let naiveDirection = Vec((Double(x) - widthOffset) * camera.zNear / camera._getTrueFov(),
                                         (heightOffset - Double(y)) * camera.zNear / camera._getTrueFov(),
                                         camera.zNear)
                
                let primaryRayDirection = camera.globalRotation.rotate(naiveDirection)
                                
                guard let (face, point) = intersectRay(origin: camera.globalPosition, direction: primaryRayDirection, distanceToLight: nil) else {
                    continue
                }
                
                let (r, g, b) = color(at: point, with: primaryRayDirection, on: face, recurseLimit: recurseLimit)
                
                let uir = UInt8(max(min(1, r), 0) * 255)
                let uig = UInt8(max(min(1, g), 0) * 255)
                let uib = UInt8(max(min(1, b), 0) * 255)
                
                let i = (y - fromY) * (toX - fromX) + (x - fromX)
                
                dataPtr.pointee[3 * i + 0] = uir
                dataPtr.pointee[3 * i + 1] = uig
                dataPtr.pointee[3 * i + 2] = uib
                
                hittestPrt.pointee[i] = face.node
            }
        }
    }
    
    private func color(at point: Vec, with dir: Vec, on face: Face, recurseLimit: Int) -> (CGFloat, CGFloat, CGFloat) {
        if recurseLimit <= 0 { return (0, 0, 0) }
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        //shadow rays
        for light in lightsForRenderPass {
            switch light.lightType {
            case .ambient:
                r += CGFloat(light.intensity) * face.color.redComponent
                g += CGFloat(light.intensity) * face.color.greenComponent
                b += CGFloat(light.intensity) * face.color.blueComponent
            case .omni:
                let lightDir = light.globalPosition - point
                if intersectRay(origin: point, direction: lightDir, distanceToLight: lightDir.magnitude()) == nil {
                    let raw = CGFloat(light.intensity * lightDir.dot(face.n) / lightDir.magnitude())
                    
                    r += raw * face.color.redComponent
                    g += raw * face.color.greenComponent
                    b += raw * face.color.blueComponent
                }
            }
        }
        
        guard recurseLimit - 1 > 0 else { return (r, g, b) }
        
        //reflection rays
        let normalPart = face.n! * dir.dot(face.n)
        let nonNormalPart = dir - normalPart

        let newDir = nonNormalPart - normalPart
        if let (newFace, newPoint) = intersectRay(origin: point, direction: newDir, distanceToLight: nil) {
            let (dr, dg, db) = color(at: newPoint, with: newDir, on: newFace, recurseLimit: recurseLimit - 1)
            r += dr * 0.5
            g += dg * 0.5
            b += db * 0.5
        }
        
        return (r, g, b)
    }
    
    
    private func intersectRay(origin: Vec, direction dir: Vec, distanceToLight: Double?) -> (Face, Vec)? {
        var t = distanceToLight ?? camera.zFar + 1
        var result: Face!
        var intersection: Vec!
        let dir = dir.normalized()
        let inverseDir = Vec(1 / dir.x, 1 / dir.y, 1 / dir.z)
        
        let intersectedFaces = faceTree.intersectedFaces(rayOrigin: origin, rayInverseDir: inverseDir)

        for face in intersectedFaces {
            
            let n = face.n!
            let p0 = face.a
            //epsilon check bc the ray and plane may be parallel
            if distanceToLight != nil {
                guard dir.dot(n) > 1e-6 else { continue }
            } else {
                guard dir.dot(n) < -1e-6 else { continue }
            }
            
            //t value for intersection of parameterized ray
            let t0 = (p0 - origin).dot(n) / dir.dot(n)
            guard 1e-6 <= t0 && t0 < t else { continue }
            let someIntersection = origin + dir * t0
            
            guard face.contains(someIntersection) else { continue }
            
            intersection = someIntersection
            t = t0
            result = face
        }
        
        if let result = result, let intersection = intersection {
            return (result, intersection)
        }
        return nil
    }    
}
