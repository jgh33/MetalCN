//
//  Renderer.swift
//  MetalCN
//
//  Created by 焦国辉 on 2022/2/19.
//

import Foundation
import MetalKit
import simd

struct AAPLVertex {
    var position: vector_float2
    var color: vector_float4
    
    init(_ position: vector_float2, _ color: vector_float4) {
        self.position = position
        self.color = color
    }
};

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var pipelineState: MTLRenderPipelineState
    var commandQueue: MTLCommandQueue
    var viewportSize: vector_uint2
    
    init?(with mtkView: MTKView) {
        guard let d = mtkView.device else {return nil}
        device = d
        guard let library = device.makeDefaultLibrary() else {return nil}
        let vf = library.makeFunction(name: "vertexShader")
        let ff = library.makeFunction(name: "fragmentShader")
        
        let psd = MTLRenderPipelineDescriptor()
        psd.vertexFunction = vf
        psd.fragmentFunction = ff
        psd.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        guard let ps = try? device.makeRenderPipelineState(descriptor: psd) else {return nil}
        self.pipelineState = ps
        guard let cq = device.makeCommandQueue() else {return nil}
        self.commandQueue = cq
        
        viewportSize = vector_uint2(x: 0, y: 0)
        
        super.init()

    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
    }
    
    func draw(in view: MTKView) {
//        let vertexes:[Float32] = [
//        250,    -250,   1, 0, 0, 1,
//        -250,   -250,   0, 1, 0, 1,
//        0,      250,    0, 0, 1, 1
//        ]
        
        let vertexes:[AAPLVertex] = [
            AAPLVertex(vector_float2(250, -250), vector_float4(1, 0, 0, 1)),
            AAPLVertex(vector_float2(-250, -250), vector_float4(0, 1, 0, 1)),
            AAPLVertex(vector_float2(0, 250), vector_float4(0, 0, 1, 1)),
        ]
        

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {return}
        guard let pd = view.currentRenderPassDescriptor else {return}
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: pd) else {return}
        let width:Double = Double(viewportSize.x)
        let height:Double = Double(viewportSize.y)
        encoder.setViewport(MTLViewport(originX: 0, originY: 0, width: width, height: height, znear: 0, zfar: 1))
        encoder.setRenderPipelineState(pipelineState)
//        let length1 = MemoryLayout<Float32>.size * 18
        let length1 = MemoryLayout<AAPLVertex>.size * 3
        encoder.setVertexBytes(vertexes, length: length1, index: 0)
        
        encoder.setVertexBytes(&viewportSize, length: MemoryLayout.size(ofValue: viewportSize), index: 1)
        
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        encoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    
}
