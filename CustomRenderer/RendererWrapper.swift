//
//  Renderer.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/13/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//


import Foundation
import AppKit

protocol Renderer {
    func render(_ wrapper: RendererWrapper)
}

class RendererWrapper {
    var tickListeners = [(Double) -> ()]()
    let rootNode = Node()
    let camera = Camera()
    
    var renderer: Renderer
    
    var hittests: [Node?]!
    var dataForRendering: Data!
    
    var startTime: Date!
    var frameRate: Double
    var size: CGSize
    
    private var frameWidth: Int
    private var frameHeight: Int
    private var scaleFactor: Double = 8
    private var recurseLimit = 1
    
    private(set) var renderedWidth: Int!
    private(set) var renderedHeight: Int!
    private(set) var widthOffset: Double!
    private(set) var heightOffset: Double!
    
    private var nextWidth: Int?
    private var nextHeight: Int?
    private var nextScaleFactor: Double?
    
    private(set) var didResize = true
    let componentsPerPixel = 3
        
    init(frameRate: Double, size: CGSize, renderer: Renderer) {
        self.frameRate = frameRate
        self.size = size
        self.frameWidth = Int(size.width)
        self.frameHeight = Int(size.height)
        self.renderer = renderer
    }
    
    func start(callback: @escaping (NSImage) -> ()) {
        RunLoop.current.add(.init(timeInterval: frameRate, repeats: true, block: {
            callback(self.tick(t: $0))
        }), forMode: .common)
        startTime = Date()
    }
    
    func changeSize(to: CGSize) {
        nextWidth = Int(to.width)
        nextHeight = Int(to.height)
    }
    
    func changeScaleFactor(to: Double) {
        nextScaleFactor = to
    }
        
    private func tick(t: Timer) -> NSImage {
        scaleFactor = nextScaleFactor ?? scaleFactor
        
        let oldWidth = renderedWidth
        let oldHeight = renderedHeight
                
        if let nw = nextWidth, let nh = nextHeight {
            frameWidth = nw
            frameHeight = nh
        }
        
        renderedWidth = Int(Double(frameWidth) / scaleFactor)
        renderedHeight = Int(Double(frameHeight) / scaleFactor)
        camera.fov = 1 / scaleFactor
        nextWidth = nil
        nextHeight = nil
        nextScaleFactor = nil
        didResize = oldWidth != renderedWidth || oldHeight != renderedHeight
        widthOffset = Double(renderedWidth / 2)
        heightOffset = Double(renderedHeight / 2)

        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(arrayLiteral: [])
        
        if didResize {
            dataForRendering = Data.init(count: componentsPerPixel * renderedWidth * renderedHeight)
        } else {
            for i in 0..<dataForRendering.count {
                dataForRendering[i] = 0
            }
        }
        render(time: Date().timeIntervalSince(startTime))
        let provider = CGDataProvider(data: dataForRendering as CFData)!
        
        let image = CGImage(width: renderedWidth, height: renderedHeight, bitsPerComponent: 8, bitsPerPixel: 8 * componentsPerPixel, bytesPerRow: renderedWidth * 3, space: colorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false, intent: .perceptual)!
        
        didResize = false
        return NSImage(cgImage: image, size: NSSize(width: frameWidth, height: frameHeight))
    }
    
    private func render(time: TimeInterval) {
        let t0 = Date()
        let elapsedDuration = t0.timeIntervalSince(startTime)
        defer { print(Date().timeIntervalSince(t0) * 60) }
        tickListeners.forEach { $0(elapsedDuration) }
        
        if didResize {
            hittests = [Node?].init(repeating: nil, count: renderedWidth * renderedHeight)
        } else {
            for i in 0..<renderedWidth * renderedHeight {
                hittests[i] = nil
            }
        }

        renderer.render(self)
    }
}
