//
//  ViewController.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/13/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Cocoa

#error("Change this path to a suitable destination for the rendered frame on your computer")
let filePath = "/Users/msa/Desktop/raytrace.png"

class ViewController: NSViewController {
    @IBOutlet weak var imageView: NSImageView!
    var startTime: Date!
    var renderer: RendererWrapper!
    
    var box: Node!
    var floor: Node!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer = RendererWrapper(frameRate: 1.0/60, size: imageView.frame.size, renderer: RayTracer())
        
        addNodes()
        addListeners()
        
        renderer.start { image in
            DispatchQueue.main.async { self.imageView.image = image }
            DispatchQueue.main.async {
                let data = NSBitmapImageRep(data: image.tiffRepresentation!)!.representation(using: .png, properties: [:])!
                do {
                    try data.write(to: URL(fileURLWithPath: filePath))
                } catch {
                    print("ERROR: could not write data to path \(filePath)")
                    print("Did you remember to change the file path?")
                }
            }
        }
    }
        
    func addNodes() {
        box = Node()
        box.position = Vec(0, 0, 20)
        box.geometry = .torus(innerRadius: 0.5, outerRadius: 2, uSubdiv: 128, vSubdiv: 128)
        box.geometry.set(color: .red)
        renderer.rootNode.addChild(box)

        let throwaway = Node(geometry: .torus(innerRadius: 0.1, outerRadius: 2, uSubdiv: 128, vSubdiv: 128))
        throwaway.geometry.set(color: .green)
        throwaway.position = Vec(2, 0, 20)
        throwaway.rotation *= Quat(theta: .pi / 2, axis: .xAxis)
        renderer.rootNode.addChild(throwaway)

        let sphere = Node(geometry: .sphere(radius: 2))
        sphere.geometry.set(color: .gray)
        sphere.position = Vec(-2, 0, 25)
        renderer.rootNode.addChild(sphere)
        
        floor = Node()
        floor.position = Vec(0, -2, 0)
        floor.geometry = .boxGeometry(width: 100, height: 1, depth: 100)
        floor.geometry.set(color: .blue)
        renderer.rootNode.addChild(floor)

                
        var l = Light(.omni)
        l.position = Vec(0.7, 4, 23)
        renderer.rootNode.addChild(l)
        
        l = Light(.omni)
        l.position = Vec(-7, -0.5, 17)
        renderer.rootNode.addChild(l)
        
        l = Light(.omni)
        l.position = Vec(-0.5, 0, 20)
        renderer.rootNode.addChild(l)
        
        
        let ambient = Light(.ambient)
        ambient.intensity = 0.3
        renderer.rootNode.addChild(ambient)
        
        renderer.camera.position = Vec(0, 0, -20)
        
        let cParent = Node()
        renderer.rootNode.addChild(cParent)
        cParent.position = box.position
        renderer.camera.position = Vec(0, 0, -40)
        cParent.addChild(renderer.camera)
    }
    
    func addListeners() {
        renderer.tickListeners.append { t in
            self.box.rotation *= Quat(theta: 1.0/30, axis: Vec(.random(in: 0...1), .random(in: 0...1), .random(in: 0...1)))
        }
    }
    
    override func keyDown(with event: NSEvent) {
        var theta = renderer.camera.rotation.yaw()
        
        switch event.charactersIgnoringModifiers?.lowercased() {
        case "a": theta += .pi / 2; fallthrough
        case "s": theta += .pi / 2; fallthrough
        case "d": theta += .pi / 2; fallthrough
        case "w": renderer.camera.position += Vec(sin(theta), 0, cos(theta))
            
        case "q": renderer.camera.position += Vec(0, 1, 0) * 0.1
        case "e": renderer.camera.position += Vec(0, -1, 0) * 0.1
            
        case "r": renderer.camera.rotation *= Quat(theta: .pi / 360, axis: .xAxis)
        case "f": renderer.camera.rotation *= Quat(theta: -.pi / 360, axis: .xAxis)
        case "t": renderer.camera.rotation *= Quat(theta: .pi / 360, axis: .zAxis)
        case "g": renderer.camera.rotation *= Quat(theta: -.pi / 360, axis: .zAxis)
        case "y": renderer.camera.rotation *= Quat(theta: .pi / 360, axis: .yAxis)
        case "h": renderer.camera.rotation *= Quat(theta: -.pi / 360, axis: .yAxis)
                    
        case "u": renderer.camera.parent!.rotation *= Quat(theta: .pi / 60, axis: .yAxis)
        case "j": renderer.camera.parent!.rotation *= Quat(theta: -.pi / 60, axis: .yAxis)
            
        case "z":
            renderer.changeScaleFactor(to: 0.25)
            (renderer.renderer as? RayTracer)?.changeRecurseLimit(to: 16)
        case "x": renderer.changeScaleFactor(to: 1)
        case "c": renderer.changeScaleFactor(to: 2)
        case "v": renderer.changeScaleFactor(to: 3)
        case "b": renderer.changeScaleFactor(to: 4)
        case "n": renderer.changeScaleFactor(to: 5)
        case "m": renderer.changeScaleFactor(to: 6)
        case ",": renderer.changeScaleFactor(to: 7)
        case ".": renderer.changeScaleFactor(to: 8)
        case "/": renderer.changeScaleFactor(to: 9)
            
        case "i": (renderer.renderer as? RayTracer)?.changeRecurseLimit(to: 1)
        case "o": (renderer.renderer as? RayTracer)?.changeRecurseLimit(to: 2)
        case "p": (renderer.renderer as? RayTracer)?.changeRecurseLimit(to: 3)
        case "[": (renderer.renderer as? RayTracer)?.changeRecurseLimit(to: 4)
        case "]": (renderer.renderer as? RayTracer)?.changeRecurseLimit(to: 5)
        case "\\": (renderer.renderer as? RayTracer)?.changeRecurseLimit(to: 6)
            
        default: break
        }
    }
}

